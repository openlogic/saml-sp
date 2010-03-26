module SamlSp  
  class ConfigurationError < StandardError
  end

  class Config
    include Logging

    def self.load_file(filename)
      logger.info "saml-sp: Loading config file '#{filename}'"

      new.interpret File.read(filename), filename
    end

    def interpret(config, filename = nil)
      if filename
        instance_eval config, filename
      else
        instance_eval config
      end
    end

    def artifact_resolution_service(&blk)
      yield

      raise ConfigurationError, "Incomplete artifact resolution service information" unless 
        @source_id && @uri && @issuer_uri

      resolver = Saml2::ArtifactResolver.new(@source_id, @uri, @issuer_uri)
      
      if @auth_info
        resolver.basic_auth_credentials(@auth_info.user_id, @auth_info.password, @auth_info.realm)
      end

      resolver
    end

    def source_id(source_id)
      @source_id = source_id
    end

    def uri(resolution_service_uri)
      @uri = resolution_service_uri
    end

    def issuer(issuer_uri)
      @issuer_uri = issuer_uri
    end

    def http_basic_auth(&blk)
      @auth_info = HttpBasicAuthConfig.new
      @auth_info.interpret(&blk)

      raise ConfigurationError, "Incomplete HTTP basic auth credentials" unless @auth_info.valid?
    end

    class HttpBasicAuthConfig
      @@no_val_marker = Object.new

      def interpret(&blk)
        instance_eval &blk
        self
      end

      def self.conf_item(name)
        
        class_eval(<<-METHOD)
        def #{name}(val=@@no_val_marker)
          if @@no_val_marker.equal? val
            @#{name}
          else
            @#{name} = val
          end
        end
        METHOD
      end

      conf_item :realm
      conf_item :user_id
      conf_item :password

      def promiscuous
        @promiscuous = true
      end

      def valid?
        (@realm || @promiscuous) && @user_id && @password
      end
    end
  end
end
