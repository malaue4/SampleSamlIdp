# frozen_string_literal: true

module Saml
  module Metadata
    class KeyDescriptor
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml

      # @!attribute [rw] use
      #    @return [String]
      attribute :use, :string
      attribute :key_info
      attribute :encryption_methods

      validates :use, presence: true, inclusion: { in: %w[signing encryption] }
      validates :key_info, presence: true

      def self.parse(key_descriptor_element)
        new(
          use: key_descriptor_element.attribute("use")&.value,
          key_info: Dsig::KeyInfo.parse(key_descriptor_element.at_xpath("ds:KeyInfo", "ds" => Namespaces::DS)),
          encryption_methods: key_descriptor_element.xpath("md:EncryptionMethod", "md" => Namespaces::MD)
                                                    .map { |node| EncryptionMethod.parse(node) }
        )
      end

      def certificate
        key_info&.certificate
      end

      private

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_attributes
          { use: }
        end

        def xml_content(builder)
          key_info.build_xml(builder)
          encryption_methods&.each do |method|
            method.build_xml(builder)
          end
      end
    end
  end
end
