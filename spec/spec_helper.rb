$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'myrrha/with_core_ext'
require 'myrrha/coerce'
require 'myrrha/to_ruby_literal'
require 'date'
require 'shared/a_value'

unless defined?(SAFE_VALUES)
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
  }
  UNSAFE_VALUES = {
    Date  => [ Date.today ],
    Time  => [ Time.now   ],
    Array => [ [Date.today, Time.now] ],
    Hash  => [ {Date.today => Time.now} ],
    Range => [ Date.today..(Date.today+1) ]
  }
  VALUES = SAFE_VALUES.values.inject([], :+) + UNSAFE_VALUES.values.inject([], :+)
end