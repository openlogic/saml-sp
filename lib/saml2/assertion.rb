require 'nokogiri'
require 'saml2/artifact_resolver'

module Saml2
  class InvalidAssertionError < ArgumentError
  end

  class Assertion
    module Parsing
      def self.item(name, xpath)
        module_eval(<<-ITEM_METH)
        def #{name}_from(node)
          target_node = node.at('#{xpath}')
          raise InvalidAssertionError, "#{name} missing (xpath: `#{xpath}`)" unless target_node
          
          target_node.content.strip
        end
        ITEM_METH
      end

      item :issuer,          '//asrt:Assertion/asrt:Issuer'
      item :subject_name_id, '//asrt:Assertion/asrt:Subject/asrt:NameID'
      item :attribute_name,  '@Name'
      item :attribute_value, './asrt:AttributeValue'

      def each_attribute_node_from(doc, &blk)
        attribute_nodes = doc.search('//asrt:Assertion/asrt:AttributeStatement/asrt:Attribute')
         
        attribute_nodes.each &blk
      end                          
    end
    extend Parsing

    # Resolves an artifact into the Assertion it represents
    #
    # @param [Saml2::Type4Artifact, String] artifact The artifact to
    #   resolve
    #
    # @return [Saml2::Assertion] The assertion represented by
    #   specified artifact
    def self.new_from_artifact(artifact)
      artifact = if artifact.respond_to? :resolve
                   artifact
                 else
                   Type4Artifact.new_from_string(artifact)
                 end
      

      artifact.resolve
    end

    def self.logger
      SamlSp.logger
    end

    def self.new_from_xml(xml_assertion)
      doc = case xml_assertion
            when Nokogiri::XML::Node
              xml_assertion
            else
              Nokogiri::XML.parse(xml_assertion)
            end
      logger.debug {"Parsing assertion: \n" + doc.to_xml(:indent => 2).gsub(/^/, "\t")}


      doc.root.add_namespace_definition('asrt', 'urn:oasis:names:tc:SAML:2.0:assertion')

      attrs = Hash.new
      each_attribute_node_from(doc) do |node|
        attrs[attribute_name_from(node)] = attribute_value_from(node)
      end

      new(issuer_from(doc), subject_name_id_from(doc), attrs)
          
    end

    attr_reader :issuer, :subject_name_id

    def initialize(issuer, subject_name_id, attributes)
      @issuer = issuer
      @subject_name_id = subject_name_id
      @attributes = attributes
    end

    def [](attr_name)
      attributes[attr_name.to_s]
    end

    protected
    
    attr_reader :attributes

  end
end


# Licensed under MIT license.  See README.txt for details.
