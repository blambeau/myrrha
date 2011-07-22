require 'spec_helper'
describe "Ruby assumptions" do
  
  describe "Proc#arity" do
    specify{
      lambda{|a| }.arity.should eq(1)
      lambda{|a,b| }.arity.should eq(2)
    }
  end
  
  class Object
    def no_such_myrrha_method
    end
  end if false
  
  specify{ Object.should_not respond_to(:no_such_myrrha_method) }
  
end