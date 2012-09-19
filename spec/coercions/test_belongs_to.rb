require 'spec_helper'
module Myrrha
  describe "Coercions#belongs_to?" do
    let(:rules){ Coercions.new }

    before(:all) do
      class Coercions
        public :belongs_to?
      end
    end

    specify "with a class" do
      rules.belongs_to?(12, Integer).should be_true
    end

    specify "with a superclass" do
      rules.belongs_to?(12, Numeric).should be_true
    end

    specify "with a proc or arity 1" do
      rules.belongs_to?(12, lambda{|x| x>10}).should be_true
      rules.belongs_to?(12, lambda{|x| x<10}).should be_false
    end

    specify "with a proc or arity 2" do
      got = nil
      l = lambda{|x,t| got = t; t == l }
      rules.belongs_to?(12, l).should be_true
      got.should eq(l)
      rules.belongs_to?(12, l, :nosuch).should be_false
      got.should eq(:nosuch)
    end

  end
end
