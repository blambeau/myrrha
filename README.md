# Myrrha

Myrrha provides the coercion framework which is missing to Ruby. 

## Links

* http://rubydoc.info/github/blambeau/myrrha/master/frames
* http://github.com/blambeau/myrrha
* http://rubygems.org/gems/myrrha

### The missing coercion() feature

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

### The missing to_ruby_literal() feature

Myrrha also implements Object#to_ruby_literal, which has a very simple 
specification. Given an object o that can be considered as a true _value_, the 
result of o.to_ruby_literal must be such that the following invariant holds:

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

    require 'myrrha/core_ext'
    
    1.to_ruby_literal                       # => 1      
    Date.today.to_ruby_literal              # => Marshal.load("...")
    ["hello", Date.today].to_ruby_literal   # => ["hello", Marshal.load("...")]
    
