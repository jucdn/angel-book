require "rails_helper"

RSpec.describe "Snapshots", type: :system do
  before { sign_in create(:user) }

  let!(:investment) { create(:investment, company_name: "Startup Z", invested_amount: 50_000) }

  describe "adding a snapshot inline" do
    it "shows the form inline and saves" do
      visit investment_path(investment)

      expect(page).to have_content("Aucune donnée")
      click_link "+ Update"

      expect(page).to have_field("snapshot[snapshot_date]")
      expect(page).to have_field("snapshot[current_valuation]")

      fill_in "snapshot[snapshot_date]",     with: Date.today.to_s
      fill_in "snapshot[current_valuation]", with: "120000"
      fill_in "snapshot[mrr]",               with: "15000"
      fill_in "snapshot[runway_months]",     with: "18"

      click_button "Enregistrer"

      expect(page).to have_content("Mise à jour enregistrée")
      expect(page).to have_content("18 mois")
    end

    it "shows runway alert when runway < 6 months" do
      visit investment_path(investment)
      click_link "+ Update"

      fill_in "snapshot[snapshot_date]", with: Date.today.to_s
      fill_in "snapshot[runway_months]", with: "4"

      click_button "Enregistrer"

      expect(page).to have_content("⚠")
      expect(page).to have_content("4 mois")
    end
  end
end
