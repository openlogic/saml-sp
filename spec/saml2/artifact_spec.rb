require File.join(File.dirname(__FILE__), '../spec_helper')

describe Saml2::Artifact do 
  describe "parsing unknown type" do 
    before do 
      # unencoded artifact: "\000\052\000\030test"
      @artifact = Saml2::Artifact.parse "ACoAGHRlc3Q=" 
    end

    it "should know its type code" do 
      @artifact.type_code.should == 42
    end

    it "should know its endpoint index" do 
      @artifact.endpoint_index.should == 24
    end

    it "should know its content" do 
      @artifact.content.should == 'test'
    end
    
    it "should not respond to source_id" do 
      @artifact.should_not respond_to(:source_id)
    end

    it "should not respond to message_handle" do 
      @artifact.should_not respond_to(:message_handle)
    end
  end

  describe "parsing type 4" do 
    before do
      # unencoded artifact: "\000\004\000\00001234567890123456789abcdefghijklmnopqrst"
      @artifact = Saml2::Artifact.parse "AAQAADAxMjM0NTY3ODkwMTIzNDU2Nzg5YWJjZGVmZ2hpamtsbW5vcHFyc3Q=" 
    end

    it "should know its type code" do 
      @artifact.type_code.should == 4
    end

    it "should know its endpoint index" do 
      @artifact.endpoint_index.should == 0
    end

    it "should know its content" do 
      @artifact.content.should == '01234567890123456789abcdefghijklmnopqrst'
    end

    it "should know the source id" do 
      @artifact.source_id.should == '01234567890123456789'
    end

    it "should know the message handle" do 
      @artifact.message_handle.should == 'abcdefghijklmnopqrst'
    end
  end
end
