module SamlSp  
  class ConfigurationError < StandardError
  end

  class ConfigBlock
    # Interpret a config block.
    def interpret(config_block, filename = nil)
      if filename
        instance_eval config_block, filename
      elsif config_block.respond_to? :call
        instance_eval &config_block
      else
        instance_eval config_block
      end
      
      self
    end
    
    def self.inherited(subclass)
      subclass.extend ClassMethods
    end
    
    NOVAL_MARKER = Object.new
    
    module ClassMethods
      def config_item(name)
        class_eval(<<METHOD)
            def #{name}(val=NOVAL_MARKER)
              if NOVAL_MARKER.equal? val
                @#{name}
              else
                @#{name} = val
              end
            end
METHOD
      end
    end
  end

  class Config < ConfigBlock
    def self.load_file(filename)
      SamlSp.logger.info "saml-sp: Loading config file '#{filename}'"

      new.interpret File.read(filename), filename
    end

    def interpret(config, filename = nil)
      if filename
        instance_eval config, filename
      else
        instance_eval config
      end
    end

    def logger(logger)
      SamlSp.logger = logger
    end

    def artifact_resolution_service(&blk)
      dsl = ResolutionSerivceConfig.new
      dsl.interpret(blk)
    end
  end 
   

  class ResolutionSerivceConfig < ConfigBlock
    config_item :source_id
    config_item :uri
    config_item :identity_provider
    config_item :service_provider
    config_item :logger

    def interpret(config_block, filename = nil)
      super

      raise ConfigurationError, "Incomplete artifact resolution service information" unless @source_id && @uri && @identity_provider && @service_provider
      
      resolver = Saml2::ArtifactResolver.new(@source_id, @uri, @identity_provider, @service_provider)
      
      if @auth_info
        resolver.basic_auth_credentials(@auth_info.user_id, @auth_info.password, @auth_info.realm)
      end

      resolver
    end
    
    def http_basic_auth(&blk)
      @auth_info = HttpBasicAuthConfig.new
      @auth_info.interpret(blk)
    end
  end

  class HttpBasicAuthConfig < ConfigBlock
    config_item :realm
    config_item :user_id
    config_item :password

    def promiscuous
      @promiscuous = true
    end

    def interpret(blk, filename = nil)
      super

      raise ConfigurationError, "Incomplete HTTP basic auth credentials" unless valid? 

      self
    end

    def valid?
      (@realm || @promiscuous) && @user_id && @password
    end
  end
end
