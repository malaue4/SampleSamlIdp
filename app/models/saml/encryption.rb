# frozen_string_literal: true

module Saml
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
