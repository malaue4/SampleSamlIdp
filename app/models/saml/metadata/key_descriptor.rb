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


      private

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_attributes
          { use: }
        end

        def xml_content(builder)
          key_info&.build_xml(builder)
          encryption_methods&.each do |method|
            method.build_xml(builder)
          end
      end
    end
  end
end
