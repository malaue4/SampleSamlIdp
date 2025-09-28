# frozen_string_literal: true

module Saml
  module Metadata
    class SPSSODescriptor < SSODescriptor


      def authn_requests_signed?
        @authn_requests_signed ||= role_descriptor_element.attribute("AuthnRequestsSigned")&.value == "true"
      end

      def want_assertions_signed?
        @want_assertions_signed ||= role_descriptor_element.attribute("WantAssertionsSigned")&.value == "true"
      end

      def assertion_consumer_services
        @assertion_consumer_services ||= role_descriptor_element
          .xpath("md:AssertionConsumerService", "md" => Namespaces::MD)
          .map do |service|
          AssertionConsumerService.parse(service)
        end
      end

      def attribute_consuming_services
        @attribute_consuming_services ||= role_descriptor_element
          .xpath("md:AttributeConsumingService", "md" => Namespaces::MD)
          .map do |service|
          AttributeConsumingService.parse(service)
        end
      end
    end
  end
end
