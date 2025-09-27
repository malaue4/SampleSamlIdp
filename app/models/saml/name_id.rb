# frozen_string_literal: true

module Saml
  class NameId
    include ActiveModel::Model

    attr_accessor :value, :format, :sp_provided_id, :name_qualifier, :sp_name_qualifier

    def self.parse(name_id_element)
      new(
        value: name_id_element.text,
        format: name_id_element.attribute("Format")&.value,
        sp_provided_id: name_id_element.attribute("SPProvidedID")&.value,
        name_qualifier: name_id_element.attribute("NameQualifier")&.value,
        sp_name_qualifier: name_id_element.attribute("SPNameQualifier")&.value,
      )
    end
  end
end
