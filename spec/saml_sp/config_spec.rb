require File.join(File.dirname(__FILE__), '../spec_helper')
require 'tempfile'

describe SamlSp::Config do 
  before do 
    @dsl = SamlSp::Config.new
  end

  describe "loading from file" do
    before do 
      @source_id = Time.now.xmlschema(10)

      @tmpfile = Tempfile.open('saml-sp-config') 
      @tmpfile << <<-CONFIG
          artifact_resolution_service {
            source_id         "#{@source_id}"
            uri               "http://idp.invalid/resolve-artifacts"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"
          }
        CONFIG
      @tmpfile.flush
    end

    after do 
      @tmpfile.close!
    end

    it "should build resolver" do 
      SamlSp::Config.load_file(@tmpfile.path)

      Saml2::ArtifactResolver(@source_id).should be_kind_of(Saml2::ArtifactResolver)
    end
  end

  describe "global log configuration" do 
    before do 
      @orig_logger = SamlSp.logger
      @dsl = SamlSp::Config.new
      @resolver = @dsl.interpret(<<-CONFIG)
          logger :MARKER
        CONFIG
    end
    
    it "should set SamlSp.logger correctly" do 
      SamlSp.logger.should == :MARKER
    end

    after do 
      SamlSp.logger = @orig_logger
    end
  end

  describe "valid basic auth'd service description" do 
    before do 
      @dsl = SamlSp::Config.new
      @resolver = @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            source_id         "01234567890123456789"
            uri               "http://idp.invalid/resolve-artifacts"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"

            http_basic_auth {
              realm    "myssorealm"
              user_id  "myuserid"
              password "mypassword"
            }
          }
        CONFIG
    end
    
    it "should build a resolver" do 
      @resolver.should be_kind_of(Saml2::ArtifactResolver)
    end
    
    it "should build a resolver with correct source id" do 
      @resolver.source_id.should == '01234567890123456789'
    end
    
    it "should build a resolver with correct service uri" do 
      @resolver.resolution_service_uri.to_s.should == "http://idp.invalid/resolve-artifacts"
    end

    it "should build a resolver with correct identity provider id" do 
      @resolver.idp_id.should == "http://idp.invalid/"
    end

    it "should build a resolver with correct service provider id" do 
      @resolver.sp_id.should == "http://sp.invalid/"
    end
    
    it "should build a resolver with correct realm" do 
      @resolver.basic_auth_realm.should == 'myssorealm'
    end
      
    it "should build a resolver with correct user id" do 
      @resolver.basic_auth_user_id.should == 'myuserid'
    end
    
    it "should build a resolver with correct password" do 
      @resolver.basic_auth_password.should == 'mypassword'
      end
  end

  describe "valid basic promiscuous auth'd service description" do 
    before do 
      @dsl = SamlSp::Config.new
      @resolver = @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            source_id         "01234567890123456789"
            uri               "http://idp.invalid/resolve-artifacts"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"

            http_basic_auth {
              promiscuous
              user_id  "myuserid"
              password "mypassword"
            }
          }
        CONFIG
    end
    
    it "should build a resolver" do 
      @resolver.should be_kind_of(Saml2::ArtifactResolver)
    end
    
      it "should build a resolver with correct source id" do 
      @resolver.source_id.should == '01234567890123456789'
    end
    
    it "should build a resolver with correct service uri" do 
      @resolver.resolution_service_uri.to_s.should == "http://idp.invalid/resolve-artifacts"
    end

    it "should build a resolver with correct identity provider id" do 
      @resolver.idp_id.should == "http://idp.invalid/"
    end

    it "should build a resolver with correct service provider id" do 
      @resolver.sp_id.should == "http://sp.invalid/"
    end
    
    it "should build a resolver with correct realm" do 
      @resolver.basic_auth_realm.should be_nil
    end
      
    it "should build a resolver with correct user id" do 
      @resolver.basic_auth_user_id.should == 'myuserid'
    end
    
    it "should build a resolver with correct password" do 
      @resolver.basic_auth_password.should == 'mypassword'
      end
  end
  
  describe "valid non-auth service description" do 
    before do 
      @dsl = SamlSp::Config.new
      @resolver = @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            source_id         "01234567890123456789"
            uri               "http://idp.invalid/resolve-artifacts"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"
          }
        CONFIG
    end
    
    it "should build a resolver" do 
      @resolver.should be_kind_of(Saml2::ArtifactResolver)
    end
    
    it "should build a resolver with correct source id" do 
      @resolver.source_id.should == '01234567890123456789'
    end
    
    it "should build a resolver with correct service uri" do 
        @resolver.resolution_service_uri.to_s.should == "http://idp.invalid/resolve-artifacts"
    end
    
    it "should build a resolver with correct identity provider id" do 
      @resolver.idp_id.should == "http://idp.invalid/"
    end

    it "should build a resolver with correct service provider id" do 
      @resolver.sp_id.should == "http://sp.invalid/"
    end

    it "should build a resolver with correct realm" do 
      @resolver.basic_auth_realm.should == nil
    end
    
    it "should build a resolver with correct user id" do 
      @resolver.basic_auth_user_id.should == nil
    end
    
    it "should build a resolver with correct password" do 
      @resolver.basic_auth_password.should == nil
    end
  end

  it "should raise error on missing source_id" do  
    lambda {
      @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            uri               "http://idp.invalid/resolve-artifacts"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"
          }
        CONFIG
    }.should raise_error SamlSp::ConfigurationError
  end

  it "should raise error on missing uri" do 
    lambda {
      @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            source_id         "01234567890123456789"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"
          }
        CONFIG
    }.should raise_error SamlSp::ConfigurationError
  end

  it "should raise error on missing issuer" do 
    lambda {
      @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            source_id "01234567890123456789"
            uri       "http://idp.invalid/resolve-artifacts"
          }
        CONFIG
    }.should raise_error SamlSp::ConfigurationError
  end

  it "should raise error on missing basic auth realm" do 
    lambda {
      @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            source_id         "01234567890123456789"
            uri               "http://idp.invalid/resolve-artifacts"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"

            http_basic_auth {
              user_id  "myuserid"
              password "mypassword"
            }
          }
        CONFIG
    }.should raise_error SamlSp::ConfigurationError
  end

  it "should raise error on missing basic auth user id" do 
    lambda {
      @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            source_id         "01234567890123456789"
            uri               "http://idp.invalid/resolve-artifacts"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"

            http_basic_auth {
              realm    "myssorealm"
              password "mypassword"
            }
          }
        CONFIG
    }.should raise_error SamlSp::ConfigurationError
  end

  it "should raise error on missing basic auth password" do 
    lambda {
      @dsl.interpret(<<-CONFIG)
          artifact_resolution_service {
            source_id         "01234567890123456789"
            uri               "http://idp.invalid/resolve-artifacts"
            identity_provider "http://idp.invalid/"
            service_provider  "http://sp.invalid/"

            http_basic_auth {
              realm    "myssorealm"
              user_id  "myuserid"
            }
          }
        CONFIG
    }.should raise_error SamlSp::ConfigurationError
  end

end


# Copyright (c) 2010 OpenLogic
#
# Licensed under MIT license.  See LICENSE.txt

