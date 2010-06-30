require File.join(File.dirname(__FILE__), '../spec_helper')

describe Saml2::Type4Artifact do 
  describe "parsing wrong type" do 
    it "should raise error" do 
      lambda {
        # unencoded artifact: "\000\052\000\030test"
        Saml2::Type4Artifact.new_from_string "ACoAGHRlc3Q=" 
      }.should raise_error UnexpectedTypeCodeError
    end

    it "should have meaningful message" do 
      lambda {
        # unencoded artifact: "\000\052\000\030test"
        Saml2::Type4Artifact.new_from_string "ACoAGHRlc3Q=" 
      }.should raise_error(/incorrect artifact type.*expected.*4.*found.*42/i)
    end

  end

  describe "parsing type 4" do 
    before do
      # unencoded artifact: "\000\004\000\00001234567890123456789abcdefghijklmnopqrst"
      @artifact = Saml2::Type4Artifact.new_from_string "AAQAADAxMjM0NTY3ODkwMTIzNDU2Nzg5YWJjZGVmZ2hpamtsbW5vcHFyc3Q=" 
    end

    it "should know its type code" do 
      @artifact.type_code.should == 4
    end

    it "should know its endpoint index" do 
      @artifact.endpoint_index.should == 0
    end

    it "should know the source id" do 
      @artifact.source_id.should == '01234567890123456789'
    end

    it "should know the message handle" do 
      @artifact.message_handle.should == 'abcdefghijklmnopqrst'
    end
  end

  describe "simple artifact" do 
    before do 
      @resolver = Saml2::ArtifactResolver.new('01234567890123456789', 'http://idp.invalid/artifact-resolver', 'http://idp.invalid/', 'http://sp.invalid/')

      @artifact = Saml2::Type4Artifact.new(0, '01234567890123456789', 'abcdefghijklmnopqrst')
    end

    it "should be able to render itself to a string" do 
      @artifact.to_s.should == "AAQAADAxMjM0NTY3ODkwMTIzNDU2Nzg5YWJjZGVmZ2hpamtsbW5vcHFyc3Q=" 
    end

    it "should be able to resolve itself" do 
      @resolver.should_receive(:resolve).with(@artifact).and_return(:assertion_marker)
      @artifact.resolve.should == :assertion_marker
    end
  end
end


# Licensed under MIT license.  See README.txt for details.
