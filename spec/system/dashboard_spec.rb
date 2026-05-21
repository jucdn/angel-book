require "rails_helper"

RSpec.describe "Dashboard", type: :system do
  context "with investments and snapshots" do
    before do
      inv1 = create(:investment, invested_amount: 50_000, status: "active", sector: "fintech")
      create(:snapshot, investment: inv1, snapshot_date: Date.today, current_valuation: 100_000, runway_months: 18)

      inv2 = create(:investment, invested_amount: 30_000, status: "exited", sector: "health")
      create(:snapshot, investment: inv2, snapshot_date: Date.today, current_valuation: 60_000)

      create(:investment, invested_amount: 20_000, status: "written_off", sector: "fintech")
    end

    it "displays the KPI cards" do
      visit root_path

      expect(page).to have_content("Capital investi")
      expect(page).to have_content("Valeur estimée")
      expect(page).to have_content("Multiple")
    end

    it "shows runway alert section when an active investment has runway < 6 months" do
      inv_alert = create(:investment, invested_amount: 10_000, status: "active")
      create(:snapshot, investment: inv_alert, snapshot_date: Date.today, runway_months: 3)

      visit root_path

      expect(page).to have_content("Alertes runway")
    end
  end

  context "with no investments" do
    it "shows the empty state" do
      visit root_path
      expect(page).to have_content("Aucun investissement")
    end
  end
end
