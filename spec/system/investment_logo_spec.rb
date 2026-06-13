require "rails_helper"

RSpec.describe "Investment logo", type: :system do
  before { sign_in create(:user) }

  it "uploads a logo and shows it on the show page" do
    investment = create(:investment, company_name: "Logo Co")

    visit edit_investment_path(investment)
    attach_file "Logo", Rails.root.join("spec/fixtures/files/logo.png")
    click_button "Enregistrer"

    expect(page).to have_content("Investissement mis à jour")
    expect(page).to have_css("img[src*='logo']")
  end

  it "removes an existing logo" do
    investment = create(:investment, company_name: "Logo Co")
    investment.logo.attach(
      io: Rails.root.join("spec/fixtures/files/logo.png").open,
      filename: "logo.png",
      content_type: "image/png"
    )

    visit edit_investment_path(investment)
    check "Supprimer le logo"
    click_button "Enregistrer"

    expect(page).to have_content("Investissement mis à jour")
    expect(investment.reload.logo).not_to be_attached
  end
end
