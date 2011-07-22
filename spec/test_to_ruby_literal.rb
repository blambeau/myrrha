require 'spec_helper'
describe "to_ruby_literal" do

  VALUES.each do |value|
    describe "on #{value.inspect}" do
      specify{ Kernel.eval(value.to_ruby_literal).should eq(value) }  
    end
  end
  
  it "should work on objects that implement to_ruby_literal" do
    class ToRubyLiteralizable
      def to_ruby_literal
        :foo
      end
    end
    Myrrha.to_ruby_literal(ToRubyLiteralizable.new).should eq(:foo)
  end
  
end