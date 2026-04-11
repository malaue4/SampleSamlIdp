# frozen_string_literal: true

module Saml
  module Metadata
    class Organization
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml

      attribute :name
      attribute :display_name
      attribute :url

      # @param [Nokogiri::XML::Node] organization_node
      def self.parse(organization_node)
        to_local_string = ->(nodes) { nodes.to_h { |node| [ node.attribute_with_ns("lang", Namespaces::XML)&.value, node.text ] } }
        new(
          name: to_local_string.(organization_node.xpath("md:OrganizationName", "md" => Namespaces::MD)),
          display_name: to_local_string.(organization_node.xpath("md:OrganizationDisplayName", "md" => Namespaces::MD)),
          url: to_local_string.(organization_node.xpath("md:OrganizationURL", "md" => Namespaces::MD))
        )
      end

      private

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_content(builder)
          name&.each do |locale, value|
            builder.OrganizationName(value, "xml:lang" => locale)
          end
          display_name&.each do |locale, value|
            builder.OrganizationDisplayName(value, "xml:lang" => locale)
          end
          url&.each do |locale, value|
            builder.OrganizationURL(value, "xml:lang" => locale)
          end
        end
    end
  end
end
