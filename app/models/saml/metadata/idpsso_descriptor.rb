# frozen_string_literal: true

module Saml
  module Metadata
    class IDPSSODescriptor < SSODescriptor


      def want_authn_requests_signed?
        @want_authn_requests_signed ||= role_descriptor_element.attribute("WantAuthnRequestsSigned")&.value == "true"
      end

      def single_sign_on_services
        @single_sign_on_services ||= role_descriptor_element
          .xpath("md:SingleSignOnService", "md" => Namespaces::MD)
          .map do |service|
          SingleSignOnService.parse(service)
        end
      end

      def name_id_mapping_services
        @name_id_mapping_services ||= role_descriptor_element
          .xpath("md:NameIDMappingService", "md" => Namespaces::MD)
          .map do |service|
          NameIdMappingService.parse(service)
        end
      end

      def assertion_id_request_services
        @assertion_id_request_services ||= role_descriptor_element
          .xpath("md:AssertionIDRequestService", "md" => Namespaces::MD)
          .map do |service|
          AssertionIdRequestService.parse(service)
        end
      end

      def attribute_profiles
        @attribute_profiles ||= role_descriptor_element
          .xpath("md:AttributeProfile", "md" => Namespaces::MD)
          .map do |profile|
          profile.text
        end
      end

      def attributes
        @attributes ||= role_descriptor_element
          .xpath("saml:Attribute", "saml" => Namespaces::SAML)
          .map do |attribute|
          Attribute.parse(attribute)
        end
      end
    end
  end
end
