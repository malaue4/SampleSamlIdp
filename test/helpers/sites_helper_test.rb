require "test_helper"

class SitesHelperTest < ActionView::TestCase
  include SitesHelper

  def setup
    @cert = OpenSSL::X509::Certificate.new
    @cert.version = 2
    @cert.serial = 1
    @cert.subject = OpenSSL::X509::Name.parse "/DC=org/DC=example/CN=Test Cert"
    @cert.issuer = @cert.subject
    @cert.public_key = OpenSSL::PKey::RSA.new(2048).public_key
    @cert.not_before = Time.now - 1.day
    @cert.not_after = Time.now + 1.year
    @cert.sign(OpenSSL::PKey::RSA.new(2048), OpenSSL::Digest.new("SHA256"))
    @pem = @cert.to_pem
  end

  test "saml_certificate_info returns correct metadata" do
    info = saml_certificate_info(@pem)
    assert_equal "Test Cert", info[:subject]
    assert_equal @cert.not_after.to_i, info[:not_after].to_i
    assert_match /^([0-9A-F]{2}:){31}[0-9A-F]{2}$/, info[:fingerprint]
    assert_equal @pem, info[:raw]
    assert_equal :valid, info[:status]
  end

  test "certificate_status returns correct status" do
    assert_equal :expired, certificate_status(Time.now - 1.day)
    assert_equal :expiring_soon, certificate_status(Time.now + 15.days)
    assert_equal :valid, certificate_status(Time.now + 45.days)
  end

  test "status_badge_class returns correct class" do
    assert_equal "text-bg-danger", status_badge_class(:expired)
    assert_equal "text-bg-warning", status_badge_class(:expiring_soon)
    assert_equal "text-bg-success", status_badge_class(:valid)
  end
end
