require 'spec_helper'
describe "Myrrha.coercions" do
  
  it "should support using user-defined domains" do
    name = Myrrha.domain(:Name){|s| s.is_a?(Symbol)}
    rules = Myrrha.coercions do |r|
      r.coercion String, name, lambda{|s,t| s.to_sym}
    end
    rules.coerce("hello", name).should eq(:hello)
  end
  
end