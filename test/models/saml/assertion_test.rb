# frozen_string_literal: true

require "test_helper"

module Saml
  class AssertionTest < ActiveSupport::TestCase
    def assertion_xml
      <<~XML
        <saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="_assertion123" IssueInstant="2025-01-01T12:00:00Z" Version="2.0">
          <saml:Issuer>https://idp.example.com/metadata</saml:Issuer>
          <saml:Subject>
            <saml:NameID>user@example.com</saml:NameID>
          </saml:Subject>
          <saml:Conditions NotBefore="2025-01-01T12:00:00Z" NotOnOrAfter="2025-01-01T13:00:00Z">
            <saml:AudienceRestriction>
              <saml:Audience>https://sp.example.com/metadata</saml:Audience>
            </saml:AudienceRestriction>
          </saml:Conditions>
        </saml:Assertion>
      XML
    end

    test "parse assertion" do
      node = Nokogiri::XML(assertion_xml).at_xpath("/saml:Assertion", "saml" => Namespaces::SAML)
      assertion = Assertion.parse(node)

      assert_equal "_assertion123", assertion.id
      assert_equal "2.0", assertion.version
      assert_equal "2025-01-01T12:00:00Z".to_time, assertion.issue_instant
      assert_equal "https://idp.example.com/metadata", assertion.issuer.value
      assert_equal "user@example.com", assertion.subject.user_id.value
      assert_equal [ "https://sp.example.com/metadata" ], assertion.conditions.audience_restrictions
    end

    test "build_xml" do
      issuer = NameId.new(value: "https://idp.example.com/metadata")
      subject = Subject.new(user_id: NameId.new(value: "user@example.com"))
      conditions = Conditions.new(
        not_before: "2025-01-01T12:00:00Z".to_time,
        not_on_or_after: "2025-01-01T13:00:00Z".to_time,
        audience_restrictions: [ "https://sp.example.com/metadata" ]
      )
      assertion = Assertion.new(
        id: "_assertion123",
        issue_instant: "2025-01-01T12:00:00Z".to_time,
        version: "2.0",
        issuer: issuer,
        subject: subject,
        conditions: conditions,
        statements: [],
        authn_statements: [],
        authz_decision_statements: [],
        attribute_statements: []
      )

      xml = assertion.to_xml
      document = Nokogiri::XML(xml)
      node = document.at_xpath("/saml:Assertion", "saml" => Namespaces::SAML)

      assert_not_nil node
      assert_equal "_assertion123", node["ID"]
      assert_equal "2025-01-01T12:00:00Z".to_time, node["IssueInstant"].to_time
      assert_equal "https://idp.example.com/metadata", node.at_xpath("saml:Issuer", "saml" => Namespaces::SAML).text
      assert_equal "user@example.com", node.at_xpath("saml:Subject/saml:NameID", "saml" => Namespaces::SAML).text
      assert_equal "https://sp.example.com/metadata", node.at_xpath("saml:Conditions/saml:AudienceRestriction/saml:Audience", "saml" => Namespaces::SAML).text
    end
  end
end
