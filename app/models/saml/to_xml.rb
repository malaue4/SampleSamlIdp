# frozen_string_literal: true

module Saml::ToXml
  def build_xml(builder, **extra_attributes)
    if xml_namespace
      builder[xml_namespace]
    else
      builder
    end.send(xml_element_name, **xml_attributes.merge(extra_attributes)) do
      xml_content(builder)
    end
  end

  private

    def xml_namespace
      nil
    end

    def xml_element_name
      @xml_element_name ||= self.class.name.demodulize.to_sym
    end

    def xml_attributes
      {}
    end

    # @param [Nokogiri::XML::Builder] builder
    def xml_content(builder); end
end
