require 'spec_helper'
module Myrrha
  describe "#domain" do
    
    specify "the basic contract" do
      subject = Myrrha.domain{|s| s == 12}
      subject.should be_a(Class) 
      subject.superclass.should eq(Object)
      (subject === 12).should be_true
      (subject === 13).should be_false
    end
    
    specify "with a ruby superclass" do
      subject = Myrrha.domain(Integer){|i| i > 0}
      subject.should be_a(Class) 
      subject.superclass.should eq(Integer)
      (subject === 12).should be_true
      (subject === 0).should be_false
    end
    
    describe "A factored sub domain of Integer" do
      PosInt = Myrrha.domain(Integer){|i| i > 0}
      specify("#name") {
        PosInt.name.should eq("Myrrha::PosInt")
      }
      specify("#new") {
        PosInt.new(12).should eq(12)
        lambda {
          PosInt.new(0)
        }.should raise_error(ArgumentError)
      }
      specify("#superclass"){
        PosInt.superclass.should eql(Integer)
      }
      specify("#superdomain_of?"){
        PosInt.superdomain_of?(Object).should be_false
        PosInt.superdomain_of?(Integer).should be_false
      }
      it "should be usable in a case" do
        [-12, 12].collect{|i|
          case i
          when PosInt
            :posint
          when Integer
            :integer
          end
        }.should eq([:integer, :posint])
      end
    end
      
    describe "A factored sub domain of a user-defined Class" do
      class Color
        attr_reader :r
        attr_reader :g
        attr_reader :b
        def initialize(r,g,b)
          raise ArgumentError unless [r,g,b].all?{|i| i.is_a?(Integer)}
          @r, @g, @b = r, g, b
        end
      end
      RedToZero = Myrrha.domain(Color){|c| c.r == 0}
      specify("#===") {
        (RedToZero === Color.new(0,1,1)).should be_true
        (RedToZero === Color.new(1,1,1)).should be_false
      }
      specify("#new") {
        RedToZero.new(Color.new(0,1,1)).should be_a(Color)
        RedToZero.new(0, 1, 1).should be_a(Color)
        lambda{
          RedToZero.new(Color.new(1,1,1))
        }.should raise_error(ArgumentError)
        lambda{
          RedToZero.new(1, 1, 1)
        }.should raise_error(ArgumentError)
      }
    end
    
  end
end
