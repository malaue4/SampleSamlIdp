# frozen_string_literal: true

module Saml
  module Dsig
    class KeyValue
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      attribute :dsa_key_value
      lazy_attribute(:dsa_key_value) { parse_dsa_key_value }
      attribute :rsa_key_value
      lazy_attribute(:rsa_key_value) { parse_rsa_key_value }
      attribute :other_elements
      lazy_attribute(:other_elements) { parse_other_elements }

      def self.parse(element)
        new.tap do |instance|
          instance.instance_variable_set(:@element, element)
        end
      end

      private

        attr_reader :element

        def parse_dsa_key_value
          el = element.at_xpath("ds:DSAKeyValue", ds: Namespaces::DS)
          return nil unless el

          {
            p: el.at_xpath("ds:P", ds: Namespaces::DS)&.text,
            q: el.at_xpath("ds:Q", ds: Namespaces::DS)&.text,
            g: el.at_xpath("ds:G", ds: Namespaces::DS)&.text,
            y: el.at_xpath("ds:Y", ds: Namespaces::DS)&.text,
            j: el.at_xpath("ds:J", ds: Namespaces::DS)&.text,
            seed: el.at_xpath("ds:Seed", ds: Namespaces::DS)&.text,
            pgen_counter: el.at_xpath("ds:PgenCounter", ds: Namespaces::DS)&.text
          }.compact
        end

        def parse_rsa_key_value
          el = element.at_xpath("ds:RSAKeyValue", ds: Namespaces::DS)
          return nil unless el

          {
            modulus: el.at_xpath("ds:Modulus", ds: Namespaces::DS)&.text,
            exponent: el.at_xpath("ds:Exponent", ds: Namespaces::DS)&.text
          }.compact
        end

        def parse_other_elements
          element.xpath("*[not(self::ds:DSAKeyValue or self::ds:RSAKeyValue)]", ds: Namespaces::DS)
        end

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_content(builder)
          if dsa_key_value.present?
            builder.DSAKeyValue do |dsa|
              dsa.P dsa_key_value[:p] if dsa_key_value[:p]
              dsa.Q dsa_key_value[:q] if dsa_key_value[:q]
              dsa.G dsa_key_value[:g] if dsa_key_value[:g]
              dsa.Y dsa_key_value[:y] if dsa_key_value[:y]
              dsa.J dsa_key_value[:j] if dsa_key_value[:j]
              dsa.Seed dsa_key_value[:seed] if dsa_key_value[:seed]
              dsa.PgenCounter dsa_key_value[:pgen_counter] if dsa_key_value[:pgen_counter]
            end
          end

          if rsa_key_value.present?
            builder.RSAKeyValue do |rsa|
              rsa.Modulus rsa_key_value[:modulus]
              rsa.Exponent rsa_key_value[:exponent]
            end
          end

          other_elements.each { |el| builder << el.to_xml }
        end
    end
  end
end
