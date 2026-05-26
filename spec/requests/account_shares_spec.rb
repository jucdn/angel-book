require "rails_helper"

RSpec.describe "AccountShares", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /account/share" do
    it "renders" do
      get account_share_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /account/share" do
    it "with a strong password creates the share and flashes the credentials once" do
      post account_share_path, params: { password: "long-enough-password" }

      user.reload
      expect(user.share_token).to be_present
      expect(flash[:share_url]).to include("/share/#{user.share_token}")
      expect(flash[:share_password]).to eq("long-enough-password")
      expect(response).to redirect_to(account_share_path)
    end

    it "with a weak password re-renders the form" do
      post account_share_path, params: { password: "short" }

      expect(user.reload.share_token).to be_nil
      expect(flash[:alert]).to match(/12 caractères/)
      expect(response).to redirect_to(account_share_path)
    end
  end

  describe "DELETE /account/share" do
    it "revokes the share" do
      user.regenerate_share!(password: "long-enough-password")
      delete account_share_path

      expect(user.reload.share_token).to be_nil
      expect(response).to redirect_to(account_share_path)
    end
  end

  context "when signed out" do
    before { sign_out user }

    it "redirects to sign in" do
      get account_share_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
