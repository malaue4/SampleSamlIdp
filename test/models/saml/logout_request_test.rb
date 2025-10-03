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
    end

    def test_as_json
      skip "Not implemented"
      assert_equal({}, logout_request.as_json)
    end
  end
end
