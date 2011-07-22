require 'spec_helper'
describe "to_ruby_literal" do

  VALUES.each do |value|
    describe "on #{value.inspect}" do
      specify{ Kernel.eval(value.to_ruby_literal).should eq(value) }  
    end
  end
  
end