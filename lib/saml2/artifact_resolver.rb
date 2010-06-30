require 'addressable/uri'
gem 'openlogic-resourceful'
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
    attr_reader :source_id, :resolution_service_uri, :idp_id, :sp_id
    attr_reader :basic_auth_realm, :basic_auth_user_id, :basic_auth_password

    # Initialize and register a new artifact resolver.
    #
    # @param [string] source_id An opacque identifier used by the IDP
    #   to identify artifact that can be resolved by this service.
    #
    # @param [string] resolution_service_uri The URI that will resolve
    #   artifacts into assertions.  
    #
    # @param [String] idp_id The URI identifying the assertion issuer at this
    #   source.
    #
    # @param [String] sp_id The URI identifying (for this source) the service 
    #    provider.  IOW, the id of your application.
    def initialize(source_id, resolution_service_uri, idp_id, sp_id)
      @source_id = source_id
      @resolution_service_uri = Addressable::URI.parse(resolution_service_uri) 
      @idp_id = idp_id
      @sp_id = sp_id
      ArtifactResolverRegistry.register self  
    end

    # Set HTTP basic authentication credentials
    def basic_auth_credentials(user_id, password, realm = nil)
      @basic_auth_realm = realm
      @basic_auth_user_id = user_id
      @basic_auth_password = password
    end

    def logger
      SamlSp.logger
    end

    def http
      @http ||= Resourceful::HttpAccessor.new(:authenticators => authenticator, :logger => logger)
    end

    def authenticator
      return nil unless basic_auth_user_id

      if basic_auth_realm
        Resourceful::BasicAuthenticator.new(basic_auth_realm, basic_auth_user_id, basic_auth_password)
      else
        Resourceful::PromiscuousBasicAuthenticator.new(basic_auth_user_id, basic_auth_password)
      end
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
    # @raise [AnomalousResponseIssuerError] When the issuer of the
    #   response do not match the idp_id for this source.
    def resolve(artifact)
      soap_body = request_document_for(artifact)
      logger.debug{"ArtifactResolve request body:\n#{soap_body.gsub(/^/, "\t")}"}
      resp = http.resource(resolution_service_uri).post(soap_body,
                                                        'Accept' => 'application/soap+xml', 
                                                        'Content-Type' => 'application/soap+xml')

      doc = Nokogiri::XML.parse(resp.body)
      assert_successful_response(doc)

      assertion = Assertion.new_from_xml(doc)

      raise AnomalousResponseIssuerError.new_from_issuers(idp_id, assertion.issuer) unless 
        assertion.issuer == idp_id

      assertion

    rescue Resourceful::UnsuccessfulHttpRequestError => e

      logger.debug { 
        body = e.http_request.body
        body.rewind
        "Artifact resolution request:\n" + body.read.gsub(/^/, '    ')}
      logger.debug {"Artifact resolution response:\n" + e.http_response.body.gsub(/^/, '    ')}
      raise
    end

    def to_s
      "Resolver for <#{idp_id}> (#{Base64.encode64(source_id).strip})"
    end

    protected

    def assert_successful_response(resp_doc)
      response_code = resp_doc.at("//sp:StatusCode/@Value", namespaces).content.strip
      return if response_code == 'urn:oasis:names:tc:SAML:2.0:status:Success'
      
      # Request was not handled successfully
      err_message =  "Request failed"

      status_message_elem = resp_doc.at("//sp:StatusMessage", namespaces) 
      if status_message_elem
        err_message << " because \"#{status_message_elem.content.strip}\""
      end
      
      err_message << ". (status code: #{response_code})"

      if status_details_elem = resp_doc.at("//sp:StatusDetail", namespaces) 
        logger.debug "Details for resolve artifact failure (status code: #{response_code}):\n" + status_details_elem.content
      end

      raise RequestDeniedError, err_message
    end

    def namespaces
      {'sp' => 'urn:oasis:names:tc:SAML:2.0:protocol',
        'sa' => 'urn:oasis:names:tc:SAML:2.0:assertion'}
    end
    def request_document_for(artifact)
      <<XML
<?xml version="1.0"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Body>
    <ArtifactResolve IssueInstant="2006-12-15T15:35:12.068Z" 
                     Version="2.0"
                     ID="_#{UUIDTools::UUID.random_create}"
                     xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" 
                     xmlns="urn:oasis:names:tc:SAML:2.0:protocol">
      <saml:Issuer>#{sp_id}</saml:Issuer>
      <Artifact>#{artifact.to_s}</Artifact>
    </ArtifactResolve>
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
      resolvers_table[source_id] || raise(NoSuchResolverError, "No resolver registered for source `#{Base64.encode64(source_id).strip}`")
    end
    
    protected
    
    def resolvers_table
      @resolvers_table ||= {}
    end
  end.new

end

# Copyright (c) 2010 OpenLogic
#
# Licensed under MIT license.  See LICENSE.txt

