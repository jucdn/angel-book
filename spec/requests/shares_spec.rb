require "rails_helper"

RSpec.describe "Shares", type: :request do
  let(:owner) { create(:user) }
  let(:password) { "long-enough-password" }
  before { owner.regenerate_share!(password: password) }

  let(:token) { owner.share_token }

  describe "GET /share/:bad_token" do
    it "404s" do
      get share_path("nope")
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /share/:token" do
    it "renders the password form when no valid session" do
      get share_path(token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mot de passe")
    end

    it "redirects to the shared dashboard when session is valid" do
      post unlock_share_path(token), params: { password: password }
      get share_path(token)
      expect(response).to redirect_to(share_dashboard_path(token))
    end
  end

  describe "POST /share/:token/unlock" do
    it "sets the session and redirects to dashboard on right password" do
      post unlock_share_path(token), params: { password: password }
      expect(session[:share_token]).to eq(token)
      expect(response).to redirect_to(share_dashboard_path(token))
    end

    it "re-renders with error on wrong password" do
      post unlock_share_path(token), params: { password: "wrong" }
      expect(session[:share_token]).to be_nil
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(share_path(token))
    end
  end

  describe "DELETE /share/:token/sign_out" do
    it "clears the session and redirects to the gate" do
      post unlock_share_path(token), params: { password: password }
      delete share_sign_out_path(token)
      expect(session[:share_token]).to be_nil
      expect(response).to redirect_to(share_path(token))
    end
  end

  describe "GET /share/:token/dashboard" do
    it "404s without a valid session" do
      get share_dashboard_path(token)
      expect(response).to have_http_status(:not_found)
    end

    it "renders with a valid session and lists the investments" do
      create(:investment, company_name: "Acme Robotics")
      post unlock_share_path(token), params: { password: password }

      get share_dashboard_path(token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Acme Robotics")
      expect(response.body).to include("Portefeuille")
    end
  end

  describe "GET /share/:token/investments/:id" do
    let!(:investment) { create(:investment, company_name: "Acme Robotics") }

    it "renders the read-only investment fiche with a valid session" do
      post unlock_share_path(token), params: { password: password }

      get share_investment_path(token, investment)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Acme Robotics")
      expect(response.body).not_to include("Modifier")
      expect(response.body).not_to include("Supprimer")
      expect(response.body).not_to include("+ Update")
    end
  end
end
