require 'base64'
require 'saml2/unexpected_type_code_error'

module Saml2
  class Type4Artifact
    attr_reader :endpoint_index, :source_id, :message_handle

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

    def type_code 
      4
    end
  end
end
