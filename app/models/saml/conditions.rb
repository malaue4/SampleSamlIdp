# frozen_string_literal: true

module Saml
  class Conditions
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute :audience_restrictions
    attribute :one_time_use, :boolean, default: false
    attribute :not_before, :datetime
    attribute :not_on_or_after, :datetime

    # @param [Nokogiri::XML::Node] conditions_element
    def self.parse(conditions_element)
      new(
        audience_restrictions: conditions_element
                                 .xpath("saml:AudienceRestriction/saml:Audience", "saml" => Namespaces::SAML)
                                 .map(&:text)
                                 .presence,
        one_time_use: conditions_element.at_xpath("saml:OneTimeUse", "saml" => Namespaces::SAML).present?,
        not_before: conditions_element.attribute("NotBefore")&.value,
        not_on_or_after: conditions_element.attribute("NotOnOrAfter")&.value,
      )
    end

    private

      def xml_attributes
        {
          NotBefore: not_before&.iso8601,
          NotOnOrAfter: not_on_or_after&.iso8601,
        }.compact
      end

      def xml_namespace
        { href: Namespaces::SAML, prefix: "saml" }
      end

      def xml_content(builder)
        builder.AudienceRestriction do
          audience_restrictions.each do |audience|
            builder.Audience audience
          end
        end
        builder.OneTimeUse if one_time_use
      end
  end
end
