require "test_helper"

describe Management::SitesController do
  let(:site) { sites(:one) }

  it "should get index" do
    get sites_url
    must_respond_with :success
  end

  it "should get new" do
    get new_site_url
    must_respond_with :success
  end

  it "should create site" do
    assert_difference("Site.count") do
      post sites_url, params: { site: { host: @site.host, saml_metadata: @site.saml_metadata } }
    end

    must_redirect_to site_url(Site.last)
  end

  it "should show site" do
    get site_url(@site)
    must_respond_with :success
  end

  it "should get edit" do
    get edit_site_url(@site)
    must_respond_with :success
  end

  it "should update site" do
    patch site_url(@site), params: { site: { host: @site.host, saml_metadata: @site.saml_metadata } }
    must_redirect_to site_url(@site)
  end

  it "should destroy site" do
    assert_difference("Site.count", -1) do
      delete site_url(@site)
    end

    must_redirect_to sites_url
  end
end
