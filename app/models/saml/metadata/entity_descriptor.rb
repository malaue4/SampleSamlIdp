module Saml
  module Metadata
    class EntityDescriptor
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml
      include LazyAttributes

      attribute :entity_id, :string
      lazy_attribute(:entity_id) { entity_descriptor_element&.attribute("entityID")&.value }
      attribute :id, :string
      lazy_attribute(:id) { entity_descriptor_element&.attribute("ID")&.value }
      attribute :valid_until, :datetime
      lazy_attribute(:valid_until) { entity_descriptor_element&.attribute("validUntil")&.value }
      attribute :cache_duration, :string
      lazy_attribute(:cache_duration) { entity_descriptor_element&.attribute("cacheDuration")&.value }
      attribute :organization
      lazy_attribute(:organization) { parse_organization }
      attribute :contact_people
      lazy_attribute(:contact_people) { parse_contact_people }
      attribute :additional_metadata_locations
      lazy_attribute(:additional_metadata_locations) do
        parse_additional_metadata_locations
      end

      attr_accessor :role_descriptor_elements
      attr_reader :raw_xml

      validates :cache_duration, presence:  { if: proc { |ed| ed.root? && ed.valid_until.nil? } }
      validates :valid_until, presence:  { if: proc { |ed| ed.root? && ed.cache_duration.nil? } }

      def self.parse(raw_xml)
        document = Nokogiri::XML(raw_xml)
        errors = Dir.chdir(File.join(Rails.root, "public")) do
          schema = Nokogiri::XML::Schema(File.read(File.join(Rails.root, "public", "saml-schema-metadata-2.0.xsd")))
          schema.validate document
        end
        if errors.any?
          Rails.logger.error "Error validating SAML metadata: #{errors.join(", ")}"
          raise Errors::SchemaError, errors.join("\n")
        end

        case document.root.name
        when "EntityDescriptor" then new(raw_xml:)
        when "EntitiesDescriptor" then raise NotImplementedError, "EntitiesDescriptor not implemented"
        else
          new(raw_xml:)
        end
      end

      def parse_organization
        return unless entity_descriptor_element.present?

        organization_element = entity_descriptor_element.at_xpath("md:Organization", "md" => Namespaces::MD)
        return unless organization_element

        Organization.parse(organization_element)
      end

      def parse_contact_people
        return unless entity_descriptor_element.present?

        entity_descriptor_element
          .xpath("md:ContactPerson", "md" => Namespaces::MD)
          .map do |contact_person_element|
          ContactPerson.parse(contact_person_element)
        end
      end

      def parse_additional_metadata_locations
        return unless entity_descriptor_element.present?

        entity_descriptor_element
          .xpath("md:AdditionalMetadataLocation", "md" => Namespaces::MD)
          .to_h do |location_element|
            [
              location_element.attribute("namespace").value,
              location_element.text
            ]
        end
      end

      def initialize(raw_xml: nil, **attributes)
        super(attributes)
        @raw_xml = raw_xml
      end

      def document
        @document ||= Nokogiri::XML(raw_xml)
      end

      # @return [Nokogiri::XML::Node]
      def entity_descriptor_element
        @entity_descriptor_element ||= document.at_xpath("/md:EntityDescriptor", "md" => Namespaces::MD)
      end

      def root?
        @root ||= entity_descriptor_element.parent.nil?
      end

      def role_descriptor_elements
        @role_descriptor_elements ||= begin
          entity_descriptor_element
            &.xpath([
                     "md:RoleDescriptor",
                     "md:IDPSSODescriptor",
                     "md:SPSSODescriptor",
                     "md:AuthnAuthorityDescriptor",
                     "md:AttributeAuthorityDescriptor",
                     "md:PDPDescriptor"
                   ].join(" | "), "md" => Namespaces::MD)
            &.map { |rd| RoleDescriptor.parse(rd) } || []
        end
      end


      # @return [Saml::Metadata::ServiceProviderSingleSignOnDescriptor, nil]
      def sp_sso_descriptor
        @sp_sso_descriptor ||= role_descriptor_elements.find { |rd| rd.is_a?(ServiceProviderSingleSignOnDescriptor) }
      end

      # @return [Saml::Metadata::IdentityProviderSingleSignOnDescriptor, nil]
      def idp_sso_descriptor
        @idp_sso_descriptor ||= role_descriptor_elements.find { |rd| rd.is_a?(IdentityProviderSingleSignOnDescriptor) }
      end

      private

        def xml_attributes
          super.merge!(
            entityID: entity_id,
            ID: id,
            validUntil: valid_until&.iso8601,
            cacheDuration: cache_duration,
          ).compact
        end

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_content(builder)
          # extensions&.build_xml(builder)
          role_descriptor_elements.each do |role_descriptor|
            role_descriptor.build_xml(builder)
          end
          organization&.build_xml(builder)
          contact_people&.each do |contact_person|
            contact_person.build_xml(builder)
          end
          additional_metadata_locations&.each do |namespace, location|
            builder.AdditionalMetadataLocation(location, namespace:)
          end
        end
    end
  end
end
