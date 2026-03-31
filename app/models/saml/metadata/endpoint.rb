# frozen_string_literal: true

module Saml
  module Metadata
    class Endpoint
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml
      include LazyAttributes

      attribute :binding, :string
      lazy_attribute(:binding) { endpoint_element&.attribute("Binding")&.value }
      attribute :location, :string
      lazy_attribute(:location) { endpoint_element&.attribute("Location")&.value }
      attribute :response_location, :string
      lazy_attribute(:response_location) { endpoint_element&.attribute("ResponseLocation")&.value }

      # @param [Nokogiri::XML::Node] endpoint_element
      def self.parse(endpoint_element)
        new(endpoint_element:)
      end

      # @!attribute[r] endpoint_element
      #   @return [Nokogiri::XML::Node] the endpoint XML element
      attr_reader :endpoint_element

      # @param [Nokogiri::XML::Node] endpoint_element
      def initialize(endpoint_element: nil, **attributes)
        super(attributes)
        @endpoint_element = endpoint_element
      end

      private

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_attributes
          {
            Binding: binding,
            Location: location,
            ResponseLocation: response_location,
          }.compact
        end
    end
  end
end
