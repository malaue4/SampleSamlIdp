require "application_system_test_case"

describe "Sites", :system do
  let(:site) { sites(:one) }

  it "visits the index" do
    visit sites_url
    assert_selector "h1", text: "Sites"
  end

  it "creates a Site" do
    visit sites_url
    click_on "New site"

    fill_in "Host", with: @site.host
    fill_in "Saml metadata", with: @site.saml_metadata
    click_on "Create Site"

    assert_text "Site was successfully created"
    click_on "Back"
  end

  it "updates a Site" do
    visit site_url(@site)
    click_on "Edit this site", match: :first

    fill_in "Host", with: @site.host
    fill_in "Saml metadata", with: @site.saml_metadata
    click_on "Update Site"

    assert_text "Site was successfully updated"
    click_on "Back"
  end

  it "destroys a Site" do
    visit site_url(@site)
    click_on "Destroy this site", match: :first

    assert_text "Site was successfully destroyed"
  end
end
