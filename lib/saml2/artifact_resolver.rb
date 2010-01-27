require 'addressable/uri'
require 'resourceful'
require 'nokogiri'

module Saml2
  class NoSuchResolverError < StandardError
  end

  class RequestDeniedError < StandardError
  end


  class ArtifactResolver
    attr_reader :source_id, :resolution_service_uri, :basic_auth_realm, :basic_auth_user_id, :basic_auth_password

    # Initialize and register a new artifact resolver.
    #
    # @param [string] source_id An opacque identifier used by the IDP
    #   to identify artifact that can be resolved by this service.
    #
    # @param [string] resolution_service_uri The URI that will resolve
    #   artifacts into assertions.  
    def initialize(source_id, resolution_service_uri)
      @source_id = source_id
      @resolution_service_uri = Addressable::URI.parse(resolution_service_uri) 

      ArtifactResolverRegistry.register self  
    end

    # Set HTTP basic authentication credentials
    def basic_auth_credentials(realm, user_id, password)
      @basic_auth_realm = realm
      @basic_auth_user_id = user_id
      @basic_auth_password = password

      Resourceful.add_authenticator Resourceful::BasicAuthenticator.new(realm, user_id, password)
    end

    def resolve(artifact)
      resp = Resourceful.post  resolution_service_uri, request_document_for(artifact), 
                               'Accept' => 'application/soap+xml', 'Content-Type' => 'application/soap+xml'

      doc = Nokogiri::XML.parse(resp.body)
      raise RequestDeniedError unless doc.at("//sp:StatusCode[@Value='urn:oasis:names:tc:SAML:2.0:status:Success']",
                                             'sp' => 'urn:oasis:names:tc:SAML:2.0:protocol')
                                                                                                       
      Assertion.new_from_xml(doc)
    end

    protected

    def request_document_for(artifact)
      <<-XML
<?xml version="1.0"?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" 
                         xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance" 
                         xmlns:xsd="http://www.w3.org/1999/XMLSchema">
        <SOAP-ENV:Body>
          <samlp:Request IssueInstant="2006-12-15T15:35:12.068Z" 
                         MajorVersion="1" MinorVersion="0" 
                         RequestID="SM8511eae716fd52188b88305f9a803e9a795b71750d" 
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
    def register(resolver)
      resolvers_table[resolver.source_id] = resolver
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
