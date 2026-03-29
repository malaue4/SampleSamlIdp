# frozen_string_literal: true

module Saml
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
end
