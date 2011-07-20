require File.expand_path('../examples_helper', __FILE__)
require 'myrrha/core_ext'

# it works on numerics
coercion("12", Integer)
coercion("12.0", Float)

# but also on regexp (through Regexp.compile)
coercion("[a-z]+", Regexp)

# and, yes, on Boolean (Sorry Matz!)
coercion("true", Boolean)
coercion("false", Boolean)

# and on date and time (through Date/Time.parse)  
require 'date'
require 'time'
coercion("2011-07-20", Date)
coercion("2011-07-20 10:57", Time)

# why not on URI?
require 'uri'
coercion('http://google.com', URI)    
