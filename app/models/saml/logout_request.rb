# frozen_string_literal: true

module Saml
  class LogoutRequest < Request

    attribute :name_id
    lazy_attribute(:name_id) { parse_name_id }
    attribute :session_indices
    lazy_attribute(:session_indices) { parse_session_indices }
    attribute :reason, :string
    lazy_attribute(:reason) { request_element.attribute("Reason")&.value }
    attribute :not_on_or_after, :datetime
    lazy_attribute(:not_on_or_after) { request_element.attribute("NotOnOrAfter")&.value&.to_time }

    validates :name_id, presence: true
    validates :not_on_or_after, comparison: { greater_than: proc { Time.current }, allow_blank: true }

    def name_id_element
      @name_id_element ||= request_element.at_xpath("saml:NameID", "saml" => Namespaces::SAML)
    end

    def parse_name_id
      return if name_id_element.blank?

      NameId.parse(name_id_element)
    end

    def session_index_elements
      request_element.xpath("samlp:SessionIndex", "samlp" => Namespaces::SAMLP)
    end

    def parse_session_indices
      session_index_elements.map(&:text).presence || []
    end
  end
end
