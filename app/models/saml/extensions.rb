# frozen_string_literal: true

module Saml
  class Extensions
    include ActiveModel::Model
    include ActiveModel::Attributes
    include LazyAttributes
    include ToXml

    attribute :content

    def self.parse(extensions_element)
      new(content: extensions_element.children.to_xml)
    end

    private

      def xml_namespace
        { href: Namespaces::SAMLP, prefix: "samlp" }
      end

      def xml_content(builder)
        builder << content if content
      end
  end
end
