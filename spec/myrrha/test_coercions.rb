require 'spec_helper'
describe "Myrrha.coercions" do
  
  it "should support using user-defined domains" do
    name = Myrrha::Domain.sbyc{|s| s.is_a?(Symbol)}
    rules = Myrrha.coercions do |r|
      r.coercion String, name, lambda{|s,t| s.to_sym}
      r.coercion name, String, lambda{|s,t| s.to_s}
    end
    rules.coerce("hello", name).should eq(:hello)
    rules.coerce(:hello, String).should eq("hello")
  end
  
end