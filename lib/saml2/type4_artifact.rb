require 'base64'
require 'saml2/unexpected_type_code_error'

module Saml2
  class Type4Artifact
    attr_reader :endpoint_index, :source_id, :message_handle

    # Parse an type 4 SAML 2.0 artifact such as one received in a
    # `SAMLart` HTTP request parameter as part of a HTTP artifact
    # binding SSO handshake.
    # 
    # @param [String] artifact_string a base64 encoded SAML 2.0
    #    artifact
    # @return [Saml2::Type4Artifact] the parsed artifact
    def self.new_from_string(artifact_string)
      unencoded_artifact = Base64.decode64 artifact_string

      type_code, *rest = unencoded_artifact.unpack('nna20a20')

      raise UnexpectedTypeCodeError.new("Incorrect artifact type (expected type code 4 but found #{type_code}") unless type_code == 4

      new *rest
    end

    def initialize(endpoint_index, source_id, message_handle)
      @endpoint_index = endpoint_index
      @source_id = source_id
      @message_handle = message_handle
    end

    # The type code of this artifact
    def type_code 
      4
    end

    # @return [String] base64 encoded version of self
    def to_s
      Base64.encode64([4, endpoint_index, source_id, message_handle].pack('nna20a20')).strip
    end

    # Resolve the artifact into an Assertion
    #
    # @return [Saml2::Assertion] the assertion to which the artifact
    #   is a reference
    def resolve
      Saml2::ArtifactResolver(source_id).resolve(self)
    end
  end
end


# Licensed under MIT license.  See README.txt for details.
