require 'spec_helper'
describe "to_ruby_literal" do

  SAFE_VALUES = {
    NilClass   => [ nil ],
    TrueClass  => [ true ],
    FalseClass => [ false ],
    Fixnum     => [ -(2**(0.size * 8 - 2)), -1, 0, 1, 10, (2**(0.size * 8 - 2) - 1)],
    Bignum     => [ -(2**(0.size * 8 - 2)) - 1, (2**(0.size * 8 - 2)) ],
    Float      => [ -0.10, 0.0, 0.10 ],
    String     => ['', 'hello'],
    Symbol     => [ :hello, :"s-b-y-c", :"12" ],
    Class      => [ Integer, ::Struct::Tms ],
    Module     => [ Kernel, Myrrha ],
    Regexp     => [ /a-z/, /^$/, /\s*/, /[a-z]{15}/ ],
    Range      => [ 0..10, 0...10 ],
    Array      => [ [], [nil], [1, "hello"] ],
    Hash       => [ {}, {1 => 2, :hello => "world"} ]
  }.values.inject([], :+)
  
  UNSAFE_VALUES = {
    Date  => [ Date.today ],
    Time  => [ Time.now   ],
    Array => [ [Date.today, Time.now] ],
    Hash  => [ {Date.today => Time.now} ]
  }.values.inject([], :+)
  
  (SAFE_VALUES + UNSAFE_VALUES).each do |value|
    describe "on #{value.inspect}" do
      specify{ Kernel.eval(value.to_ruby_literal).should eq(value) }  
    end
  end

end