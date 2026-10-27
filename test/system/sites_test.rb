require "application_system_test_case"

class SitesTest < ApplicationSystemTestCase
  before do
    @site = sites(:one)
    visit management_site_url
    fill_in "Username", with: "one"
    fill_in "Password", with: "password"
    click_on "Sign in"
  end

  it "updates a Site" do
    visit management_site_url(@site)
    click_on "Edit", match: :first

    fill_in "Organization name", with: "@site.host"
    fill_in "Organization display name", with: "@site.saml_metadata"
    click_on "Save Settings"

    assert_text 'en: "@site.host"'
  end
end
