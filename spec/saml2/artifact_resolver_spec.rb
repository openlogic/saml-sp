require File.join(File.dirname(__FILE__), '../spec_helper')

describe Saml2::ArtifactResolver do 
  describe "lookups" do 
    before do 
      @resolver = Saml2::ArtifactResolver.new('a-source-id', 'https://idp.invalid/resolution-service', 'http://idp.invalid', 'http://sp.invalid')
    end

    it "should have pseudo-class lookup method" do 
      Saml2::ArtifactResolver('a-source-id').should == @resolver
    end

    it "should raise error when resolver is not found" do 
      lambda {
        Saml2::ArtifactResolver('not-a-known-source-id')
      }.should raise_error Saml2::NoSuchResolverError
    end
  end


  describe "successfully resolving artifact" do 
    before do 
      @resolver = Saml2::ArtifactResolver.new('a-source-id', 'https://idp.invalid/resolution-service', 'http://idp.invalid', 'http://sp.invalid')
      @resolver.basic_auth_credentials('myuserid', 'mypasswd', 'myrealm')
      # register issuer which doesn't require verification
      Saml2::Issuer.new(@resolver.idp_id, false)

      @artifact = Saml2::Type4Artifact.new(0, '01234567890123456789', 'abcdefghijklmnopqrst')
      FakeWeb.register_uri(:post, 'https://idp.invalid/resolution-service', :body => SUCCESSFUL_SAML_RESP)
    end
  
    it "should parse reponse into an assertion" do 
      @resolver.resolve(@artifact).should be_kind_of(Saml2::Assertion)
    end

    it "should extract issuer from response" do 
      @resolver.resolve(@artifact).issuer.should == 'http://idp.invalid'
    end

  end

  describe "denied artifact resolution request" do 
    before do 
      @resolver = Saml2::ArtifactResolver.new('a-source-id', 'https://idp.invalid/resolution-service', 'http://idp.invalid', 'http://sp.invalid')
      @resolver.basic_auth_credentials('myuserid', 'mypasswd', 'myrealm')

      @artifact = Saml2::Type4Artifact.new(0, '01234567890123456789', 'abcdefghijklmnopqrst')
      FakeWeb.register_uri(:post, 'https://idp.invalid/resolution-service', :body => DENIED_SAML_RESP)
    end
  
    it "should raise exception" do
      lambda {
        @resolver.resolve(@artifact)
      }.should raise_error(Saml2::RequestDeniedError)
    end
  end


  SUCCESSFUL_SAML_RESP = <<-SAML_RESP
        <SOAP-ENV:Envelope
            xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
        <SOAP-ENV:Body>
          <ArtifactResponse
              ID="_423adb988f2673de74553f9f26ff27eda8af"
              InResponseTo="_gIPoW.YXQpZj17m.EpboPCp9cT"
              IssueInstant="2006-11-28T23:07:43.738+00:00"
              Version="2.0"
              xmlns="urn:oasis:names:tc:SAML:2.0:protocol">
            <ns1:Issuer xmlns:ns1="urn:oasis:names:tc:SAML:2.0:assertion">
              http://idp.invalid
            </ns1:Issuer>

            <Status>
              <StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success" />
            </Status>
  
            <Response
                Destination="https://service_provider/SAMLConsumer"
                ID="_dcfacebe4f2fca1cbdae749c5f5738995e0"
                IssueInstant="2006-11-28T23:04:32Z"
                Version="2.0">
              <ns2:Issuer
                  Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity"
                  xmlns:ns2="urn:oasis:names:tc:SAML:2.0:assertion">
                http://idp.invalid
              </ns2:Issuer>

              <Status>
                <StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success" />
              </Status>

              <ns3:Assertion
                  ID="_1ebc0cd2f88ade6396bccb22fc20a42792c4"
                  IssueInstant="2006-11-28T23:04:32Z"
                  Version="2.0"
                  xmlns:ns3="urn:oasis:names:tc:SAML:2.0:assertion">
                <ns3:Issuer
                    Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">
                  http://idp.invalid
                </ns3:Issuer>

                <ns3:Subject>
                  <ns3:NameID
                      Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">
                    12345678
                  </ns3:NameID>
                </ns3:Subject>

                <ns3:Conditions
                    NotBefore="2006-11-28T22:54:32Z"
                    NotOnOrAfter="2006-11-28T23:24:32Z">
                  <ns3:AudienceRestriction>
                    <ns3:Audience>https://sp.invalid</ns3:Audience>
                  </ns3:AudienceRestriction>
                </ns3:Conditions>

                <ns3:AuthnStatement
                    AuthnInstant="2006-11-28T23:03:14Z"
                    SessionIndex="MQSnyIps57sm2wRDKP+f9PsY+2A=nFfVrw=="
                    SessionNotOnOrAfter="2006-11-28T23:24:32Z">
                  <ns3:AuthnContext>
                    <ns3:AuthnContextClassRef>
                      urn:oasis:names:tc:SAML:2.0:ac:classes:Password
                    </ns3:AuthnContextClassRef>
                  </ns3:AuthnContext>
                </ns3:AuthnStatement>
            
                <ns3:AttributeStatement>
                  <ns3:Attribute
                      Name="cn"
                      NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
                    <ns3:AttributeValue>Smith, James</ns3:AttributeValue>
                  </ns3:Attribute>
                </ns3:AttributeStatement>
            
              </ns3:Assertion>
            </Response>
          </ArtifactResponse>
        </SOAP-ENV:Body>
        </SOAP-ENV:Envelope> 
      SAML_RESP
    
  DENIED_SAML_RESP = <<-SAML_RESP
        <SOAP-ENV:Envelope
            xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
        <SOAP-ENV:Body>
          <ArtifactResponse
              ID="_423adb988f2673de74553f9f26ff27eda8af"
              InResponseTo="_gIPoW.YXQpZj17m.EpboPCp9cT"
              IssueInstant="2006-11-28T23:07:43.738+00:00"
              Version="2.0"
              xmlns="urn:oasis:names:tc:SAML:2.0:protocol">
            <ns1:Issuer xmlns:ns1="urn:oasis:names:tc:SAML:2.0:assertion">
              https://idp.invalid
            </ns1:Issuer>

            <Status>
              <StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:RequestDenied" />
            </Status>
            </ArtifactResponse>
        </SOAP-ENV:Body>
        </SOAP-ENV:Envelope> 
      SAML_RESP

end


# Copyright (c) 2010 OpenLogic
#
# Licensed under MIT license.  See LICENSE.txt

