require 'spec_helper'
module Myrrha
  describe "Coercions#convert" do
    let(:graph){ Coercions.new }
    
    subject{ graph.send(:convert, "value", String, converter) }
      
    describe "when passed a proc of arity 2" do
      let(:converter){ lambda{|v,t| [v,t]} }
      it{ should eq(["value", String]) }
    end
      
    describe "when passed an object that respond to call" do
      let(:converter){ 
        o = Object.new
        def o.call(arg, t); [arg, t]; end
        o
      }
      it{ should eq(["value", String]) }
    end

  end
end