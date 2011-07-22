require 'spec_helper'
describe "::Ruby's coercion " do
  
  describe "from NilClass" do
    it "should always return nil" do
      coercion(nil, Integer).should be_nil
      coercion(nil, Date).should be_nil
    end
  end
  
  describe "to Integer" do
    specify "from Integer" do
      coercion(12,     Integer).should eq(12)
    end
    specify "from String" do
      coercion("12",   Integer).should eq(12)
      coercion("-12",  Integer).should eq(-12)
      coercion("0",    Integer).should eq(0)
    end
    specify "on error" do
      lambda{coercion("abc",  Integer)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Float" do
    specify "from Float" do
      coercion(12.2,   Float).should eq(12.2)
    end
    specify "from Integer" do
      coercion(0,      Float).should eq(0.0)
      coercion(12,     Float).should eq(12.0)
      coercion(-12,    Float).should eq(-12.0)
    end
    specify "from String" do
      coercion("12.2", Float).should eq(12.2)
      coercion("0",    Float).should eq(0.0)
      coercion("0.0",  Float).should eq(0.0)
      coercion("-12.2", Float).should eq(-12.2)
    end
    specify "on error" do
      lambda{coercion("abc",  Float)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Numeric" do
    specify "from String" do
      coercion("12",   Numeric).should eq(12)
      coercion("12.2", Numeric).should eq(12.2)
    end
  end
  
  describe "to Boolean" do    
    specify "from Boolean" do
      coercion(true,  Boolean).should eq(true)
      coercion(false, Boolean).should eq(false)
    end
    specify "from String" do
      coercion("true",  Boolean).should eq(true)
      coercion("false", Boolean).should eq(false)
    end
    specify "on error" do
      lambda{coercion("abc", Boolean)}.should raise_error(Myrrha::Error)
    end
  end

  describe "to Date" do
    let(:expected){ Date.parse("2011-07-20") }
    specify "from String" do
      coercion("2011-07-20", Date).should eq(expected)
      coercion("2011/07/20", Date).should eq(expected)
    end
  end
      
  describe "to Time" do
    let(:expected){ Time.parse("2011-07-20 10:53") }
    specify "from String" do
      coercion("2011-07-20 10:53", Time).should eq(expected)
    end
  end
  
  describe "to Symbol" do
    specify "from Symbol" do
      coercion(:hello, Symbol).should eq(:hello)
    end
    specify "from String" do
      coercion("hello", Symbol).should eq(:hello)
    end
  end
  
  describe "to Regexp" do
    specify "from Regexp" do
      coercion(/[a-z]+/, Regexp).should eq(/[a-z]+/)
    end
    specify "from String" do
      coercion("[a-z]+", Regexp).should eq(/[a-z]+/)
    end
  end
  
  describe "to URI" do
    require 'uri'
    specify "from String" do
      coercion("http://www.google.com/", URI).should eq(URI.parse("http://www.google.com/"))
    end
  end

end