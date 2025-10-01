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

      def test_build_xml
        acs = AttributeConsumingService.new(
          service_name: { en: "Razor Lanes" },
          requested_attributes: [
            RequestedAttribute.new(
              name: "urn:oid:0.9.2342.19200300.100.1.3",
              friendly_name: "mail",
              attribute_value: "test@localhost"
            )
          ]
        )
        assert_equal("test@localhost", acs.requested_attributes[0].attribute_value)
        doc = Nokogiri::XML::Builder.new do |builder|
          acs.build_xml(builder, "xmlns:md" => Namespaces::MD, "xmlns:saml" => Namespaces::SAML)
        end

        assert_equal(<<~XML, doc.to_xml)
          <?xml version="1.0"?>
          <md:AttributeConsumingService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" index="1" isDefault="false">
            <md:ServiceName xml:lang="en">Razor Lanes</md:ServiceName>
            <md:RequestedAttribute Name="urn:oid:0.9.2342.19200300.100.1.3" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="mail" isRequired="false">
              <saml:AttributeValue>test@localhost</saml:AttributeValue>
            </md:RequestedAttribute>
          </md:AttributeConsumingService>
        XML
      end
    end
  end
end
