# frozen_string_literal: true

require "test_helper"

module Saml
  class AttributeTest < ActiveSupport::TestCase

    NO_VALUE_EXAMPLE = <<~XML
      <saml:Attribute Name="isAdmin" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
      </saml:Attribute>
    XML

    SINGLE_VALUE_TYPED_EXAMPLE = <<~XML
      <saml:Attribute Name="isDefault" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
        <saml:AttributeValue xsi:type="xs:boolean">true</saml:AttributeValue>
      </saml:Attribute>
    XML

    SINGLE_VALUE_UNTYPED_EXAMPLE = <<~XML
      <saml:Attribute Name="isDefault" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
        <saml:AttributeValue>true</saml:AttributeValue>
      </saml:Attribute>
    XML

    test "no value" do
      node = Nokogiri::XML(NO_VALUE_EXAMPLE).at_xpath("/saml:Attribute", "saml" => Namespaces::SAML)
      attr = Attribute.parse(node)
      assert_equal({
                     "name"=>"isAdmin",
                     "name_format"=>nil,
                     "friendly_name"=>nil,
                     "attribute_value"=>nil
                   }, attr.as_json)
    end

    test "single value with type" do
      node = Nokogiri::XML(SINGLE_VALUE_TYPED_EXAMPLE).at_xpath("/saml:Attribute", "saml" => Namespaces::SAML)
      attr = Attribute.parse(node)
      assert_equal({
                     "name"=>"isDefault",
                     "name_format"=>nil,
                     "friendly_name"=>nil,
                     "attribute_value"=>true
                   }, attr.as_json)
    end

    test "single value without type" do
      node = Nokogiri::XML(SINGLE_VALUE_UNTYPED_EXAMPLE).at_xpath("/saml:Attribute", "saml" => Namespaces::SAML)
      attr = Attribute.parse(node)
      assert_equal({
                     "name"=>"isDefault",
                     "name_format"=>nil,
                     "friendly_name"=>nil,
                     "attribute_value"=>"true"
                   }, attr.as_json)
    end
  end
end
