# frozen_string_literal: true

require "test_helper"

module Saml
  class NameIdTest < ActiveSupport::TestCase

    SAMPLE_XML = <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <saml:NameID Format="bad" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
        https://disaster.area/please/clear
      </saml:NameID>
    XML

    def setup
      element = Nokogiri::XML(SAMPLE_XML).at_xpath("saml:NameID", "saml" => Namespaces::SAML)
      assert element, "Could not find NameID element"
      @name_id = NameId.parse(element)
    end

    def test_parse
      assert_equal "https://disaster.area/please/clear", @name_id.value
      assert_equal "bad", @name_id.format
    end

    def test_as_json
      assert_equal({
                     "attributes"=>{
                       "value"=>"https://disaster.area/please/clear",
                       "format"=>"bad",
                       "sp_provided_id"=>nil,
                       "name_qualifier"=>nil,
                       "sp_name_qualifier"=>nil
                     }
                   }, @name_id.as_json)
    end

    def test_to_xml
      builder = Nokogiri::XML::Builder.new(encoding: "utf-8") do |xml|
        @name_id.build_xml(xml, "xmlns:saml" => Namespaces::SAML)
      end
      assert_equal <<~XML, builder.to_xml
        <?xml version="1.0" encoding="utf-8"?>
        <saml:NameID xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Format="bad">https://disaster.area/please/clear</saml:NameID>
      XML
    end
  end
end
