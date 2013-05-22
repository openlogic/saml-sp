module Saml2
  class AuthnRequest
    attr_reader :issuer, :id, :issue_instant, :assertion_consumer_service_url

    def initialize(attrs = {})
      @issuer = attrs.fetch(:issuer)
      @id = SecureRandom.uuid
      @issue_instant = Time.now.utc.strftime('%FT%TZ')
      @assertion_consumer_service_url = attrs[:assertion_consumer_service_url]
    end

    def to_xml
      Nokogiri::XML::Builder.new do |xml|
        xml.AuthnRequest('xmlns:samlp' => 'urn:oasis:names:tc:SAML:2.0:protocol',
                         'xmlns:saml' => 'urn:oasis:names:tc:SAML:2.0:assertion',
                         'ID' => id,
                         'Version' => '2.0',
                         'IssueInstant' => issue_instant,
                         'AssertionConsumerServiceURL' => assertion_consumer_service_url) do
          xml.parent.namespace = xml.parent.namespace_definitions.find {|ns| ns.prefix == 'samlp'} # Necessary to output namespace prefix on root element.
          xml['saml'].Issuer issuer
        end
      end.to_xml
    end
  end
end
