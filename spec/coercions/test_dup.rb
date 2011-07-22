require 'spec_helper'
module Myrrha
  describe "Coercions#dup" do
    let(:rules){ Coercions.new{|r|
      r.coercion String, Integer, lambda{|s,t| Integer(s)}
    }}
    
    it "should duplicate the rules" do
      rules.dup.coerce("12", Integer).should eql(12)
    end
    
    it "should not touch the original" do
      dupped = rules.dup.append do |r|
        r.coercion String, Float, lambda{|s,t| Float(s)}
      end
      dupped.coerce("12", Float).should eql(12.0)
      lambda{ rules.coerce("12", Float) }.should raise_error(Myrrha::Error)
    end
      
  end
end