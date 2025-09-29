# frozen_string_literal: true

module Saml
  module Metadata
    class AttributeConsumingService
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml


      attribute :service_name
      attribute :service_description
      attribute :requested_attributes
      attribute :index, :integer, default: 1
      attribute :default, :boolean, default: false


      # @param [Nokogiri::XML::Node] attribute_consuming_service_element
      def self.parse(attribute_consuming_service_element)
        new(
          service_name: attribute_consuming_service_element
            .xpath("md:ServiceName", "md" => Namespaces::MD)
            .to_h { |sn| [sn.attribute_with_ns("lang", Namespaces::XML)&.value, sn.text] },
          service_description: attribute_consuming_service_element
            .xpath("md:ServiceDescription", "md" => Namespaces::MD)
            .to_h { |sn| [sn.attribute_with_ns("lang", Namespaces::XML)&.value, sn.text] },
          requested_attributes: attribute_consuming_service_element
            .xpath("md:RequestedAttribute", "md" => Namespaces::MD)
            .map { |rae| RequestedAttribute.parse(rae) },
          index: attribute_consuming_service_element.attribute("index")&.value.to_i,
          default: attribute_consuming_service_element.attribute("isDefault")&.value == "true"
        )
      end

      private

        def xml_namespace
          "md"
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
