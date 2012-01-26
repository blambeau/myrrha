require 'spec_helper'
module Myrrha
  describe "Coercions#dup" do
    let(:rules){ Coercions.new{|r|
      r.coercion String, Integer, lambda{|s,t| Integer(s) }
      r.coercion Array,  Integer, lambda{|s,t|
        s.inject(0){|sum,x| sum + r.apply(x,t)}
      }
    }}

    it "should duplicate the rules" do
      rules.dup.coerce("12", Integer).should eql(12)
      rules.dup.coerce(["12", "10"], Integer).should eql(22)
    end

    it "should not touch the original" do
      dupped = rules.dup.append do |r|
        r.coercion String, Float, lambda{|s,t| Float(s)}
      end
      dupped.coerce("12", Float).should eql(12.0)
      lambda{ rules.coerce("12", Float) }.should raise_error(Myrrha::Error)
    end

    it "should not forget main_target_domain" do
      rules = Coercions.new do |r|
        r.main_target_domain = Integer
      end
      rules.dup.main_target_domain.should eql(Integer)
    end

    it 'should apply inheritance in a intuitive way' do
      dupped = rules.dup.append do |r|
        r.coercion Float, Integer, lambda{|s,t| s.round}
      end
      dupped.coerce(12.15, Integer).should eq(12)
      dupped.coerce([12.15, 10], Integer).should eq(22)
    end

  end
end
