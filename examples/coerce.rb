require 'myrrha/with_core_ext'
require 'myrrha/coerce'

# NilClass -> _Anything_ returns nil, always
coerce(nil, Integer)              # => nil

# Object -> String, via ruby's String()
coerce("hello", String)           # => "hello"
coerce(:hello, String)            # => "hello"

# String -> Numeric, through ruby's Integer() and Float()
coerce("12", Integer)             # => 12
coerce("12.0", Float)             # => 12.0

# String -> Numeric is smart enough:
coerce("12", Numeric)             # => 12 (Integer)
coerce("12.0", Numeric)           # => 12.0 (Float)

# String -> Regexp, through Regexp.compile
coerce("[a-z]+", Regexp)          # => /[a-z]+/

# String -> Symbol, through to_sym
coerce("hello", Symbol)           # => :hello 

# String -> Boolean (hum, sorry Matz!)
coerce("true", Boolean)           # => true
coerce("false", Boolean)          # => false

# String -> Date, through Date.parse  
require 'date'
coerce("2011-07-20", Date)        # => #<Date: 2011-07-20 (4911525/2,0,2299161)>  

# String -> Time, through Time.parse (just in time issuing of require('time'))
coerce("2011-07-20 10:57", Time)  # => 2011-07-20 10:57:00 +0200

# String -> URI, through URI.parse
require 'uri'
coerce('http://google.com', URI)  # => #<URI::HTTP:0x8281ce0 URL:http://google.com>    

# String -> Class and Module through constant lookup
coerce("Integer", Class)          # => Integer
coerce("Myrrha::Version", Module) # => Myrrha::Version

# Symbol -> Class and Module through constant lookup
coerce(:Integer, Class)           # => Integer
coerce(:Enumerable, Module)       # => Enumerable
