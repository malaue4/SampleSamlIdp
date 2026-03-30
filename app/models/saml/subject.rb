# frozen_string_literal: true

module Saml
  class Subject
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute :user_id
    attribute :subject_confirmations, default: -> { [] }

    # @param [Nokogiri::XML::Node] subject_element
    def self.parse(subject_element)
      new(
        user_id: parse_user_id(subject_element.at_xpath("saml:NameID | saml:EncryptedID | saml:BaseID", "saml" => Namespaces::SAML)),
        subject_confirmations: subject_element.xpath("saml:SubjectConfirmation", "saml" => Namespaces::SAML).map do |confirmation|
          SubjectConfirmation.parse(confirmation)
        end,
      )
    end

    # @param [Nokogiri::XML::Node, nil] user_id_element
    def self.parse_user_id(user_id_element)
      return if user_id_element.nil?

      case user_id_element.name
      when "NameID" then NameId.parse(user_id_element)
      when "EncryptedID" then EncryptedId.parse(user_id_element)
      when "BaseID" then BaseId.parse(user_id_element)
      else raise NotImplementedError, "Unknown user ID element: #{user_id_element.name}"
      end
    end

    private

      def xml_namespace
        { href: Namespaces::SAML, prefix: "saml" }
      end

      def xml_content(builder)
        user_id&.build_xml(builder)
        subject_confirmations.each { |confirmation| confirmation.build_xml(builder) }
      end
  end
end
