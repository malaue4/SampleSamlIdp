# frozen_string_literal: true

module Saml
  module Metadata
    # The RequestedAttribute element is used within an AttributeConsumingService
    # to define a specific SAML attribute that the Service Provider (SP) requests from an IdP.
    class RequestedAttribute < Attribute
      # @!attribute [rw] required
      #   @return [Boolean] whether the attribute is required by the service
      attribute :required, :boolean, default: false

      def self.parse(name_id_element)
        super(name_id_element) do |attributes|
          attributes[:required] = name_id_element.attribute("isRequired")&.value == "true"
        end
      end

      private

        def xml_attributes
          super.merge(isRequired: required)
        end

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end
    end
  end
end
