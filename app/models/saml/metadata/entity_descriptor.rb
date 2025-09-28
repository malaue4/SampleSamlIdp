module Saml
  module Metadata
    class EntityDescriptor
      include ActiveModel::Model

      attr_accessor :raw_xml, :entity_id

      validates :cache_duration, presence:  { if: proc { |ed| ed.root? && ed.valid_until.nil? } }
      validates :valid_until, presence:  { if: proc { |ed| ed.root? && ed.cache_duration.nil? } }

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
            .xpath([
                     "md:RoleDescriptor",
                     "md:IDPSSODescriptor",
                     "md:SPSSODescriptor",
                     "md:AuthnAuthorityDescriptor",
                     "md:AttributeAuthorityDescriptor",
                     "md:PDPDescriptor"
                   ].join(" | "), "md" => Namespaces::MD)
            .map { |element| RoleDescriptor.parse(element) }
        end
      end

      def affiliation_descriptor_element
        @affiliation_descriptor_element ||= entity_descriptor_element
          .at_xpath("md:AffiliationDescriptor", "md" => Namespaces::MD)
      end
    end
  end
end
