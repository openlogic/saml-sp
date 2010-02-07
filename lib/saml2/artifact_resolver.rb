require 'addressable/uri'
require 'resourceful'
require 'nokogiri'
require 'uuidtools'

module Saml2
  class NoSuchResolverError < StandardError
  end

  class RequestDeniedError < StandardError
  end

  class AnomalousResponseIssuerError < StandardError
    def self.new_from_issuers(expected, actual)
      new "Issuer should have been <#{expected}> but was <#{actual}>"
    end
  end

  class ArtifactResolver
    attr_reader :source_id, :resolution_service_uri, :issuer
    attr_reader :basic_auth_realm, :basic_auth_user_id, :basic_auth_password

    # Initialize and register a new artifact resolver.
    #
    # @param [string] source_id An opacque identifier used by the IDP
    #   to identify artifact that can be resolved by this service.
    #
    # @param [string] resolution_service_uri The URI that will resolve
    #   artifacts into assertions.  
    #
    # @param [String] issuer The URI identifying the issuer at this
    #   source.
    def initialize(source_id, resolution_service_uri, issuer)
      @source_id = source_id
      @resolution_service_uri = Addressable::URI.parse(resolution_service_uri) 
      @issuer = issuer
      ArtifactResolverRegistry.register self  
    end

    # Set HTTP basic authentication credentials
    def basic_auth_credentials(realm, user_id, password)
      @basic_auth_realm = realm
      @basic_auth_user_id = user_id
      @basic_auth_password = password

      Resourceful.add_authenticator Resourceful::BasicAuthenticator.new(realm, user_id, password)
    end

    # Resolve `artifact` into an Assertion.  
    #
    # @param [Saml2::Type4Artifact] The artifact to resolve.
    #
    # @return [Saml2::Assertion]
    #
    # @raise [RequestDeniedError] When the resolution service refuses
    #   to resolve the artifact.
    #
    # @raise [AnomalousResponseIssuerError] When the issuer in the
    #   response do not match the expected issuer for this source.
    def resolve(artifact)
      resp = Resourceful.post  resolution_service_uri, request_document_for(artifact), 
                               'Accept' => 'application/soap+xml', 'Content-Type' => 'application/soap+xml'

      doc = Nokogiri::XML.parse(resp.body)
      raise RequestDeniedError unless response_status(doc) == 'urn:oasis:names:tc:SAML:2.0:status:Success'

      assertion = Assertion.new_from_xml(doc)

      raise AnomalousResponseIssuerError.new_from_issuers(issuer, assertion.issuer) unless 
        assertion.issuer == issuer

      assertion
    end

    def to_s
      "Resolver for <#{issuer}> (#{Base64.encode64(source_id).strip})"
    end

    protected

    def response_status(resp_doc)
      resp_doc.at("//sp:StatusCode/@Value", namespaces).content.strip
    end

    def namespaces
      {'sp' => 'urn:oasis:names:tc:SAML:2.0:protocol',
        'sa' => 'urn:oasis:names:tc:SAML:2.0:assertion'}
    end
    def request_document_for(artifact)
      <<XML
<?xml version="1.0"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" 
                   xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance" 
                   xmlns:xsd="http://www.w3.org/1999/XMLSchema">
  <SOAP-ENV:Body>
    <samlp:Request IssueInstant="2006-12-15T15:35:12.068Z" 
                   MajorVersion="1" MinorVersion="0" 
                   RequestID="#{UUIDTools::UUID.random_create}"
                   xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion" 
                   xmlns:samlp="urn:oasis:names:tc:SAML:1.0:protocol">
      <samlp:AssertionArtifact>
        #{artifact.to_s}
      </samlp:AssertionArtifact>
    </samlp:Request>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
XML
    end
  end

  # Returns an artifact resolver that can be used to resolve artifacts
  # from the specified source.
  #
  # @param [String] source_id The id of the source of interest.
  def self.ArtifactResolver(source_id)
    ArtifactResolverRegistry.lookup_by_source_id(source_id)
  end

  ArtifactResolverRegistry = Class.new do
    include SamlSp::Logging

    def register(resolver)
      resolvers_table[resolver.source_id] = resolver

      logger.info "saml-sp: #{resolver}' registered"
    end
    
    def lookup_by_source_id(source_id)
      resolvers_table[source_id] || raise(NoSuchResolverError, "No resolver registered for source `#{source_id}`")
    end
    
    protected
    
    def resolvers_table
      @resolvers_table ||= {}
    end
  end.new

end
