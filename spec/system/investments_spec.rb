require "rails_helper"

RSpec.describe "Investments", type: :system do
  describe "creating an investment" do
    it "saves and redirects to the show page" do
      visit new_investment_path

      fill_in "Nom de la société", with: "Acme Corp"
      fill_in "Ticket investi (€)", with: "30000"
      fill_in "Date d'investissement", with: "2024-01-15"
      select "Saas b2b", from: "Secteur"
      select "Seed", from: "Stade"

      click_button "Créer l'investissement"

      expect(page).to have_content("Acme Corp")
      expect(page).to have_content("Investissement créé")
    end

    it "shows validation errors when required fields are missing" do
      visit new_investment_path
      click_button "Créer l'investissement"

      expect(page).to have_content("can't be blank").or have_content("doit être rempli").or have_content("is not a number")
    end
  end

  describe "listing investments" do
    let!(:inv_a) { create(:investment, company_name: "Alpha", sector: "fintech", status: "active") }
    let!(:inv_b) { create(:investment, company_name: "Beta", sector: "health", status: "exited") }

    it "shows all investments by default" do
      visit investments_path
      expect(page).to have_content("Alpha")
      expect(page).to have_content("Beta")
    end

    it "filters by status" do
      visit investments_path
      select "Actifs", from: "status"
      click_button "Filtrer"

      expect(page).to have_content("Alpha")
      expect(page).not_to have_content("Beta")
    end

    it "filters by sector" do
      visit investments_path
      select "Fintech", from: "sector"
      click_button "Filtrer"

      expect(page).to have_content("Alpha")
      expect(page).not_to have_content("Beta")
    end
  end

  describe "editing an investment" do
    let!(:investment) { create(:investment, company_name: "OldName") }

    it "updates the investment" do
      visit edit_investment_path(investment)
      fill_in "Nom de la société", with: "NewName"
      click_button "Enregistrer"

      expect(page).to have_content("NewName")
      expect(page).to have_content("Investissement mis à jour")
    end
  end

  describe "deleting an investment" do
    let!(:investment) { create(:investment, company_name: "ToDelete") }

    it "removes the investment and redirects to list" do
      visit investment_path(investment)
      # Override window.confirm so Turbo's confirmation dialog auto-accepts
      page.evaluate_script("window.confirm = function() { return true; }")
      click_button "Supprimer"

      expect(page).to have_current_path(investments_path)
      expect(page).not_to have_content("ToDelete")
    end
  end
end
