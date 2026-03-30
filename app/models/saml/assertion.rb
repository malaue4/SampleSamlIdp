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
    attribute :statements, default: -> { [] }
    attribute :authn_statements, default: -> { [] }
    attribute :authz_decision_statements, default: -> { [] }
    attribute :attribute_statements, default: -> { [] }

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

    def self.parse_issuer(assertion_element)
      issuer_element = assertion_element.at_xpath("saml:Issuer", "saml" => Namespaces::SAML)
      return unless issuer_element

      NameId.parse(issuer_element)
    end

    def self.parse_subject(assertion_element)
      subject_element = assertion_element.at_xpath("saml:Subject", "saml" => Namespaces::SAML)
      return unless subject_element

      Subject.parse(subject_element)
    end

    def self.parse_conditions(assertion_element)
      conditions_element = assertion_element.at_xpath("saml:Conditions", "saml" => Namespaces::SAML)
      return unless conditions_element

      Conditions.parse(conditions_element)
    end

    def self.parse_advice(assertion_element)
      advice_element = assertion_element.at_xpath("saml:Advice", "saml" => Namespaces::SAML)
      return unless advice_element

      Advice.parse(advice_element)
    end

    def self.parse_statements(assertion_element)
      statement_elements = assertion_element.xpath("saml:Statement", "saml" => Namespaces::SAML)
      statement_elements.map { |element| Statement.parse(element) }
    end

    def self.parse_authn_statements(assertion_element)
      authn_statement_elements = assertion_element.xpath("saml:AuthnStatement", "saml" => Namespaces::SAML)
      authn_statement_elements.map { |element| AuthnStatement.parse(element) }
    end

    def self.parse_authz_decision_statements(assertion_element)
      authz_decision_statement_elements = assertion_element.xpath("saml:AuthzDecisionStatement", "saml" => Namespaces::SAML)
      authz_decision_statement_elements.map { |element| AuthzDecisionStatement.parse(element) }
    end

    def self.parse_attribute_statements(assertion_element)
      attribute_statement_elements = assertion_element.xpath("saml:AttributeStatement", "saml" => Namespaces::SAML)
      attribute_statement_elements.map { |element| AttributeStatement.parse(element) }
    end

    private

      def xml_namespace
        { href: Namespaces::SAML, prefix: "saml" }
      end

      def xml_attributes
        {
          Version: version,
          ID: id,
          IssueInstant: issue_instant&.iso8601,
        }.compact
      end

      def xml_content(builder)
        if issuer&.respond_to?(:build_xml)
          issuer.build_xml(builder, xml_element_name: "Issuer")
        elsif issuer.present?
          builder[xml_namespace[:prefix]].Issuer(issuer.to_s)
        end
        # signature&.build_xml(builder)
        subject&.build_xml(builder)
        conditions&.build_xml(builder)
        advice&.build_xml(builder)
        statements.each { |s| s.build_xml(builder) }
        authn_statements.each { |s| s.build_xml(builder) }
        authz_decision_statements.each { |s| s.build_xml(builder) }
        attribute_statements.each { |s| s.build_xml(builder) }
      end

      def xml_element_name
        "Assertion"
      end
  end
end
