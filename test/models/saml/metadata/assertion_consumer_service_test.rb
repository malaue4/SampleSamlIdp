require "test_helper"

module Saml
  module Metadata
    class AssertionConsumerServiceTest < ActiveSupport::TestCase

      test "parse" do
        node = Nokogiri::XML(<<XML).at_xpath("//md:AssertionConsumerService", "md" => Namespaces::MD)
<md:AssertionConsumerService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://localhost:3000/saml/auth" index="0"/>
XML
        acs = AssertionConsumerService.parse(node)

        assert_equal({
                       "binding"=>"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
                       "location"=>"https://localhost:3000/saml/auth",
                       "response_location"=>nil,
                       "index"=>0,
                       "default"=>false
                     }, acs.as_json)
      end
    end
  end
end
