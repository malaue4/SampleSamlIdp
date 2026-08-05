# frozen_string_literal: true

module Saml
  module AttributeAuthority
    class QueriesController < ApplicationController
      def create
        our_metadata = SampleSamlIdp::Application.config.metadata
        our_attribute_authority_metadata = our_metadata.attribute_authority_descriptor

        request = request.body.read
        request = Request.parse(request)
        their_metadata = SamlMetadatum.find_by(entity_id: request.issuer_entity_id)
        if their_metadata.nil?
          response = StatusResponse.new(
            id: "_#{SecureRandom.uuid}",
            in_response_to: request.id,
            issuer: our_metadata.entity_id,
            issue_instant: Time.current.utc,
            status: Status.new(
              status_code: StatusCode.new(
                value: StatusCode::REQUESTER,
              ),
              status_message: "No metadata found for #{request.issuer_entity_id}",
            )
          )

          return render xml: response.to_xml
        end

        if request.signed?
          cert = their_metadata.sp_sso_descriptor&.signing_certificates&.first # Assume they sign as SP?
          return render xml: "error_response" if cert.nil?

          # TODO: validate signature
        else
          # TODO: return error? allow unsigned? configurable?
        end

        # validate the requested attributes
        available_attributes = our_attribute_authority_metadata.requestable_attributes
        requested_attributes = request.requested_attributes || available_attributes
        if requested_attributes.any? { |attr| !available_attributes.include?(attr) }
          return render xml: "error_response"
        end

        # fetch the subject
        subject = User.find_by name_id: request.subject_name_id
        if subject.nil?
          # TODO
          return render xml: "error_response"
        end

        attributes = subject.saml_attributes_for(requested_attributes)
        # TODO: build response

        render xml: "attribute_response"
      end
    end
  end
end
