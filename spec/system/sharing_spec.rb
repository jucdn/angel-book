require "rails_helper"

RSpec.describe "Sharing a read-only portfolio", type: :system do
  let(:owner) { create(:user) }
  let!(:investment) { create(:investment, company_name: "Acme Robotics") }

  it "owner generates a link, recipient unlocks and browses without write affordances" do
    sign_in owner
    visit account_share_path

    fill_in "password", with: "long-enough-password"
    click_button "Générer le lien"

    expect(page).to have_content("Copie ces informations maintenant")
    share_url_value = find("input[value^='http']", match: :first).value

    sign_out owner
    visit share_url_value

    expect(page).to have_content("Vue partagée")

    fill_in "password", with: "long-enough-password"
    click_button "Déverrouiller"

    expect(page).to have_content("Portefeuille")
    expect(page).to have_content("Acme Robotics")
    expect(page).not_to have_link("+ Nouvel investissement")

    # Investments-table rows use onclick=window.location, so click the row directly
    find("tr", text: "Acme Robotics").click

    expect(page).to have_content(/données d'entrée/i)
    expect(page).not_to have_link("Modifier")
    expect(page).not_to have_button("Supprimer")
    expect(page).not_to have_link("+ Update")
    expect(page).not_to have_link("Enregistrer une sortie")
  end

  it "wrong password keeps the recipient out" do
    owner.regenerate_share!(password: "long-enough-password")
    visit share_path(owner.share_token)

    fill_in "password", with: "wrong"
    click_button "Déverrouiller"

    expect(page).to have_content("Mot de passe invalide")
    expect(page).not_to have_content("Capital investi")
  end

  it "revoking the share invalidates the URL" do
    owner.regenerate_share!(password: "long-enough-password")
    bad_token = owner.share_token

    owner.revoke_share!
    visit share_path(bad_token)

    # Headless Chrome doesn't expose status_code; assert the password gate is gone instead
    expect(page).not_to have_field("password")
    expect(page).not_to have_content("Vue partagée")
  end
end
