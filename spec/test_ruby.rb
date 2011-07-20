require 'spec_helper'
describe "::Ruby's coercion " do
  
  describe "to Integer" do
    specify "from Integer" do
      coerce(12,     Integer).should eq(12)
    end
    specify "from String" do
      coerce("12",   Integer).should eq(12)
      coerce("-12",  Integer).should eq(-12)
      coerce("0",    Integer).should eq(0)
    end
    specify "on error" do
      lambda{coerce("abc",  Integer)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Float" do
    specify "from Float" do
      coerce(12.2,   Float).should eq(12.2)
    end
    specify "from Integer" do
      coerce(0,      Float).should eq(0.0)
      coerce(12,     Float).should eq(12.0)
      coerce(-12,    Float).should eq(-12.0)
    end
    specify "from String" do
      coerce("12.2", Float).should eq(12.2)
      coerce("0",    Float).should eq(0.0)
      coerce("0.0",  Float).should eq(0.0)
      coerce("-12.2", Float).should eq(-12.2)
    end
    specify "on error" do
      lambda{coerce("abc",  Float)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Numeric" do
    specify "from String" do
      coerce("12",   Numeric).should eq(12)
      coerce("12.2", Numeric).should eq(12.2)
    end
  end
  
  describe "to Boolean" do    
    specify "from Boolean" do
      coerce(true,  Boolean).should eq(true)
      coerce(false, Boolean).should eq(false)
    end
    specify "from String" do
      coerce("true",  Boolean).should eq(true)
      coerce("false", Boolean).should eq(false)
    end
    specify "on error" do
      lambda{coerce("abc", Boolean)}.should raise_error(Myrrha::Error)
    end
  end

  describe "to Date" do
    let(:expected){ Date.parse("2011-07-20") }
    specify "from String" do
      coerce("2011-07-20", Date).should eq(expected)
      coerce("2011/07/20", Date).should eq(expected)
    end
  end
      
  describe "to Time" do
    let(:expected){ Time.parse("2011-07-20 10:53") }
    specify "from String" do
      coerce("2011-07-20 10:53", Time).should eq(expected)
    end
  end
  
  describe "to Symbol" do
    specify "from Symbol" do
      coerce(:hello, Symbol).should eq(:hello)
    end
    specify "from String" do
      coerce("hello", Symbol).should eq(:hello)
    end
  end
  
  describe "to Regexp" do
    specify "from Regexp" do
      coerce(/[a-z]+/, Regexp).should eq(/[a-z]+/)
    end
    specify "from String" do
      coerce("[a-z]+", Regexp).should eq(/[a-z]+/)
    end
  end
  
  describe "to URI" do
    require 'uri'
    specify "from String" do
      coerce("http://www.google.com/", URI).should eq(URI.parse("http://www.google.com/"))
    end
  end

end