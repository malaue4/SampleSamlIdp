# frozen_string_literal: true

module Saml
  class StatusResponse
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    RESPONSE_TYPES = %w[
      Response
      ArtifactResponse
      ManageNameIDResponse
      LogoutResponse
      NameIDMappingResponse
    ]

    attr_reader :raw_xml

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


    # @param [String] raw_xml
    def self.parse(maybe_encoded_xml)
      decoded_xml = Encoding.decode_if_needed(maybe_encoded_xml)
      raw_xml = Compression.inflate_if_needed(decoded_xml)

      document = Nokogiri::XML(raw_xml)
      errors = Dir.chdir(File.join(Rails.root, "public")) do
        schema = Nokogiri::XML::Schema(File.read(File.join(Rails.root, "public", "saml-schema-protocol-2.0.xsd")))
        schema.validate document
      end

      if errors.any?
        Rails.logger.error "Error validating SAML request: #{errors.join(", ")}"
        raise Errors::SchemaError, errors.join("\n")
      end

      response_type_name = document
               .at_xpath(RESPONSE_TYPES.map { |type| "/samlp:#{type}" }.join("|"), "samlp" => Namespaces::SAMLP).name
      case response_type_name
      when "Response" then Response.new(raw_xml:)
      else
        raise NotImplementedError, "Unknown response type: #{response_type_name}"
      end
    end



    def initialize(raw_xml:, **attributes)
      super(attributes)
      @raw_xml = raw_xml
    end

    def id
      @id ||= status_response_element&.[]("ID")
    end

    def in_response_to
      @in_response_to ||= status_response_element&.[]("InResponseTo")
    end

    def version
      @version ||= status_response_element&.[]("Version")
    end

    def issue_instant
      @issue_instant ||= status_response_element&.[]("IssueInstant")
    end

    def destination
      @destination ||= status_response_element&.[]("Destination")
    end

    def consent
      @consent ||= status_response_element&.[]("Consent")
    end

    def issuer_element
      @issuer_element ||= status_response_element&.at_xpath("saml:Issuer", "saml" => Namespaces::SAML)
    end

    def issuer
      return if issuer_element.blank?

      @issuer ||= NameId.parse(issuer_element)
    end

    def status_element
      @status_element ||= status_response_element&.at_xpath("samlp:Status", "samlp" => Namespaces::SAMLP)
    end

    def status
      if status_element.blank?
        return
      end

      @status ||= Status.parse(status_element)
    end

    def document
      @document ||= Nokogiri::XML(raw_xml)
    end

    def status_response_element
      @status_response_element ||= document.at_xpath(RESPONSE_TYPES.map { |type| "/samlp:#{type}" }.join("|"), "samlp" => Namespaces::SAMLP)
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
