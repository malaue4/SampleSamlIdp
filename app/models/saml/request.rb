# frozen_string_literal: true

module Saml
  class Request
    include ActiveModel::Model

    attr_reader :raw_request
    attr_accessor :metadata

    validates :raw_request, presence: true
    validates :metadata, presence: { message: "is needed for most validations and for verifying signature" }
    validates :id, presence: true
    validates :version, presence: true, inclusion: { in: [ "2.0" ] }
    validates :issue_instant, presence: true
    #validates :destination, presence: { if: true }, inclusion: { in: proc { metadata&.acs_url } }
    #validates :signature, presence: { if: proc { metadata&.wants_requests_signed? } }
    validate :verify_signature, if: :signed?


    def self.parse(maybe_encoded_request)
      decoded_request = Encoding.decode_if_needed(maybe_encoded_request)
      raw_request = Compression.inflate_if_needed(decoded_request)

      document = Nokogiri::XML(raw_request)
      errors = Dir.chdir(File.join(Rails.root, "public")) do
        schema = Nokogiri::XML::Schema(File.read(File.join(Rails.root, "public", "saml-schema-protocol-2.0.xsd")))
        schema.validate document
      end
      if errors.any?
        Rails.logger.error "Error validating SAML request: #{errors.join(", ")}"
        raise errors.join(", ")
      end
      case document.at_xpath("/samlp:AuthnRequest | /samlp:AssertionIDRequest | /samlp:SubjectQuery | /samlp:ArtifactResolve | /samlp:ManageNameIDRequest | /samlp:LogoutRequest | /samlp:NameIDMappingRequest | /samlp:AuthnQuery", "samlp" => Namespaces::SAMLP).name
      when "AuthnRequest" then AuthnRequest.new(raw_request:)
      when "LogoutRequest" then LogoutRequest.new(raw_request:)
      when "AssertionIDRequest" then raise NotImplementedError
      when "SubjectQuery" then raise NotImplementedError
      when "NameIDMappingRequest" then raise NotImplementedError
      when "ManageNameIDRequest" then raise NotImplementedError
      when "ArtifactResolve" then raise NotImplementedError
      when "AuthnQuery" then raise NotImplementedError
      else
        new(raw_request:)
      end
    end

    def initialize(raw_request:, **attributes)
      super(attributes)
      @raw_request = raw_request
    end

    def document
      @document ||= Nokogiri::XML(@raw_request)
    end

    def request_element
      @request_element ||= document.at_xpath("/samlp:AuthnRequest | /samlp:LogoutRequest", "samlp" => Namespaces::SAMLP)
    end

    # The ID of the request. It is used when responding to the request. It must be unique and only used once.
    #
    # @return [String]
    def id
      @id ||= request_element.attribute('ID').value
    end

    # The version of the request. It indicates the SAML protocol version used in the request.
    #
    # @return [String]
    def version
      @version ||= request_element.attribute('Version').value
    end

    # The IssueInstant of the request. It represents the timestamp when the request was issued.
    #
    # @return [String]
    def issue_instant
      @issue_instant ||= request_element.attribute('IssueInstant').value
    end

    # The destination of the request. It specifies the endpoint to which the request must be sent.
    # If it does not match the endpoint of the identity provider, the request must be rejected.
    #
    # @return [String, nil]
    def destination
      @destination ||= request_element.attribute('Destination')&.value
    end

    # The Consent of the request. It specifies the user's consent to the request process, if provided.
    # Possible values are:
    # - urn:oasis:names:tc:SAML:2.0:consent:unspecified
    #   * The consent of the user is not specified.
    # - urn:oasis:names:tc:SAML:2.0:consent:obtained
    #   * Specifies that user consent is acquired by the issuer of the message.
    # - urn:oasis:names:tc:SAML:2.0:consent:prior
    #   * Specifies that user consent is acquired by the issuer of the message before the action which initiated the message.
    # - urn:oasis:names:tc:SAML:2.0:consent:current-implicit
    #   * Specifies that user consent is implicitly acquired by the issuer of the message when the message was initiated.
    # - urn:oasis:names:tc:SAML:2.0:consent:current-explicit
    #   * Specifies that the user consent is explicitly acquired by the issuer of the message at the instance that the message was sent.
    # - urn:oasis:names:tc:SAML:2.0:consent:unavailable
    #   * Specifies that the issuer of the message was not able to get consent from the user.
    # - urn:oasis:names:tc:SAML:2.0:consent:inapplicable
    #   * Specifies that the issuer of the message does not need to get or report the user consent.
    #
    # @return [String, nil]
    def consent
      @consent ||= request_element.attribute('Consent')&.value
    end

    def issuer_element
      @issuer_element ||= request_element.at_xpath('saml:Issuer')
    end

    def issuer
      return if issuer_element.blank?

      @issuer ||= NameId.parse(issuer_element)
    end

    # The entity ID of the issuer. It identifies the entity that issued the SAML request.
    # This is used to determine which set of metadata to use when validating the request.
    #
    # @return [String, nil]
    def issuer_entity_id
      @issuer_entity_id ||= issuer&.value
    end

    # The Signature element of the request. This element contains the XML Signature
    # associated with the request. It is used to verify the authenticity of the request.
    #
    # If the signature element is not present in the request, this will return `nil`.
    #
    # @return [Nokogiri::XML::Node, nil]
    def signature_element
      @signature_element ||= request_element.at_xpath("ds:Signature", "ds" => Namespaces::DS)
    end

    def signed?
      signature_element.present?
    end

    def verify_signature(certificate = nil)
      certificate ||= metadata.parsed_metadata.fetch(:signing_certificate)
      certificate = OpenSSL::X509::Certificate.new(certificate) unless certificate.is_a? OpenSSL::X509::Certificate
      signed_document = Xmldsig::SignedDocument.new(raw_request)
      signed_document.validate(certificate)
    end

    # The Extensions element of the request. This element contains optional metadata or additional elements
    # that extend the functionality of the SAML protocol.
    #
    # If the Extensions element is not present in the request, this will return `nil`.
    #
    # @return [Nokogiri::XML::Node, nil]
    def extensions_element
      @extensions_element ||= request_element.at_xpath("samlp:Extensions", "samlp" => Namespaces::SAMLP)
    end

    module Compression
      extend self

      def inflate_if_needed(request)
        inflate(request)
      rescue Zlib::DataError
        request
      end

      # Note: SAML requests can't actually use this check, the zlib headers are stripped as per the spec.
      def needs_inflation?(request)
        request.starts_with? "\x78"
      end

      def inflate(request)
        zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
        begin
          zstream.inflate(request).tap { zstream.finish }
        rescue Zlib::Error => e
          Rails.logger.error "Error inflating SAML request: #{e.message}"
          request
        ensure
          zstream.close
        end
      end

      def deflate(request)
        zstream = Zlib::Deflate.new(Zlib::BEST_COMPRESSION)
        begin
          zstream.deflate(request, Zlib::FINISH)[2..-5] # This strips the zlib container, because SAML :shrug:
        ensure
          zstream.close
        end
      end
    end

    module Encoding
      extend self

      def decode_if_needed(request)
        needs_decoding?(request) ? decode(request) : request
      end

      def needs_decoding?(request)
        request.match?(/\A[A-Za-z0-9+\/=\n]+\z/)
      end

      def decode(request)
        Base64.decode64(request)
      end

      def encode(request)
        Base64.strict_encode64(request)
      end
    end

    module Encryption
      extend self

      def decrypt(request, decryption_key)
        encrypted_document = Xmlenc::EncryptedDocument.new(request)
        encrypted_document.decrypt(decryption_key)
      end

      def needs_decryption?(request)
        request.match?(/<(\w+:)?EncryptedData/)
      end

      def encrypt_element(element, encryption_key)
        encrypted_document = Xmlenc::EncryptedData
        encrypted_document.encrypt(encryption_key)
      end
    end
  end
end
