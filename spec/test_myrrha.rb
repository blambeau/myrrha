require File.expand_path('../spec_helper', __FILE__)
describe Myrrha do
  
  it "should have a version number" do
    Myrrha.const_defined?(:VERSION).should be_true
  end
  
  it "should provide the abitity to define a coercion graph" do
    graph = Myrrha::Graph.new do |g|
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
    }.should raise_error(Myrrha::Error, "Unable to coerce `true` to Integer")
    lambda{ 
      graph.coerce("12.2", Integer)
    }.should raise_error(Myrrha::Error, /^Unable to coerce `12.2` to Integer \(invalid value /)
  end
  
  it "should support all-catching rules" do
    graph = Myrrha::Graph.new do |g|
      g.coercion String, Myrrha::ANY, lambda{|s,t| :world}
    end
    graph.coerce("hello", Symbol).should eq(:world)
  end
  
  it "should support using matchers" do
    ArrayOfSymbols = proc{|val| val.is_a?(Array) && val.all?{|x| Symbol===x}}
    graph = Myrrha::Graph.new do |g|
      g.coercion ArrayOfSymbols, String, lambda{|x,t| x.join(', ')}
    end
    graph.coerce([:a, :b], ArrayOfSymbols).should eq([:a, :b])
    graph.coerce([:a, :b], String).should eq("a, b")
  end
  
  it "should support using any object that respond to call as converter" do
    converter = Object.new
    def converter.call(arg, t); arg.to_sym; end
    graph = Myrrha::Graph.new do |g|
      g.coercion String, Symbol, converter
    end
    graph.coerce("hello", Symbol).should eq(:hello)
  end
  
  it "should support using a class a converter" do
    class Foo
      attr_reader :arg
      def initialize(arg); @arg = arg; end
      def ==(other); other.is_a?(Foo) && (other.arg==arg); end
    end
    graph = Myrrha::Graph.new do |g|
      g.coercion String, Foo, Foo
    end
    graph.coerce("hello", Foo).should eq(Foo.new("hello"))
  end
  
end
