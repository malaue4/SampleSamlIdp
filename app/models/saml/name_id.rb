# frozen_string_literal: true

module Saml
  class NameId
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute :value, default: ""
    attribute :format, default: "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
    attribute :sp_provided_id, default: false
    attribute :name_qualifier
    attribute :sp_name_qualifier

    def self.parse(name_id_element)
      new(
        value: name_id_element.text&.squish,
        format: name_id_element["Format"],
        sp_provided_id: name_id_element["SPProvidedID"],
        name_qualifier: name_id_element["NameQualifier"],
        sp_name_qualifier: name_id_element["SPNameQualifier"],
      )
    end

    private

      def xml_namespace
        "saml"
      end

      def xml_attributes
        {
          Format: format,
          SPProvidedID: sp_provided_id,
          NameQualifier: name_qualifier,
          SPNameQualifier: sp_name_qualifier,
        }.compact
      end

      def xml_content(builder)
        builder.text(value)
      end

      def xml_element_name
        "NameID"
      end
  end
end
