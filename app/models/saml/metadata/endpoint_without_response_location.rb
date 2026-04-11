# frozen_string_literal: true

module Saml
  module Metadata
    # Base class for SAML metadata endpoints that do not include a ResponseLocation attribute.
    class EndpointWithoutResponseLocation
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml
      include LazyAttributes

      # @!attribute [rw] binding
      #   @return [String] the URI reference identifying the SAML binding used by the endpoint
      attribute :binding, :string
      lazy_attribute(:binding) { endpoint_element&.attribute("Binding")&.value }
      # @!attribute [rw] location
      #   @return [String] the URI reference identifying the location of the endpoint
      attribute :location, :string
      lazy_attribute(:location) { endpoint_element&.attribute("Location")&.value }

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
            Location: location
          }.compact
        end
    end
  end
end
