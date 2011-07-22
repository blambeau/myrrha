require 'spec_helper'
module Myrrha
  describe "Coercions#append" do
    let(:rules){ Coercions.new }
    
    it "should return the rules" do
      rules.append{|r| }.should eq(rules)
    end
      

  end
end