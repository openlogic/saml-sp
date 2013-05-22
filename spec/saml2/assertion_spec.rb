require File.join(File.dirname(__FILE__), '../spec_helper')

describe Saml2::Assertion do 
  describe "w/ 2 attributes" do 
    before do 
      @assertion = Saml2::Assertion.new('http://idp.invalid', 'abcd', 'this' => 'that', 'foo' => 'bar')
    end

    it "should provide read access for issuer" do 
      @assertion.issuer.should == 'http://idp.invalid'
    end

    it "should provide read access to subject name id" do 
      @assertion.subject_name_id.should == 'abcd'
    end

    it "should provide read access to attributes ('this')" do 
      @assertion['this'].should == 'that'
    end

    it "should provide read access to attributes (:this)" do 
      @assertion[:this].should == 'that'
    end

    it "should provide read access to attributes ('foo')" do 
      @assertion['foo'].should == 'bar'
    end

    it "should provide read access to attributes (:foo)" do 
      @assertion[:foo].should == 'bar'
    end
  end

  describe "instantiation" do 
    it 'should be creatable from artifact string' do 
      mock_artifact = mock('artifact', :resolve => :assertion_marker)
      Saml2::Type4Artifact.should_receive(:new_from_string).with('artifact_marker').and_return(mock_artifact)

      Saml2::Assertion.new_from_artifact("artifact_marker").should == :assertion_marker
    end

    it 'should be creatable from a type 4 artifact' do 
      artifact = Saml2::Type4Artifact.new(0, 'a-source-id', 'http://idp.invalid/')
      artifact.should_receive(:resolve).and_return(:assertion_marker)

      Saml2::Assertion.new_from_artifact(artifact).should == :assertion_marker
    end
  end

  describe "parsing" do 
    before do 
      @assertion_xml = <<-XML
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
                https://idp.invalid
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
                  https://idp.invalid
                </ns3:Issuer>

                <ns3:Subject>
                  <ns3:NameID
                      Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">
                    12345678
                  </ns3:NameID>

                  <ns3:SubjectConfirmation
                      Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
                    <ns3:SubjectConfirmationData
                        NotOnOrAfter="2006-11-28T23:24:32Z"
                        Recipient="https://sp.invalid/SAMLConsumer"/>
                  </ns3:SubjectConfirmation>
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
            
                  <ns3:Attribute
                      Name="email"
                      NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
                    <ns3:AttributeValue>james.smith@idp.invalid</ns3:AttributeValue>
                  </ns3:Attribute>
            
                </ns3:AttributeStatement>
            
              </ns3:Assertion>
            </Response>
          </ArtifactResponse>
        </SOAP-ENV:Body>
        </SOAP-ENV:Envelope> 
      XML

      # register issuer which doesn't require verification
      Saml2::Issuer.new('https://idp.invalid', false)
    end

    def self.it_should_extract(prop, expected_value)
      eval(<<-EXAMPLE)
        it "should extract #{prop}" do 
          Saml2::Assertion.new_from_xml(@assertion_xml).#{prop}.should == #{expected_value.inspect}
        end
      EXAMPLE
    end

    it_should_extract :issuer, 'https://idp.invalid'
    it_should_extract :subject_name_id, '12345678'
    
    it "should extract attributes (cn)" do 
      Saml2::Assertion.new_from_xml(@assertion_xml)['cn'].should == 'Smith, James'
    end

    it "should extract attributes (email)" do 
      Saml2::Assertion.new_from_xml(@assertion_xml)['email'].should == 'james.smith@idp.invalid'
    end
  end

end


# Copyright (c) 2010 OpenLogic
#
# Licensed under MIT license.  See LICENSE.txt

