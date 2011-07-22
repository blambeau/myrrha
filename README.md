# Myrrha

Myrrha provides the coercion framework which is missing to Ruby, IMHO. 

## Links

* http://rubydoc.info/github/blambeau/myrrha/master/frames (read this file there!)
* http://github.com/blambeau/myrrha (source code)
* http://rubygems.org/gems/myrrha (download)

## The missing <code>coerce()</code>

    Myrrha.coerce(:anything, Domain)
    coerce(:anything, Domain)                    # with core extensions

### What for?

Having a single entry point for coercing values from one data-type (typically
a String) to another one is very useful. Unfortunately, Ruby does not provide
such a unique entry point... Thanks to Myrrah, the following scenario is 
possible and even straightforward:

    require 'myrrha/with_core_ext'
    require 'myrrha/coerce'
    require 'date'
    
    values = ["12", "true", "2011-07-20"]
    types  = [Integer, Boolean, Date]
    values.zip(types).collect do |value,domain|
      coerce(value, domain)
    end
    # => [12, true, #<Date: 2011-07-20 (...)>]

### Example

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
    
    Myrrha.coerce("12", Integer)            # => 12
    Myrrha.coerce("12.0", Float)            # => 12.0
    
    Myrrha.coerce("true", Myrrha::Boolean)  # => true
    # [... and so on ...]

## The missing <code>to\_ruby\_literal()</code>

    Myrrha.to_ruby_literal([:anything]) 
    [:anything].to_ruby_literal                  # with core extensions

### What for?

<code>Object#to\_ruby\_literal</code> has a very simple specification. Given an 
object o that can be considered as a true _value_, the result of 
<code>o.to\_ruby\_literal</code> must be such that the following invariant 
holds:

    Kernel.eval(o.to_ruby_literal) == o 

That is, parsing & evaluating the literal yields the same value. When generating 
(human-readable) ruby code, having a unique entry point that respects the 
specification is very useful. 

For almost all ruby classes, but not all, using o.inspect respects the 
invariant. For example, the following is true:
 
    Kernel.eval("hello".inspect)           == "hello"            # => true
    Kernel.eval([1, 2, 3].inspect)         == [1, 2, 3]          # => true
    Kernel.eval({:key => :value}.inspect)  == {:key => :value}   # => true
    # => true

Unfortunately, this is not always the case:

    Kernel.eval(Date.today.inspect) == Date.today
    # => false 
    # => because Date.today.inspect yields "#<Date: 2011-07-20 ...", which is a comment

### Example

Myrrha implements a very simple set of rules for implementing 
<code>Object#to\_ruby\_literal</code> that works:

    require 'date'
    require 'myrrha/with_core_ext'
    require 'myrrha/to_ruby_literal'
    
    1.to_ruby_literal                       # => "1"      
    Date.today.to_ruby_literal              # => "Marshal.load('...')"
    ["hello", Date.today].to_ruby_literal   # => "['hello', Marshal.load('...')]"

Myrrha implements a best-effort strategy to return a human readable string. It
simply fallbacks to <code>Marshal.load(...)</code> when the strategy fails:

    (1..10).to_ruby_literal                 # => "1..10"
    
    today = Date.today
    (today..today+1).to_ruby_literal        # => "Marshal.load('...')"

### No core extension? No problem!

    require 'date'
    require 'myrrha/to_ruby_literal'
    
    Myrrha.to_ruby_literal(1)              # => 1
    Myrrha.to_ruby_literal(Date.today)     # => Marshal.load("...")
    # [... and so on ...]
    
### Limitation

As the feature fallbacks to marshaling, everything which is marshalable will
work. As usual, <code>to\_ruby\_literal(Proc)</code> won't work. 