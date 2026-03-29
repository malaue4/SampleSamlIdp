# frozen_string_literal: true

require "test_helper"

module Saml
  class StatusTest < ActiveSupport::TestCase
    SUCCESS_STATUS_XML = <<~XML
      <samlp:Status xmlns:samlp="#{Namespaces::SAMLP}">
        <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
      </samlp:Status>
    XML

    STATUS_WITH_MESSAGE_XML = <<~XML
      <samlp:Status xmlns:samlp="#{Namespaces::SAMLP}">
        <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Responder"/>
        <samlp:StatusMessage>Something went wrong!</samlp:StatusMessage>
      </samlp:Status>
    XML

    NESTED_STATUS_CODE_XML = <<~XML
      <samlp:Status xmlns:samlp="#{Namespaces::SAMLP}">
        <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Responder">
          <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:AuthnFailed"/>
        </samlp:StatusCode>
      </samlp:Status>
    XML

    test "parse success status" do
      node = Nokogiri::XML(SUCCESS_STATUS_XML).at_xpath("/samlp:Status", "samlp" => Namespaces::SAMLP)
      status = Status.parse(node)
      assert_equal "urn:oasis:names:tc:SAML:2.0:status:Success", status.status_code.value
      assert_nil status.status_message
    end

    test "parse status with message" do
      node = Nokogiri::XML(STATUS_WITH_MESSAGE_XML).at_xpath("/samlp:Status", "samlp" => Namespaces::SAMLP)
      status = Status.parse(node)
      assert_equal "urn:oasis:names:tc:SAML:2.0:status:Responder", status.status_code.value
      assert_equal "Something went wrong!", status.status_message
    end

    test "parse nested status code" do
      node = Nokogiri::XML(NESTED_STATUS_CODE_XML).at_xpath("/samlp:Status", "samlp" => Namespaces::SAMLP)
      status = Status.parse(node)
      assert_equal "urn:oasis:names:tc:SAML:2.0:status:Responder", status.status_code.value
      assert_not_nil status.status_code.status_code
      assert_equal "urn:oasis:names:tc:SAML:2.0:status:AuthnFailed", status.status_code.status_code.value
    end

    test "build_xml" do
      status_code = StatusCode.new(value: "urn:oasis:names:tc:SAML:2.0:status:Success")
      status = Status.new(status_code: status_code, status_message: "OK")

      builder = Nokogiri::XML::Builder.new
      status.build_xml(builder)

      xml = builder.to_xml

      assert_equal <<~XML, xml
        <?xml version="1.0"?>
        <samlp:Status xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol">
          <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
          <samlp:StatusMessage>OK</samlp:StatusMessage>
        </samlp:Status>
      XML
    end
  end
end
