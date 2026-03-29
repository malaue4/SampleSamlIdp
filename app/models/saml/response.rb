# frozen_string_literal: true

module Saml
  class Response < StatusResponse
    attribute :assertions
    lazy_attribute(:assertions) { parse_assertions }
    attribute :encrypted_assertions
    lazy_attribute(:encrypted_assertions) { parse_encrypted_assertions }

    private

    def parse_assertions
      status_response_element.xpath("saml:Assertion", "saml" => Namespaces::SAML).map do |it|
        Assertion.parse(it)
      end
    end

    def parse_encrypted_assertions
      status_response_element.xpath("samlp:EncryptedAssertion", "samlp" => Namespaces::SAMLP).map do |it|
        # TODO: EncryptedAssertion.parse(it)
      end
    end
  end
end
