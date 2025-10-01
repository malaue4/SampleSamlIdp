# frozen_string_literal: true

module Saml
  class LogoutRequest < Request

    validates :name_id, presence: true
    validates :not_on_or_after, comparison: { greater_than: proc { Time.current }, allow_blank: true }

    def name_id_element
      @name_id_element ||= request_element.at_xpath("saml:NameID", "saml" => Namespaces::SAML)
    end

    def name_id
      return if name_id_element.blank?

      @name_id ||= NameId.parse(name_id_element)
    end

    def session_index_elements
      @session_index_element ||= request_element.xpath("samlp:SessionIndex", "samlp" => Namespaces::SAMLP)
    end

    def session_indices
      @session_index ||= session_index_elements.map(&:text)
    end

    def reason
      @reason ||= request_element.attribute("Reason")&.value
    end

    def not_on_or_after
      @not_on_or_after ||= request_element.attribute("NotOnOrAfter")&.value&.to_time
    end
  end
end
