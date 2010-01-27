module SamlSp  
  class ConfigurationError < StandardError
  end

  class Config
    def interpret(config)
      instance_eval config
    end

    def artifact_resolution_service(&blk)
      yield

      raise ConfigurationError, "Incomplete artifact resolution service information" unless @source_id && @uri

      resolver = Saml2::ArtifactResolver.new(@source_id, @uri)
      
      if @has_basic_auth_credentials
        resolver.basic_auth_credentials(@realm, @user_id, @password)
      end

      resolver
    end

    def source_id(source_id)
      @source_id = source_id
    end

    def uri(resolution_service_uri)
      @uri = resolution_service_uri
    end

    def http_basic_auth(&blk)
      @has_basic_auth_credentials = true
      yield
      raise ConfigurationError, "Incomplete HTTP basic auth credentials" unless @realm && @user_id && @password
    end

    def realm(realm)
      @realm = realm
    end

    def user_id(user_id)
      @user_id = user_id
    end
    
    def password(password)
      @password = password
    end
  end
end