# Myrrha

Myrrha provides the coercion framework which is missing to Ruby, IMHO. 

## Links

* http://rubydoc.info/github/blambeau/myrrha/master/frames
* http://github.com/blambeau/myrrha
* http://rubygems.org/gems/myrrha

## The missing coerce() feature

    require 'myrrha/with_core_ext'
    require 'myrrha/coerce'
    
    # it works on numerics
    coerce("12", Integer)             # => 12
    coerce("12.0", Float)             # => 12.0
    
    # but also on regexp (through Regexp.compile)
    coerce("[a-z]+", Regexp)          # => /[a-z]+/
    
    # and, yes, on Boolean (sorry Matz!)
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

    # on nil, it always returns nil
    coerce(nil, Integer)              # => nil

### No core extension? no problem!

    require 'myrrha/coerce'
    
    Myrrha.coerce("12", Integer)     # => 12
    
    # and so on

## The missing to_ruby_literal() feature

Myrrha also implements <code>Object#to_ruby_literal</code>, which has a very 
simple specification. Given an object o that can be considered as a true 
_value_, the result of o.to_ruby_literal must be such that the following 
invariant holds:

    Kernel.eval(o.to_ruby_literal) == o 

That is, parsing & evaluating the literal yields the same value. For almost all 
ruby classes, but not all, using o.inspect is safe. For example, you can check 
that the following is true:
 
    Kernel.eval("hello".inspect) == "hello"
    # => true

Unfortunately, this is not always the case:

    Kernel.eval(Date.today.inspect) == Date.today
    # => false (because Date.today.inspect yields "#<Date: 2011-07-20 ...")

Myrrha implements a very simple set of rules for implementing to_ruby_literal
that works:

    require 'myrrha/with_core_ext'
    require 'myrrha/to_ruby_literal'
    
    1.to_ruby_literal                       # => 1      
    Date.today.to_ruby_literal              # => Marshal.load("...")
    ["hello", Date.today].to_ruby_literal   # => ["hello", Marshal.load("...")]
    
