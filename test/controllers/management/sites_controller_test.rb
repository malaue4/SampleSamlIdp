require "test_helper"

describe Management::SitesController do
  let(:site) { sites(:one) }

  before { sign_in_as(users(:one)) }

  it "should show site" do
    get management_site_url
    must_respond_with :success
  end

  it "should get edit" do
    get edit_management_site_url
    must_respond_with :success
  end

  it "should update site" do
    patch management_site_url, params: { site: { entity_id: "https://site.host" } }
    must_redirect_to management_site_url
  end
end
