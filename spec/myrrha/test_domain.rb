require 'spec_helper'
module Myrrha
  describe "#domain" do
    
    describe "with only a predicate" do
      subject{ Myrrha.domain{|s| s == 12} }
      specify{ 
        subject.should be_a(Class) 
        subject.superclass.should eq(Object)
        (subject === 12).should be_true
        (subject === 13).should be_false
      }
    end
    
    describe "with a super domain and a predicate" do
      subject{ Myrrha.domain(Integer){|i| i > 0} }
      specify{ 
        subject.should be_a(Class) 
        subject.superclass.should eq(Integer)
        (subject === 12).should be_true
        (subject === 0).should be_false
      }
    end
    
    specify "when affected to a constant" do
      PosInt = Myrrha.domain(Integer){|i| i > 0}
      PosInt.name.should eq("Myrrha::PosInt")
    end
    
    describe ".new" do

      specify "when call to super is not required" do
        posint = Myrrha.domain(Integer){|i| i > 0}
        posint.new(12).should eq(12)
        lambda {
          posint.new(0)
        }.should raise_error(ArgumentError)
      end
      
      specify "when call to super is required" do
        class Color
          attr_reader :r
          attr_reader :g
          attr_reader :b
          def initialize(r,g,b)
            @r, @g, @b = r, g, b
          end
        end
        RedToZero = Myrrha.domain(Color){|c| c.r == 0}
        (RedToZero === Color.new(0,1,1)).should be_true
        (RedToZero === Color.new(1,1,1)).should be_false
        RedToZero.new(0, 1, 1).should be_a(Color)
        lambda{
          RedToZero.new(1, 1, 1)
        }.should raise_error(ArgumentError)
      end
      
    end
    
  end
end
