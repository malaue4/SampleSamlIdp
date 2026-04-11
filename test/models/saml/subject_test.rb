# frozen_string_literal: true

require "test_helper"

module Saml
  class SubjectTest < ActiveSupport::TestCase
    def subject_xml
      <<~XML
        <saml:Subject xmlns:saml="#{Namespaces::SAML}">
          <saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">user@example.com</saml:NameID>
          <saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
            <saml:SubjectConfirmationData NotOnOrAfter="2025-01-01T13:00:00Z" Recipient="https://sp.example.com/acs"/>
          </saml:SubjectConfirmation>
        </saml:Subject>
      XML
    end

    test "parse subject" do
      node = Nokogiri::XML(subject_xml).at_xpath("/saml:Subject", "saml" => Namespaces::SAML)
      subject = Subject.parse(node)

      assert_kind_of NameId, subject.user_id
      assert_equal "user@example.com", subject.user_id.value
      assert_equal "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress", subject.user_id.format

      assert_equal 1, subject.subject_confirmations.size
      confirmation = subject.subject_confirmations.first
      assert_equal "urn:oasis:names:tc:SAML:2.0:cm:bearer", confirmation.method
      assert_not_nil confirmation.subject_confirmation_data
      assert_equal "https://sp.example.com/acs", confirmation.subject_confirmation_data.recipient
    end

    test "build_xml" do
      name_id = NameId.new(value: "user@example.com", format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress")
      data = SubjectConfirmation::Data.new(recipient: "https://sp.example.com/acs", not_on_or_after: "2025-01-01T13:00:00Z".to_time)
      confirmation = SubjectConfirmation.new(method: "urn:oasis:names:tc:SAML:2.0:cm:bearer", subject_confirmation_data: data)
      subject = Subject.new(user_id: name_id, subject_confirmations: [ confirmation ])

      xml = subject.to_xml
      document = Nokogiri::XML(xml)
      node = document.at_xpath("/saml:Subject", "saml" => Namespaces::SAML)

      assert_not_nil node
      assert_equal "user@example.com", node.at_xpath("saml:NameID", "saml" => Namespaces::SAML).text
      assert_equal "urn:oasis:names:tc:SAML:2.0:cm:bearer", node.at_xpath("saml:SubjectConfirmation", "saml" => Namespaces::SAML)["Method"]
      assert_equal "https://sp.example.com/acs", node.at_xpath("saml:SubjectConfirmation/saml:SubjectConfirmationData", "saml" => Namespaces::SAML)["Recipient"]
    end
  end
end
