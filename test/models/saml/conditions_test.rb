# frozen_string_literal: true

require "test_helper"

module Saml
  class ConditionsTest < ActiveSupport::TestCase
    def conditions_xml
      <<~XML
        <saml:Conditions xmlns:saml="#{Namespaces::SAML}" NotBefore="2025-01-01T12:00:00Z" NotOnOrAfter="2025-01-01T13:00:00Z">
          <saml:AudienceRestriction>
            <saml:Audience>https://sp.example.com/metadata</saml:Audience>
          </saml:AudienceRestriction>
          <saml:OneTimeUse/>
        </saml:Conditions>
      XML
    end

    test "parse conditions" do
      node = Nokogiri::XML(conditions_xml).at_xpath("/saml:Conditions", "saml" => Namespaces::SAML)
      conditions = Conditions.parse(node)

      assert_equal "2025-01-01T12:00:00Z".to_time, conditions.not_before
      assert_equal "2025-01-01T13:00:00Z".to_time, conditions.not_on_or_after
      assert_equal ["https://sp.example.com/metadata"], conditions.audience_restrictions
      assert conditions.one_time_use
    end

    test "build_xml" do
      conditions = Conditions.new(
        not_before: "2025-01-01T12:00:00Z",
        not_on_or_after: "2025-01-01T13:00:00Z",
        audience_restrictions: ["https://sp.example.com/metadata"],
        one_time_use: true
      )

      xml = conditions.to_xml
      document = Nokogiri::XML(xml)
      node = document.at_xpath("/saml:Conditions", "saml" => Namespaces::SAML)

      assert_not_nil node
      assert_equal "2025-01-01T12:00:00Z", node.attribute("NotBefore").value
      assert_equal "2025-01-01T13:00:00Z", node.attribute("NotOnOrAfter").value
      assert_equal "https://sp.example.com/metadata", node.at_xpath("saml:AudienceRestriction/saml:Audience", "saml" => Namespaces::SAML).text
      assert_not_nil node.at_xpath("saml:OneTimeUse", "saml" => Namespaces::SAML)
    end
  end
end
