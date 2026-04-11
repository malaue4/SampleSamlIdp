require "test_helper"

module Saml
  module Metadata
    class AssertionConsumerServiceTest < ActiveSupport::TestCase
      test "parse" do
        node = Nokogiri::XML(<<XML).at_xpath("//md:AssertionConsumerService", "md" => Namespaces::MD)
<md:AssertionConsumerService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://localhost:3000/saml/auth" index="0"/>
XML
        acs = AssertionConsumerService.parse(node)

        assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", acs.binding
        assert_equal "https://localhost:3000/saml/auth", acs.location
        assert_equal 0, acs.index
        assert_equal false, acs.default
      end
    end
  end
end
