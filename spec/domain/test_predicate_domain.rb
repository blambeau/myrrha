require 'spec_helper'
module Myrrha
  class Domain
    describe PredicateDomain do
      
      specify "name" do
        PredicateDomain.new(:test, nil, nil).name.should eq(:test)
      end
      
      specify "is_value? with a proc of arity 1" do
        seen = nil
        PredicateDomain.new(:test, nil, lambda{|s| seen=12; s==12}).
                        is_value?(12).should be_true
        seen.should eq(12)
      end
      
      specify "is_value? with a proc of arity 2" do
        seen = nil
        PredicateDomain.new(:test, nil, lambda{|s,t| seen=[s,t]; s==12}).
                        is_value?(12, :hello).should be_true
        seen.should eq([12,:hello])
      end

      specify "is_value? with a object that respond to call" do
        obj = Object.new
        def obj.call(v); v == 12; end
        PredicateDomain.new(:test, nil, obj).
                        is_value?(12).should be_true
      end
      
      specify "subdomain_of?" do
        d1 = PredicateDomain.new(nil, nil, nil)
        d2 = PredicateDomain.new(nil, d1, nil)
        d1.subdomain_of?(d1).should be_true
        d2.subdomain_of?(d1).should be_true
        d2.subdomain_of?(d2).should be_true
        d1.subdomain_of?(d2).should be_false
      end
      
    end
  end
end