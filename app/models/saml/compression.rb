# frozen_string_literal: true

module Saml
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
end
