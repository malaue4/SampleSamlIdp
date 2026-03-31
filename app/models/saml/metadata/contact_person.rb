# frozen_string_literal: true

module Saml
  module Metadata
    class ContactPerson
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml

      attribute :extensions # This could contain anything, TODO: Have a class for representing that?
      attribute :company, :string
      attribute :given_name, :string
      attribute :sur_name, :string
      attribute :email_addresses, default: -> { [] }
      attribute :telephone_numbers, default: -> { [] }
      attribute :contact_type, :string
      # TODO: The spec allows for arbitrary attributes here, maybe we could store them as :extra_attributes or something?

      validates :contact_type, presence: true, inclusion: { in: %w[technical support administrative billing other] }

      # @param [Nokogiri::XML::Node] organization_node
      def self.parse(organization_node)
        to_local_string = ->(nodes) { nodes.to_h { |node| [node.attribute_with_ns("lang", Namespaces::XML)&.value, node.text]} }
        new(
          name: to_local_string.(organization_node.xpath("md:OrganizationName", "md" => Namespaces::MD)),
          display_name: to_local_string.(organization_node.xpath("md:OrganizationDisplayName", "md" => Namespaces::MD)),
          url: to_local_string.(organization_node.xpath("md:OrganizationURL", "md" => Namespaces::MD))
        )
      end

      private

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_attributes
          {
            contactType: contact_type
          }
        end

        def xml_content(builder)
          builder.Company(company) if company.present?
          builder.GivenName(given_name) if given_name.present?
          builder.SurName(sur_name) if sur_name.present?
          email_addresses.each { |email_address| builder.EmailAddress(email_address) }
          telephone_numbers.each { |telephone_number| builder.TelephoneNumber(telephone_number) }
        end
    end
  end
end
