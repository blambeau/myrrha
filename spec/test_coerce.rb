require 'spec_helper'
describe "::Ruby's coercion " do
  
  describe "from NilClass" do
    it "should always return nil" do
      coerce(nil, Integer).should be_nil
      coerce(nil, Date).should be_nil
    end
  end
  
  describe "to String" do
    specify "from Integer" do
      coerce(12,     String).should eql("12")
    end
    specify "from String" do
      coerce("12",   String).should eql("12")
    end
    specify "from NilClass" do
      coerce(nil,   String).should be_nil
    end
  end
  
  describe "to Integer" do
    specify "from Integer" do
      coerce(12,     Integer).should eql(12)
    end
    specify "from String" do
      coerce("12",   Integer).should eql(12)
      coerce("-12",  Integer).should eql(-12)
      coerce("0",    Integer).should eql(0)
    end
    specify "on error" do
      lambda{coerce("abc",  Integer)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Float" do
    specify "from Float" do
      coerce(12.2,   Float).should eql(12.2)
    end
    specify "from Integer" do
      coerce(0,      Float).should eql(0.0)
      coerce(12,     Float).should eql(12.0)
      coerce(-12,    Float).should eql(-12.0)
    end
    specify "from String" do
      coerce("12.2", Float).should eql(12.2)
      coerce("0",    Float).should eql(0.0)
      coerce("0.0",  Float).should eql(0.0)
      coerce("-12.2", Float).should eql(-12.2)
    end
    specify "on error" do
      lambda{coerce("abc",  Float)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Numeric" do
    specify "from String" do
      coerce("12",   Numeric).should eql(12)
      coerce("12.2", Numeric).should eql(12.2)
    end
  end
  
  describe "to Boolean" do    
    specify "from Boolean" do
      coerce(true,  Boolean).should eql(true)
      coerce(false, Boolean).should eql(false)
    end
    specify "from String" do
      coerce("true",  Boolean).should eql(true)
      coerce("false", Boolean).should eql(false)
    end
    specify "on error" do
      lambda{coerce("abc", Boolean)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to TrueClass" do
    specify "from String" do
      coerce("true", TrueClass).should eql(true)
      lambda{ coerce("false", TrueClass) }.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to FalseClass" do
    specify "from String" do
      coerce("false", FalseClass).should eql(false)
      lambda{ coerce("true", FalseClass) }.should raise_error(Myrrha::Error)
    end
  end

  describe "to Date" do
    let(:expected){ Date.parse("2011-07-20") }
    specify "from String" do
      coerce("2011-07-20", Date).should eql(expected)
      coerce("2011/07/20", Date).should eql(expected)
    end
  end
      
  describe "to Time" do
    let(:expected){ Time.parse("2011-07-20 10:53") }
    specify "from String" do
      coerce("2011-07-20 10:53", Time).should eql(expected)
    end
  end
  
  describe "to Symbol" do
    specify "from Symbol" do
      coerce(:hello, Symbol).should eql(:hello)
    end
    specify "from String" do
      coerce("hello", Symbol).should eql(:hello)
    end
  end
  
  describe "to Regexp" do
    specify "from Regexp" do
      coerce(/[a-z]+/, Regexp).should eql(/[a-z]+/)
    end
    specify "from String" do
      coerce("[a-z]+", Regexp).should eql(/[a-z]+/)
    end
  end
  
  describe "to URI" do
    require 'uri'
    specify "from String" do
      coerce("http://www.google.com/", URI).should eql(URI.parse("http://www.google.com/"))
    end
  end

  describe "to Module" do
    specify "from String" do
      coerce("Kernel", Module).should eql(Kernel)
      coerce("::Kernel", Module).should eql(Kernel)
      coerce("Myrrha::Version", Module).should eql(Myrrha::Version)
      coerce("::Myrrha::Version", Module).should eql(Myrrha::Version)
      coerce("Myrrha::Coercions", Module).should eql(Myrrha::Coercions)
    end
    specify "from Symbol" do
      coerce(:Kernel, Module).should eql(Kernel)
    end
    it "should raise error if not a module" do
      lambda{
        coerce("Myrrha::VERSION", Module)
      }.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Class" do
    specify "from String" do
      coerce("Myrrha::Coercions", Class).should eql(Myrrha::Coercions)
    end
    specify "from Symbol" do
      coerce(:Integer, Class).should eql(Integer)
    end
    it "should raise error if not a module" do
      lambda{
        coerce("Myrrha::Version", Class)
      }.should raise_error(Myrrha::Error)
    end
  end
  
  specify "to a class that respond to coerce" do
    class Coerceable
      def self.coerce(val)
        [:coerced, val]
      end
    end
    coerce("hello", Coerceable).should eq([:coerced, "hello"])
  end
  
  specify "otherwise" do
    lambda{ coerce("hallo", Myrrha) }.should raise_error(Myrrha::Error)
  end

end