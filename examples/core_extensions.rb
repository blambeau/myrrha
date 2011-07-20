require File.expand_path('../examples_helper', __FILE__)
require 'myrrha/core_ext'

# it works on numerics
coerce("12", Integer).should      eq(12)
coerce("12.0", Float).should      eq(12.0)

# but also on regexp (through Regexp.compile)
coerce("[a-z]+", Regexp).should   eq(/[a-z]+/)

# and, yes, on Boolean (Sorry Matz!)
coerce("true", Boolean).should    eq(true)      
coerce("false", Boolean).should   eq(false)

# and on date and time (through Date/Time.parse)  
require 'date'
require 'time'
coerce("2011-07-20", Date).should       be_a(Date)  
coerce("2011-07-20 10:57", Time).should be_a(Time)

# why not on URI?
require 'uri'
coerce('http://google.com', URI).should be_a(URI)    
