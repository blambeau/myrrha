require File.expand_path('../examples_helper', __FILE__)
require 'myrrha/core_ext'

# it works on numerics
coercion("12", Integer).should eq(12)
coercion("12.0", Float).should eq(12.0)

# but also on regexp (through Regexp.compile)
coercion("[a-z]+", Regexp).should eq(/[a-z]+/)

# and, yes, on Boolean (Sorry Matz!)
coercion("true", Boolean).should eq(true)      
coercion("false", Boolean).should eq(false)

# and on date and time (through Date/Time.parse)  
require 'date'
require 'time'
coercion("2011-07-20", Date).should be_a(Date)  
coercion("2011-07-20 10:57", Time).should be_a(Time)

# why not on URI?
require 'uri'
coercion('http://google.com', URI).should be_a(URI)    
