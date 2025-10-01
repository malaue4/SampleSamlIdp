# frozen_string_literal: true

module Saml

  # The SubjectConfirmation element in SAML serves to verify that an assertion is being presented by the legitimate
  # subject it claims to represent. It acts as a proof mechanism to prevent unauthorized parties from misusing
  # assertions.
  #
  # ## Core Purpose
  # SubjectConfirmation establishes how the relying party can confirm that the entity presenting the assertion is
  # indeed the subject described in that assertion. Without this confirmation, assertions could be intercepted and
  # misused by malicious actors.
  #
  # ## Key Components
  # 1. Method attribute (required): Specifies the confirmation mechanism (e.g., bearer token, holder-of-key, sender-vouches)
  # 2. SubjectConfirmation::Data: Contains method-specific validation parameters like:
  #     - Time constraints (`NotBefore`, `NotOnOrAfter`)
  #     - Intended recipient (`Recipient`)
  #     - Network address restrictions (`Address`)
  #     - Request correlation (`InResponseTo`)
  #
  # ## Security Role
  # The element prevents assertion replay attacks and ensures proper audience targeting. For example, with the bearer
  # confirmation method, the SubjectConfirmationData can restrict which service provider can accept the assertion and
  # within what time window.
  #
  # ## Usage Pattern
  # A Subject can have multiple SubjectConfirmation elements, allowing different confirmation methods for different
  # scenarios. The relying party must successfully validate at least one SubjectConfirmation to accept the assertion as
  # legitimate.
  #
  # This makes SubjectConfirmation a critical security component that bridges authentication (who the subject is) with
  # authorization (proving they're presenting their own assertion).
  class SubjectConfirmation
    include ActiveModel::Model

    attr_accessor :name_id, :subject_confirmation_data, :method


    # @param [Nokogiri::XML::Node] subject_confirmation_element
    def self.parse(subject_confirmation_element)
      new(
        method: subject_confirmation_element.attribute("Method")&.value,
        name_id: subject_confirmation_element
          .at_xpath("saml:NameID", "saml" => Namespaces::SAML)
          &.then { |name_id_element| NameId.parse(name_id_element) },
        subject_confirmation_data: subject_confirmation_element
          .at_xpath("saml:SubjectConfirmationData", "saml" => Namespaces::SAML)
          &.then { |data_element| Data.parse(data_element) }
      )
    end

    class Data
      include ActiveModel::Model

      attr_accessor :not_before, :not_on_or_after, :recipient, :in_response_to, :address, :data

      # @param [Nokogiri::XML::Node] subject_confirmation_data_element
      def self.parse(subject_confirmation_data_element)
        new(
          not_before: subject_confirmation_data_element.attribute("NotBefore")&.value&.to_time,
          not_on_or_after: subject_confirmation_data_element.attribute("NotOnOrAfter")&.value&.to_time,
          recipient: subject_confirmation_data_element.attribute("Recipient")&.value,
          in_response_to: subject_confirmation_data_element.attribute("InResponseTo")&.value,
          address: subject_confirmation_data_element.attribute("Address")&.value,
          data: {
            attributes: subject_confirmation_data_element.attributes,
            elements: subject_confirmation_data_element.elements
          }
        )
      end
    end
  end
end
