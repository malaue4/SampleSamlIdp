# frozen_string_literal: true

module Saml
  module Metadata
    # The AttributeConsumingService element describes the set of SAML attributes
    # requested by a Service Provider (SP) for a particular service. It allows an IdP
    # to understand what user data the SP requires for its operation.
    class AttributeConsumingService
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml

      # @!attribute [rw] service_name
      #   @return [Hash<String, String>] the service names for various languages
      attribute :service_name
      # @!attribute [rw] service_description
      #   @return [Hash<String, String>] the service descriptions for various languages
      attribute :service_description
      # @!attribute [rw] requested_attributes
      #   @return [Array<Saml::Metadata::RequestedAttribute>] the requested attributes
      attribute :requested_attributes
      # @!attribute [rw] index
      #   @return [Integer] the unique index for the service
      attribute :index, :integer, default: 1
      # @!attribute [rw] default
      #   @return [Boolean] whether the service is the default one
      attribute :default, :boolean, default: false


      # @param [Nokogiri::XML::Node] attribute_consuming_service_element
      def self.parse(attribute_consuming_service_element)
        new(
          service_name: attribute_consuming_service_element
            .xpath("md:ServiceName", "md" => Namespaces::MD)
            .to_h { |sn| [ sn.attribute_with_ns("lang", Namespaces::XML)&.value, sn.text ] },
          service_description: attribute_consuming_service_element
            .xpath("md:ServiceDescription", "md" => Namespaces::MD)
            .to_h { |sn| [ sn.attribute_with_ns("lang", Namespaces::XML)&.value, sn.text ] },
          requested_attributes: attribute_consuming_service_element
            .xpath("md:RequestedAttribute", "md" => Namespaces::MD)
            .map { |rae| RequestedAttribute.parse(rae) },
          index: attribute_consuming_service_element.attribute("index")&.value.to_i,
          default: attribute_consuming_service_element.attribute("isDefault")&.value == "true"
        )
      end

      private

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_attributes
          { index:, isDefault: default }
        end

        def xml_content(builder)
          service_name&.each do |lang, value|
            builder.ServiceName("xml:lang" => lang) { builder.text(value) }
          end
          service_description&.each do |lang, value|
            builder.ServiceDescription("xml:lang" => lang) { builder.text(value) }
          end
          requested_attributes&.each { |requested_attribute| requested_attribute.build_xml(builder) }
        end
    end
  end
end
