require 'spec_helper'
describe "Myrrha.coercions" do
  
  it "should support using user-defined domains" do
    name = Myrrha.domain(:Name){|s| s.is_a?(Symbol)}
    rules = Myrrha.coercions do |r|
      r.coercion String, name, lambda{|s,t| s.to_sym}
      r.coercion name, String, lambda{|s,t| s.to_s}
    end
    rules.coerce("hello", name).should eq(:hello)
    rules.coerce(:hello, String).should eq("hello")
  end
  
  it "should support the inline definition of user domains" do
    name = nil
    rules = Myrrha.coercions do |r|
      name = r.domain(:Name){|s| s.is_a?(Symbol)}
      r.coercion String, name, lambda{|s,t| s.to_sym}
    end
    rules.coerce("hello", name).should eq(:hello)
  end
  
end