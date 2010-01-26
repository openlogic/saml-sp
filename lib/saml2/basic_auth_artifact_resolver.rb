require 'resourceful'
require 'nokogiri'

module Saml2
  class RequestDeniedError < StandardError
  end

  class BasicAuthArtifactResolver
    attr_reader :source_id, :resolution_service_uri, :user_id, :password, :realm

    # Initialize a new artifact resolver that uses basic
    # authentication.
    #
    # @param [string] source_id An opacque identifier used by the IDP
    #   to identify artifact that can be resolved by this service.
    # @param [string] resolution_service_uri The URI that will resolve
    #   artifacts into assertions.
    # @param [string] user_id The user id with which to authenticate.
    # @param [string] pasword The password with which to authenticate.
    # @param [string] realm The realm for the authenication
    def initialize(source_id, resolution_service_uri, user_id, password, realm)
      @source_id = source_id
      @resolution_service_uri = Addressable::URI.parse(resolution_service_uri) 
      @user_id = user_id
      @password = password
      @realm = realm
    end

    # Resolve the specified artifact into an assertion.
    #
    # @param [Saml2::Type4Artifact] artifact The artifact to resolve.
    #
    # @return [Saml2::Assertion]
    def resolve(artifact)
      Resourceful.add_authenticator Resourceful::BasicAuthenticator.new(realm, user_id, password)
      resp = Resourceful.post  resolution_service_uri, '', 'Accept' => 'application/soap+xml', 'Content-Type' => 'application/soap+xml'

      doc = Nokogiri::XML.parse(resp.body)
      raise RequestDeniedError unless doc.at("//sp:StatusCode[@Value='urn:oasis:names:tc:SAML:2.0:status:Success']",
                                             'sp' => 'urn:oasis:names:tc:SAML:2.0:protocol')
                                                                                                       
      Assertion.new_from_xml(doc)
    end
    
  end
end
