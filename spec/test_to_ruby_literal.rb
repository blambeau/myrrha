require 'spec_helper'
describe "to_ruby_literal" do

  it 'works on Symbols' do
    Myrrha::ToRubyLiteral.apply(:name).should eq(':name')
  end

  $VALUES.each do |value|
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