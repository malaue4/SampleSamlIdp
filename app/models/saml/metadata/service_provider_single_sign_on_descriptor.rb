# frozen_string_literal: true

module Saml
  module Metadata
    class ServiceProviderSingleSignOnDescriptor < SingleSignOnDescriptor
      attribute :authn_requests_signed, :boolean
      lazy_attribute(:authn_requests_signed) { role_descriptor_element&.attribute("AuthnRequestsSigned")&.value == "true" }
      attribute :want_assertions_signed, :boolean
      lazy_attribute(:want_assertions_signed) { role_descriptor_element&.attribute("WantAssertionsSigned")&.value == "true" }

      attr_accessor :assertion_consumer_services, :attribute_consuming_services

      # @return [Array<Saml::Metadata::AssertionConsumerService>]
      def assertion_consumer_services
        @assertion_consumer_services ||= role_descriptor_element
          &.xpath("md:AssertionConsumerService", "md" => Namespaces::MD)
          &.map do |service|
          AssertionConsumerService.parse(service)
        end || []
      end

      def attribute_consuming_services
        @attribute_consuming_services ||= role_descriptor_element
          &.xpath("md:AttributeConsumingService", "md" => Namespaces::MD)
          &.map do |service|
          AttributeConsumingService.parse(service)
        end || []
      end

      private

        def xml_attributes
          super.merge!(
            AuthnRequestsSigned: authn_requests_signed,
            WantAssertionsSigned: want_assertions_signed,
          ).compact
        end

        def xml_content(builder)
          super
          assertion_consumer_services&.each { |s| s.build_xml(builder) }
          attribute_consuming_services&.each { |s| s.build_xml(builder) }
        end
    end
  end
end
