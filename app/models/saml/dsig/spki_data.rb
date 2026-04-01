# frozen_string_literal: true

module Saml
  module Dsig
    class SPKIData
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      attribute :elements
      lazy_attribute(:elements) { parse_elements }

      def self.parse(element)
        new.tap do |instance|
          instance.instance_variable_set(:@element, element)
        end
      end

      private

        attr_reader :element

        def parse_elements
          element.xpath("*", ds: Namespaces::DS).map do |it|
            if it.name == "SPKISexp"
              { type: :spki_sexp, value: it.text }
            else
              { type: :other, xml: it.to_xml }
            end
          end
        end

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_content(builder)
          elements.each do |el|
            if el[:type] == :spki_sexp
              builder.SPKISexp el[:value]
            else
              builder << el[:xml]
            end
          end
        end
    end
  end
end
