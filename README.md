# Myrrha

Myrrha provides the coercion framework which is missing to Ruby. 

## Links

* http://rubydoc.info/github/blambeau/myrrha/master/frames
* http://github.com/blambeau/myrrha
* http://rubygems.org/gems/myrrha

### The missing Ruby feature

  require 'myrrha/core_ext'
  
  # it works on numerics
  coerce("12", Integer)             # => 12
  coerce("12.0", Float)             # => 12.0
  
  # but also on regexp (through Regexp.compile)
  coerce("[a-z]+", Regexp)          # => /[a-z]+/
  
  # and, yes, on Boolean (Sorry Matz!)
  coerce("true", Boolean)           # => true
  coerce("false", Boolean)          # => false

  # and on date and time (through Date/Time.parse)  
  require 'date'
  require 'time'
  coerce("2011-07-20", Date)        # => #<Date: 2011-07-20 (4911525/2,0,2299161)>  
  coerce("2011-07-20 10:57", Time)  # => 2011-07-20 10:57:00 +0200
  
  # why not on URI?
  require 'uri'
  coerce('http://google.com', URI)  # => #<URI::HTTP:0x8281ce0 URL:http://google.com>    

