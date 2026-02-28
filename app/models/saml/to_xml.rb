# frozen_string_literal: true

module Saml
  module ToXml
    # @param [Nokogiri::XML::Builder] builder
    # @param [Hash] extra_attributes
    def build_xml(builder, **extra_attributes)
      if xml_namespace.present?
        namespace_href = xml_namespace[:href]
        namespace_prefix = xml_namespace[:prefix]
        namespace = builder.parent.namespaces.find do |_prefix, href|
          href == namespace_href
        end
        namespace_prefix = namespace.first.delete_prefix("xmlns:") if namespace.present?
        extra_attributes[[ "xmlns", namespace_prefix ].join(":")] ||= namespace_href if namespace.nil?
        namespace_prefix.present? ? builder[namespace_prefix] : builder
      else
        builder
      end.send(xml_element_name, **xml_attributes.merge(extra_attributes)) do |shadow_builder|
        xml_content(shadow_builder)
      end
    end

    private

      def xml_namespace
        {}
      end

      def xml_element_name
        @xml_element_name ||= self.class.name.demodulize.to_sym
      end

      def xml_attributes
        {}
      end

      # @param [Nokogiri::XML::Builder] builder
      def xml_content(builder)
      end
  end
end
