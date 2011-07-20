require 'spec_helper'
describe "Coercer::Ruby" do
  
  let(:graph){ Coercer::Ruby }
    
  specify "Integer" do
    # from Integer
    graph.coerce(12,     Integer).should eq(12)
    # from String
    graph.coerce("12",   Integer).should eq(12)
    graph.coerce("-12",  Integer).should eq(-12)
    graph.coerce("0",    Integer).should eq(0)
    # on error
    lambda{graph.coerce("abc",  Integer)}.should raise_error(Coercer::Error)
  end
  
  specify "Float" do
    # from Float
    graph.coerce(12.2,   Float).should eq(12.2)
    # from Integer
    graph.coerce(0,      Float).should eq(0.0)
    graph.coerce(12,     Float).should eq(12.0)
    graph.coerce(-12,    Float).should eq(-12.0)
    # from String
    graph.coerce("12.2", Float).should eq(12.2)
    graph.coerce("0",    Float).should eq(0.0)
    graph.coerce("0.0",  Float).should eq(0.0)
    graph.coerce("-12.2", Float).should eq(-12.2)
    # on error
    lambda{graph.coerce("abc",  Float)}.should raise_error(Coercer::Error)
  end
  
  specify "Numeric" do
    # from String
    graph.coerce("12",   Numeric).should eq(12)
    graph.coerce("12.2", Numeric).should eq(12.2)
  end
  
  specify "Boolean" do    
    # from Boolean
    graph.coerce(true,  Boolean).should eq(true)
    graph.coerce(false, Boolean).should eq(false)
    # from String
    graph.coerce("true",  Boolean).should eq(true)
    graph.coerce("false", Boolean).should eq(false)
    # on Error
    lambda{graph.coerce("abc", Boolean)}.should raise_error(Coercer::Error)
  end
  
  specify "Date" do
    #graph.coerce("2011/07/20", Date).should eq(Date.parse("2011-07-20"))
  end
      
end