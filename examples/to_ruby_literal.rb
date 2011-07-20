require File.expand_path('../examples_helper', __FILE__)
require 'date'
require 'time'

#
# This example shows how to simply implement a missing feature of 
# Ruby, namely Object#to_ruby_literal.
#
# Object#to_ruby_literal has a very simple specification. Provided an
# object o that can be considered as a true _value_, the result of 
# o.to_ruby_literal must be such that the following invariant holds:
#
#   Kernel.eval(o.to_ruby_literal) == o 
#
# That is, parsing & evaluating the literal yields the same value. 
#
# For almost all ruby classes, but not all, using o.inspect is safe.
# For example, you can check that the following is true:
# 
#   Kernel.eval("hello".inspect) == "hello"
#   # => true
#
# Unfortunately, this is not always the case:
#
#   Kernel.eval(Date.today.inspect) == Date.today
#   # => false (because Date.today.inspect yields "#<Date: 2011-07-20 ...")
#
# We show below how to implement this using Myrrha in a simple, flexible,
# way ... without much code or core extensions.
#

# These are all classes for which using inspect is safe
INSPECT_SAFE = [ NilClass, TrueClass, FalseClass, Fixnum, Bignum, Float, 
  String, Symbol, Class, Module, Regexp ]

#
# These are the Myrrha rules
#   - we rely on inspect for safe classes
#   - we fallback to Marshal otherwise 
#
rules = Myrrha.coercions do |r|
  safe = lambda{|x| INSPECT_SAFE.include?(x.class)}
  r.coercion(safe, :to_ruby_literal) do |s,t| 
    s.inspect
  end
  r.fallback(Object) do |s,t| 
    "Marshal.load(#{Marshal.dump(s).inspect})"
  end
end

# Have a look at this!
puts rules.coerce(1, :to_ruby_literal)
puts rules.coerce(Date.today, :to_ruby_literal)

#
# You can even override the default Marshal behavior later, 
# providing a friendly extension point to your users. 
#
rules.append do |r|
  r.coercion Date, :to_ruby_literal do |s,t|
    "Date.parse(#{s.to_s.inspect})"
  end
end
puts rules.coerce(Date.today, :to_ruby_literal)

#
# this is for testing purposes
#

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
  Regexp     => [ /a-z/, /^$/, /\s*/, /[a-z]{15}/ ]
}.values.inject([], :+)

UNSAFE_VALUES = {
  Date => [ Date.today ],
  Time => [ Time.now   ]
}.values.inject([], :+)

(SAFE_VALUES + UNSAFE_VALUES).each do |value|
  Kernel.eval(rules.coerce(value, :to_ruby_literal)).should eq(value)
end

