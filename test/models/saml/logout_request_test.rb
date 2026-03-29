# frozen_string_literal: true

require "test_helper"

module Saml
  class LogoutRequestTest < ActiveSupport::TestCase

    def setup
      # Do nothing
    end

    def teardown
      # Do nothing
    end

    def logout_request
      @logout_request ||= Request.parse file_fixture("saml_requests/logout_request.xml").read
    end

    def test_parse
      assert_kind_of LogoutRequest, logout_request
      assert_equal "_logout123", logout_request.id
      assert_equal "2.0", logout_request.version
      assert_equal "2025-01-01T12:05:00Z", logout_request.issue_instant
      assert_equal "https://idp.example.com/saml/logout", logout_request.destination
      assert_equal "https://sp.example.com/metadata", logout_request.issuer.value
      assert_equal "user@example.com", logout_request.name_id.value
      assert_equal [ "_session_abc123" ], logout_request.session_indices
    end

    def test_as_json
      json = logout_request.as_json
      assert_equal "_logout123", json["attributes"]["id"]
      assert_equal "user@example.com", json["attributes"]["name_id"]["attributes"]["value"]
      assert_equal [ "_session_abc123" ], json["attributes"]["session_indices"]
    end
  end
end
