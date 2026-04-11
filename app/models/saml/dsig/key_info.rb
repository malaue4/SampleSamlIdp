# frozen_string_literal: true

require_relative "pgp_data"
require_relative "spki_data"

module Saml
  module Dsig
    class KeyInfo
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      attribute :id, :string
      lazy_attribute(:id) { key_info_element&.attribute("Id")&.value }
      attribute :key_names
      lazy_attribute(:key_names) { key_info_element&.xpath("ds:KeyName", ds: Namespaces::DS)&.map(&:text) || [] }
      attribute :key_values
      lazy_attribute(:key_values) { parse_key_values }
      attribute :retrieval_methods
      lazy_attribute(:retrieval_methods) { parse_retrieval_methods }
      attribute :x509_datas
      lazy_attribute(:x509_datas) { parse_x509_datas }
      attribute :pgp_datas
      lazy_attribute(:pgp_datas) { parse_pgp_datas }
      attribute :spki_datas
      lazy_attribute(:spki_datas) { parse_spki_datas }
      attribute :mgmt_datas
      lazy_attribute(:mgmt_datas) { key_info_element&.xpath("ds:MgmtData", ds: Namespaces::DS)&.map(&:text) || [] }

      def self.parse(key_info_element)
        new.tap do |instance|
          instance.instance_variable_set(:@key_info_element, key_info_element)
        end
      end

      def certificate
        x509_datas.first&.certificate
      end

      private

        attr_reader :key_info_element

        def parse_key_values
          return [] unless key_info_element.present?

          key_info_element.xpath("ds:KeyValue", ds: Namespaces::DS).map do |it|
            ::Saml::Dsig::KeyValue.parse(it)
          end
        end

        def parse_retrieval_methods
          return [] unless key_info_element.present?

          key_info_element.xpath("ds:RetrievalMethod", ds: Namespaces::DS).map do |it|
            ::Saml::Dsig::RetrievalMethod.parse(it)
          end
        end

        def parse_x509_datas
          return [] unless key_info_element.present?

          key_info_element.xpath("ds:X509Data", ds: Namespaces::DS).map do |it|
            ::Saml::Dsig::X509Data.parse(it)
          end
        end

        def parse_pgp_datas
          return [] unless key_info_element.present?

          key_info_element.xpath("ds:PGPData", ds: Namespaces::DS).map do |it|
            ::Saml::Dsig::PgpData.parse(it)
          end
        end

        def parse_spki_datas
          return [] unless key_info_element.present?

          key_info_element.xpath("ds:SPKIData", ds: Namespaces::DS).map do |it|
            ::Saml::Dsig::SPKIData.parse(it)
          end
        end

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_attributes
          { Id: id }.compact
        end

        def xml_content(builder)
          key_names.each { |name| builder.KeyName(name) }
          key_values.each { |value| value.build_xml(builder) }
          retrieval_methods.each { |method| method.build_xml(builder) }
          x509_datas.each { |data| data.build_xml(builder) }
          pgp_datas.each { |data| data.build_xml(builder) }
          spki_datas.each { |data| data.build_xml(builder) }
          mgmt_datas.each { |data| builder.MgmtData(data) }
        end
    end
  end
end
