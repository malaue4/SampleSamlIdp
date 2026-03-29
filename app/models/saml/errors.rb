# frozen_string_literal: true

module Saml
  module Errors
    class SamlError < StandardError
    end

    class SchemaError < SamlError
    end
  end
end
