# frozen_string_literal: true

module Saml
  class Status
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute :status_code
    attribute :status_message, :string
    attribute :status_detail

    # @param [Nokogiri::XML::Node] status_element
    def self.parse(status_element)
      children = status_element.element_children.to_h do |node|
        [ node.name, node ]
      end
      new(
        status_code: StatusCode.parse(children.fetch("StatusCode")),
        status_message: children.fetch("StatusMessage", nil)&.text,
        status_detail: children.fetch("StatusDetail", nil), # TODO: This can be anything, not sure how to parse it.
      )
    end

    private

      def xml_namespace
        { href: Namespaces::SAMLP, prefix: "samlp" }
      end

      def xml_content(builder)
        status_code.build_xml(builder)
        builder.StatusMessage status_message if status_message
        builder.StatusDetail status_detail if status_detail
      end
  end
end
