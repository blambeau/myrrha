# Myrrha

Myrrha provides the coercion framework which is missing to Ruby. 

## Links

* http://rubydoc.info/github/blambeau/myrrha/master/frames
* http://github.com/blambeau/myrrha
* http://rubygems.org/gems/myrrha

### The missing coercion() core feature

    require 'myrrha/core_ext'
    
    # it works on numerics
    coercion("12", Integer)             # => 12
    coercion("12.0", Float)             # => 12.0
    
    # but also on regexp (through Regexp.compile)
    coercion("[a-z]+", Regexp)          # => /[a-z]+/
    
    # and, yes, on Boolean (Sorry Matz!)
    coercion("true", Boolean)           # => true
    coercion("false", Boolean)          # => false
  
    # and on date and time (through Date/Time.parse)  
    require 'date'
    require 'time'
    coercion("2011-07-20", Date)        # => #<Date: 2011-07-20 (4911525/2,0,2299161)>  
    coercion("2011-07-20 10:57", Time)  # => 2011-07-20 10:57:00 +0200
    
    # why not on URI?
    require 'uri'
    coercion('http://google.com', URI)  # => #<URI::HTTP:0x8281ce0 URL:http://google.com>    

