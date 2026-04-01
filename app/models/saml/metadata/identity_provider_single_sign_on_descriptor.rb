# frozen_string_literal: true

module Saml
  module Metadata
    class IdentityProviderSingleSignOnDescriptor < SingleSignOnDescriptor
      attribute :want_authn_requests_signed, :boolean
      lazy_attribute(:want_authn_requests_signed) { role_descriptor_element&.attribute("WantAuthnRequestsSigned")&.value == "true" }

      attr_accessor :single_sign_on_services, :name_id_mapping_services, :assertion_id_request_services, :attribute_profiles, :saml_attributes

      def single_sign_on_services
        @single_sign_on_services ||= role_descriptor_element
          &.xpath("md:SingleSignOnService", "md" => Namespaces::MD)
          &.map do |service|
          SingleSignOnService.parse(service)
        end || []
      end

      def name_id_mapping_services
        @name_id_mapping_services ||= role_descriptor_element
          &.xpath("md:NameIDMappingService", "md" => Namespaces::MD)
          &.map do |service|
          NameIdMappingService.parse(service)
        end || []
      end

      def assertion_id_request_services
        @assertion_id_request_services ||= role_descriptor_element
          &.xpath("md:AssertionIDRequestService", "md" => Namespaces::MD)
          &.map do |service|
          AssertionIdRequestService.parse(service)
        end || []
      end

      def attribute_profiles
        @attribute_profiles ||= role_descriptor_element
          &.xpath("md:AttributeProfile", "md" => Namespaces::MD)
          &.map do |profile|
          profile.text
        end || []
      end

      def saml_attributes
        @saml_attributes ||= role_descriptor_element
          &.xpath("saml:Attribute", "saml" => Namespaces::SAML)
          &.map do |attribute|
          Attribute.parse(attribute)
        end || []
      end

      private

        def xml_attributes
          super.merge!(
            WantAuthnRequestsSigned: want_authn_requests_signed,
          ).compact
        end

        def xml_content(builder)
          super
          single_sign_on_services&.each { |s| s.build_xml(builder) }
          name_id_mapping_services&.each { |s| s.build_xml(builder) }
          assertion_id_request_services&.each { |s| s.build_xml(builder) }
          attribute_profiles&.each { |p| builder[:md].AttributeProfile p }
          saml_attributes&.each { |a| a.build_xml(builder) }
        end
    end
  end
end
