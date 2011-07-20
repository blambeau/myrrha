require 'spec_helper'
describe "::Ruby's coercion " do
  
  let(:graph){ Myrrha::Ruby }
    
  describe "to Integer" do
    specify "from Integer" do
      graph.coerce(12,     Integer).should eq(12)
    end
    specify "from String" do
      graph.coerce("12",   Integer).should eq(12)
      graph.coerce("-12",  Integer).should eq(-12)
      graph.coerce("0",    Integer).should eq(0)
    end
    specify "on error" do
      lambda{graph.coerce("abc",  Integer)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Float" do
    specify "from Float" do
      graph.coerce(12.2,   Float).should eq(12.2)
    end
    specify "from Integer" do
      graph.coerce(0,      Float).should eq(0.0)
      graph.coerce(12,     Float).should eq(12.0)
      graph.coerce(-12,    Float).should eq(-12.0)
    end
    specify "from String" do
      graph.coerce("12.2", Float).should eq(12.2)
      graph.coerce("0",    Float).should eq(0.0)
      graph.coerce("0.0",  Float).should eq(0.0)
      graph.coerce("-12.2", Float).should eq(-12.2)
    end
    specify "on error" do
      lambda{graph.coerce("abc",  Float)}.should raise_error(Myrrha::Error)
    end
  end
  
  describe "to Numeric" do
    specify "from String" do
      graph.coerce("12",   Numeric).should eq(12)
      graph.coerce("12.2", Numeric).should eq(12.2)
    end
  end
  
  describe "to Boolean" do    
    specify "from Boolean" do
      graph.coerce(true,  Boolean).should eq(true)
      graph.coerce(false, Boolean).should eq(false)
    end
    specify "from String" do
      graph.coerce("true",  Boolean).should eq(true)
      graph.coerce("false", Boolean).should eq(false)
    end
    specify "on error" do
      lambda{graph.coerce("abc", Boolean)}.should raise_error(Myrrha::Error)
    end
  end

  describe "to Date" do
    let(:expected){ Date.parse("2011-07-20") }
    specify "from String" do
      graph.coerce("2011-07-20", Date).should eq(expected)
      graph.coerce("2011/07/20", Date).should eq(expected)
    end
  end
      
  describe "to Time" do
    let(:expected){ Time.parse("2011-07-20 10:53") }
    specify "from String" do
      graph.coerce("2011-07-20 10:53", Time).should eq(expected)
    end
  end

end