# frozen_string_literal: true

module Saml
  class StatusCode
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute :value, :string
    attribute :status_code

    validates :value, presence: true

    # @param [Nokogiri::XML::Node] status_code_element
    def self.parse(status_code_element)
      new(
        value: status_code_element.attribute("Value")&.value,
        status_code: status_code_element.first_element_child&.then { |child| StatusCode.parse(child) }
      )
    end


    private

    def xml_namespace
      { href: Namespaces::SAMLP, prefix: "samlp" }
    end

    def xml_attributes
      { "Value" => value }
    end

    def xml_content(builder)
      status_code&.build_xml(builder)
    end
  end
end
