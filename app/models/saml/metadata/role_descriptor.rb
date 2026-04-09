# frozen_string_literal: true

module Saml
  module Metadata
    class RoleDescriptor
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml
      include LazyAttributes

      attribute :id, :string
      lazy_attribute(:id) { role_descriptor_element&.attribute("ID")&.value }
      attribute :valid_until, :datetime
      lazy_attribute(:valid_until) { role_descriptor_element&.attribute("validUntil")&.value }
      attribute :cache_duration
      lazy_attribute(:cache_duration) { role_descriptor_element&.attribute("cacheDuration")&.value }
      attribute :protocol_support_enumeration, :string, default: "urn:oasis:names:tc:SAML:2.0:protocol"
      lazy_attribute(:protocol_support_enumeration) { role_descriptor_element&.attribute("protocolSupportEnumeration")&.value }
      attribute :error_url, :string
      lazy_attribute(:error_url) { role_descriptor_element&.attribute("errorURL")&.value }

      attribute :signature
      lazy_attribute(:signature) { parse_signature }
      attribute :extensions
      lazy_attribute(:extensions) { parse_extensions }
      attribute :key_descriptors
      lazy_attribute(:key_descriptors) { parse_key_descriptors }
      attribute :organization
      lazy_attribute(:organization) { parse_organization }
      attribute :contact_people
      lazy_attribute(:contact_people) { parse_contact_people }

      # @param [Nokogiri::XML::Node] role_descriptor_element
      def self.parse(role_descriptor_element)
        case role_descriptor_element.node_name
        when "IDPSSODescriptor" then IdentityProviderSingleSignOnDescriptor.new(role_descriptor_element:)
        when "SPSSODescriptor" then ServiceProviderSingleSignOnDescriptor.new(role_descriptor_element:)
        when "AuthnAuthorityDescriptor" then raise NotImplementedError, "AuthnAuthorityDescriptor not implemented"
        when "AttributeAuthorityDescriptor" then raise NotImplementedError, "AttributeAuthorityDescriptor not implemented"
        when "PDPDescriptor" then raise NotImplementedError, "PDPDescriptor not implemented"
        else
          new(role_descriptor_element:)
        end
      end

      # @!attribute[r] role_descriptor_element
      #   @return [Nokogiri::XML::Node] the role descriptor XML element
      attr_reader :role_descriptor_element

      # @param [Nokogiri::XML::Node] role_descriptor_element
      def initialize(role_descriptor_element: nil, **attributes)
        super(attributes)
        @role_descriptor_element = role_descriptor_element
      end

      def signing_certificate
        key_descriptors.find { |k| k.use == "signing" }.certificate
      end

      private

        def parse_signature
          return unless role_descriptor_element.present?

          # TODO: parse signature
          nil
        end

        def parse_extensions
          return unless role_descriptor_element.present?

          # TODO: parse extensions
          nil
        end

        def parse_key_descriptors
          return unless role_descriptor_element.present?

          role_descriptor_element
            .xpath("md:KeyDescriptor", "md" => Namespaces::MD)
            .map do |key_descriptor_element|
            KeyDescriptor.parse(key_descriptor_element)
          end
        end

        def parse_organization
          return unless role_descriptor_element.present?

          organization_element = role_descriptor_element.at_xpath("md:Organization", "md" => Namespaces::MD)
          return unless organization_element

          Organization.parse(organization_element)
        end

        def parse_contact_people
          return unless role_descriptor_element.present?

          role_descriptor_element
            .xpath("md:ContactPerson", "md" => Namespaces::MD)
            .map do |contact_person_element|
            ContactPerson.parse(contact_person_element)
          end
        end

        def xml_attributes
          super.merge!(
            ID: id,
            validUntil: valid_until&.iso8601,
            cacheDuration: cache_duration&.iso8601,
            protocolSupportEnumeration: protocol_support_enumeration,
            errorURL: error_url,
          ).compact
        end

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_element_name
          case self
          when IdentityProviderSingleSignOnDescriptor then :IDPSSODescriptor
          when ServiceProviderSingleSignOnDescriptor then :SPSSODescriptor
          else :RoleDescriptor
          end
        end

        def xml_content(builder)
          super
          signature&.build_xml(builder)
          extensions&.build_xml(builder)
          key_descriptors&.each { |k| k.build_xml(builder) }
          organization&.build_xml(builder)
          contact_people&.each { |c| c.build_xml(builder) }
        end
    end
  end
end
