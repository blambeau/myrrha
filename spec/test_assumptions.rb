require 'spec_helper'
describe "Ruby assumptions" do
  
  describe "Proc#arity" do
    specify{
      lambda{|a| }.arity.should eq(1)
      lambda{|a,b| }.arity.should eq(2)
    }
  end
  
end