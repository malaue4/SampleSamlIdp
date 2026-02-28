# frozen_string_literal: true

module Saml
  class StatusResponse
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute :id, :string
    attribute :in_response_to, :string
    attribute :version, :string
    attribute :issue_instant, :datetime
    attribute :destination, :string
    attribute :consent, :string

    attribute :issuer
    attribute :signature
    attribute :extensions
    attribute :status


    # @param [Nokogiri::XML::Node] node
    def self.parse(node)
      attributes = {
        id: node["ID"],
        in_response_to: node["InResponseTo"],
        version: node["Version"],
        issue_instant: node["IssueInstant"],
        destination: node["Destination"],
        consent: node["Consent"],
      }
      case node.name
      when "Response" then Response.new(node)
      end
    end

    private

      def xml_attributes
        super.merge!(
          ID: id,
          InResponseTo: in_response_to,
          Version: version,
          IssueInstant: issue_instant,
          Destination: destination,
          Consent: consent,
          ).compact
      end

      def xml_namespace
        { href: Namespaces::SAMLP, prefix: "samlp" }
      end

      def xml_content(builder)
        super
      end
  end
end
