require File.expand_path('../examples_helper', __FILE__)
require 'date'

# In many cases, arguments coming from the user (in console mode, in web,
# and so on) are Strings, that must be converted to other types: numerics,
# booleans, and so on.
#
# The String class could be extended with to_Integer, to_Float, to_Date, 
# to_Time and so on, but this is not a good idea... for obvious reasons.
#
# With Myrrha, building a set of rules for coercing strings is easy:

rules = Myrrha.coercions do |r|
  r.coercion String, Integer, lambda{|s,t| Integer(s)    }
  r.coercion String,   Float, lambda{|s,t| Float(s)      }
  r.coercion String,    Date, lambda{|s,t| Date.parse(s) }
  # ... add your own rules here ...
end

# Integers are recognized correctly
rules.coerce("12", Integer).should be_a(Integer)
rules.coerce("12", Integer).should eq(12)

# And so are Floats
rules.coerce("12.0", Float).should be_a(Float)
rules.coerce("12.0", Float).should eq(12.0)

#
# Interestingly, coercion to Numeric works as well. Because
# of the order in which the rules are defined, Integer are 
# return in priority!
# 
rules.coerce("12", Numeric).should be_a(Integer) 
rules.coerce("12.0", Numeric).should be_a(Float) 

# And dates will work as well
rules.coerce("2010-07-20", Date).should be_a(Date)
rules.coerce("2010-07-20", Date).should eq(Date.parse("2010-07-20"))

# Going further? See the set of rules in Myrrha::Ruby