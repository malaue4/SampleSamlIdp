# frozen_string_literal: true

require "test_helper"

module Saml
  module Metadata
    class AttributeConsumingServiceTest < ActiveSupport::TestCase
      SAMPLE_XML = <<~XML
        <md:AttributeConsumingService index="1" isDefault="true" xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">
          <md:ServiceName xml:lang="en">Student Information Service</md:ServiceName>
          <md:ServiceName xml:lang="es">Servicio de Información Estudiantil</md:ServiceName>
          <md:ServiceDescription xml:lang="en">Service for accessing student records</md:ServiceDescription>
          <md:ServiceDescription xml:lang="es">Servicio para acceder a registros de estudiantes</md:ServiceDescription>
          <md:RequestedAttribute Name="urn:oid:2.5.4.42" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="givenName" isRequired="true"/>
          <md:RequestedAttribute Name="urn:oid:2.5.4.4" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="surname" isRequired="true"/>
          <md:RequestedAttribute Name="urn:oid:0.9.2342.19200300.100.1.3" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="mail"/>
          <md:RequestedAttribute Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.7" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="eduPersonEntitlement"/>
        </md:AttributeConsumingService>
      XML

      def test_parse
        acs = AttributeConsumingService
          .parse(Nokogiri::XML(SAMPLE_XML).at_xpath("md:AttributeConsumingService", "md" => Namespaces::MD))

        assert_equal true, acs.default
        assert_equal 1, acs.index
        assert_equal({ "en"=>"Student Information Service", "es"=>"Servicio de Información Estudiantil" }, acs.service_name)
        assert_equal({ "en"=>"Service for accessing student records", "es"=>"Servicio para acceder a registros de estudiantes" }, acs.service_description)
        assert_equal([
                       RequestedAttribute.new(
                         name: "urn:oid:2.5.4.42",
                         name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                         friendly_name: "givenName",
                         attribute_value: nil,
                         required: true,
                       ).attributes,
                       RequestedAttribute.new(
                         name: "urn:oid:2.5.4.4",
                         name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                         friendly_name: "surname",
                         attribute_value: nil,
                         required: true,
                         ).attributes,
                       RequestedAttribute.new(
                         name: "urn:oid:0.9.2342.19200300.100.1.3",
                         name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                         friendly_name: "mail",
                         attribute_value: nil,
                         required: false,
                         ).attributes,
                       RequestedAttribute.new(
                         name: "urn:oid:1.3.6.1.4.1.5923.1.1.1.7",
                         name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                         friendly_name: "eduPersonEntitlement",
                         attribute_value: nil,
                         required: false,
                         ).attributes,
                     ], acs.requested_attributes.map(&:attributes))
      end
    end
  end
end
