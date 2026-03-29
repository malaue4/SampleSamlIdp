# frozen_string_literal: true

module Saml
  class Assertion
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute :version, :string
    attribute :id, :string
    attribute :issue_instant, :datetime

    attribute :issuer
    attribute :signature
    attribute :subject
    attribute :conditions
    attribute :advice
    attribute :statements
    attribute :authn_statements
    attribute :authz_decision_statements
    attribute :attribute_statements

    validates :version, presence: true
    validates :id, presence: true
    validates :issue_instant, presence: true
    validates :issuer, presence: true

    def self.parse(assertion_element)
      new(
        version: assertion_element.attribute("Version")&.value,
        id: assertion_element.attribute("ID")&.value,
        issue_instant: assertion_element.attribute("IssueInstant")&.value,
        issuer: parse_issuer(assertion_element),
        # TODO: signature: Signature.parse(assertion_element.at_xpath("ds:Signature", "ds" => Namespaces::DS)),
        subject: parse_subject(assertion_element),
        conditions: parse_conditions(assertion_element),
        advice: parse_advice(assertion_element),
        statements: parse_statements(assertion_element),
        authn_statements: parse_authn_statements(assertion_element),
        authz_decision_statements: parse_authz_decision_statements(assertion_element),
        attribute_statements: parse_attribute_statements(assertion_element),
      )
    end

    private

      def parse_issuer(assertion_element)
        issuer_element = assertion_element.at_xpath("saml:Issuer", "saml" => Namespaces::SAML)
        return unless issuer_element

        NameId.parse(issuer_element)
      end

      def parse_subject(assertion_element)
        subject_element = assertion_element.at_xpath("saml:Subject", "saml" => Namespaces::SAML)
        return unless subject_element

        Subject.parse(subject_element)
      end

      def parse_conditions(assertion_element)
        conditions_element = assertion_element.at_xpath("saml:Conditions", "saml" => Namespaces::SAML)
        return unless conditions_element

        Conditions.parse(conditions_element)
      end

      def parse_advice(assertion_element)
        advice_element = assertion_element.at_xpath("saml:Advice", "saml" => Namespaces::SAML)
        return unless advice_element

        Advice.parse(advice_element)
      end

      def parse_statements(assertion_element)
        statement_elements = assertion_element.xpath("saml:Statement", "saml" => Namespaces::SAML)
        statement_elements.map { |element| Statement.parse(element) }
      end

      def parse_authn_statements(assertion_element)
        authn_statement_elements = assertion_element.xpath("saml:AuthnStatement", "saml" => Namespaces::SAML)
        authn_statement_elements.map { |element| AuthnStatement.parse(element) }
      end

      def parse_authz_decision_statements(assertion_element)
        authz_decision_statement_elements = assertion_element.xpath("saml:AuthzDecisionStatement", "saml" => Namespaces::SAML)
        authz_decision_statement_elements.map { |element| AuthzDecisionStatement.parse(element) }
      end

      def parse_attribute_statements(assertion_element)
        attribute_statement_elements = assertion_element.xpath("saml:AttributeStatement", "saml" => Namespaces::SAML)
        attribute_statement_elements.map { |element| AttributeStatement.parse(element) }
      end

      def xml_namespace
        { href: Namespaces::SAML, prefix: "saml" }
      end

      def xml_attributes
        {
          Format: format,
          SPProvidedID: sp_provided_id,
          NameQualifier: name_qualifier,
          SPNameQualifier: sp_name_qualifier,
        }.compact
      end

      def xml_content(builder)
        builder.text(value)
      end

      def xml_element_name
        "NameID"
      end
  end
end
