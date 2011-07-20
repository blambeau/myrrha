require File.expand_path('../spec_helper', __FILE__)
describe Coercer do
  
  it "should have a version number" do
    Coercer.const_defined?(:VERSION).should be_true
  end
  
  it "should provide the abitity to define a coercion graph" do
    graph = Coercer::Graph.new do |g|
      g.coercion String, Integer, lambda{|s| Integer(s)}
      g.coercion String, Float,   lambda{|s| Float(s)  }
    end
    graph.coerce("12",   Integer).should == 12
    graph.coerce("12.2",   Float).should == 12.2
    #graph.coerce("12",   Numeric).should == 12
    #graph.coerce("12.2", Numeric).should == 12.2
    lambda{ graph.coerce(true, Integer) }.should raise_error(Coercer::Error)
    lambda{ graph.coerce(true, String)  }.should raise_error(Coercer::Error)
  end
  
end
