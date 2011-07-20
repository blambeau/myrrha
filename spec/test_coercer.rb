require File.expand_path('../spec_helper', __FILE__)
describe Coercer do
  
  it "should have a version number" do
    Coercer.const_defined?(:VERSION).should be_true
  end
  
  it "should provide the abitity to define a coercion graph" do
    graph = Coercer::Graph.new do |g|
      g.coercion String, Integer, lambda{|s,t| Integer(s)}
      g.coercion String, Float,   lambda{|s,t| Float(s)  }
    end
    graph.coerce(12,     Integer).should eq(12)
    graph.coerce("12",   Integer).should eq(12)
    graph.coerce(12.2,   Float).should   eq(12.2)
    graph.coerce("12.2", Float).should   eq(12.2) 
    graph.coerce("12",   Numeric).should eq(12)
    graph.coerce("12.2", Numeric).should eq(12.2)
    lambda{ 
      graph.coerce(true, Integer) 
    }.should raise_error(Coercer::Error, "Unable to coerce `true` to Integer")
    lambda{ 
      graph.coerce("12.2", Integer)
    }.should raise_error(Coercer::Error, "Unable to coerce `12.2` to Integer (invalid value for Integer: \"12.2\")")
  end
  
  it "should support all-catching rules" do
    graph = Coercer::Graph.new do |g|
      g.coercion String, Coercer::ANY, lambda{|s,t| :world}
    end
    graph.coerce("hello", Symbol).should eq(:world)
  end
  
end
