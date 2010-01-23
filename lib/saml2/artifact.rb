require 'base64'

module Saml2
  class Artifact
    def self.parse(artifact)
      decoded_artifact = Base64.decode64(artifact)
      type_code, endpoint_index, content = decoded_artifact.unpack('nna*')

      klass = if type_code ==4 
                Type4Artifact
              else
                self
              end

      klass.new(type_code, endpoint_index, content)
    end

    attr_reader :type_code, :endpoint_index, :content

    def initialize(type_code, endpoint_index, content)
      @type_code = type_code
      @endpoint_index = endpoint_index
      @content = content
    end
  end

  class Type4Artifact < Artifact
    attr_reader :source_id, :message_handle

    def initialize(type_code, endpoint_index, content)
      super

      @source_id, @message_handle = content.unpack('a20a20')
    end
  end
end
