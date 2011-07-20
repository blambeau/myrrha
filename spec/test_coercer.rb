require File.expand_path('../spec_helper', __FILE__)
describe Coercer do
  
  it "should have a version number" do
    Coercer.const_defined?(:VERSION).should be_true
  end
  
end
