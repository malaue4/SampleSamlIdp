# frozen_string_literal: true

module Saml
  module Dsig
    class X509Data
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

      def certificate
        elements.find { |el| el[:type] == :x509_certificate }&.dig(:value)
      end

      private

        attr_reader :element

        def parse_elements
          element.xpath("*", ds: Namespaces::DS).map do |it|
            case it.name
            when "X509IssuerSerial"
              {
                type: :issuer_serial,
                issuer_name: it.at_xpath("ds:X509IssuerName", ds: Namespaces::DS)&.text,
                serial_number: it.at_xpath("ds:X509SerialNumber", ds: Namespaces::DS)&.text
              }
            when "X509SKI", "X509SubjectName", "X509Certificate", "X509CRL"
              { type: it.name.underscore.to_sym, value: it.text }
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
            case el[:type]
            when :issuer_serial
              builder.X509IssuerSerial do |is|
                is.X509IssuerName el[:issuer_name]
                is.X509SerialNumber el[:serial_number]
              end
            when :x509_ski
              builder.X509SKI el[:value]
            when :x509_subject_name
              builder.X509SubjectName el[:value]
            when :x509_certificate
              builder.X509Certificate el[:value]
            when :x509_crl
              builder.X509CRL el[:value]
            when :other
              builder << el[:xml]
            end
          end
        end
    end
  end
end
