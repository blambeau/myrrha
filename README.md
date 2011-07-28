# Myrrha (v1.1.0)

## Description

Myrrha provides the coercion framework which is missing to Ruby, IMHO. Coercions
are simply defined as a set of rules for converting values from source to target
domains (in an abstract sense). As a typical and useful example, it comes bundled
with a coerce() method providing a unique entry point for converting a string to 
a numeric, a boolean, a date, a time, an URI, and so on.  

### Install

    % [sudo] gem install myrrha

### Bundler & Require 

    # Bug fixes (tiny) do not even add new default rules to coerce and 
    # to\_ruby\_literal. Minor version can, which could break your code. 
    # Therefore, please always use:
    gem "myrrha", "~> 1.1.0"

## Links

* http://www.rubydoc.info/gems/myrrha/1.1.0/file/README.md (read this file there!)
* http://github.com/blambeau/myrrha (source code)
* http://rubygems.org/gems/myrrha (download)

## The <code>coerce()</code> feature

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

### Implemented coercions

Implemented coercions are somewhat conservative, and only use a subset of what 
ruby provides here and there. This is to avoid strangeness ala PHP... The 
general philosophy is to provide the natural coercions we apply everyday.

The master rules are

* <code>coerce(value, Domain)</code> return <code>value</code> if 
  <code>belongs_to?(value, Domain)</code> is true (see last section below)
* <code>coerce(value, Domain)</code> returns <code>Domain.coerce(value)</code>
  if the latter method exists.
* <code>coerce("any string", Domain)</code> returns <code>Domain.parse(value)</code>
  if the latter method exists.

The specific implemented rules are 

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
    coerce("true", TrueClass)         # => true
    coerce("false", FalseClass)       # => false
  
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

### No core extension? no problem!

    require 'myrrha/coerce'
    
    Myrrha.coerce("12", Integer)            # => 12
    Myrrha.coerce("12.0", Float)            # => 12.0
    
    Myrrha.coerce("true", Myrrha::Boolean)  # => true
    # [... and so on ...]

### Adding your own coercions

The easiest way to add additional coercions is to implement a <code>coerce</code>
method on you class; it will be used in priority.

    class Foo
      def initialize(arg)
        @arg = arg
      end
      def self.coerce(arg)
        Foo.new(arg)
      end
    end
    
    Myrrha.coerce(:hello, Foo) 
    # => #<Foo:0x869eee0 @arg=:hello>

If <code>Foo</code> is not your code and you don't want to make core extensions
by adding a <code>coerce</code> class method, you can simply add new rules to 
Myrrha itself:

    Myrrha::Coerce.append do |r|
      r.coercion(Symbol, Foo) do |value, _|
        Foo.new(value)
      end
    end
    
    Myrrha.coerce(:hello, Foo) 
    # => #<Foo:0x8866f84 @arg=:hello>

Now, doing so, the new coercion rule will be shared with all Myrrha users, which 
might be intrusive. Why not using your own set of coercion rules?

    MyRules = Myrrha::Coerce.dup.append do |r|
      r.coercion(Symbol, Foo) do |value, _|
        Foo.new(value)
      end
    end 
    
    # Myrrha.coerce is actually a shortcut for:
    Myrrha::Coerce.apply(:hello, Foo)
    # => Myrrha::Error: Unable to coerce `hello` to Foo
    
    MyRules.apply(:hello, Foo) 
    # =>  #<Foo:0x8b7d254 @arg=:hello>

## The <code>to\_ruby\_literal()</code> feature

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

### No core extension? no problem!

    require 'date'
    require 'myrrha/to_ruby_literal'
    
    Myrrha.to_ruby_literal(1)              # => 1
    Myrrha.to_ruby_literal(Date.today)     # => Marshal.load("...")
    # [... and so on ...]

### Adding your own rules

The easiest way is simply to override <code>to\_ruby\_literal</code> in your
class

    class Foo
      attr_reader :arg
      def initialize(arg)
        @arg = arg
      end
      def to_ruby_literal
        "Foo.new(#{arg.inspect})"
      end
    end
    
    Myrrha.to_ruby_literal(Foo.new(:hello))
    # => "Foo.new(:hello)" 

As with coerce, contributing your own rule to Myrrha is possible:

    Myrrha::ToRubyLiteral.append do |r|
      r.coercion(Foo) do |foo, _|
        "Foo.new(#{foo.arg.inspect})"
      end
    end

    Myrrha.to_ruby_literal(Foo.new(:hello))
    # => "Foo.new(:hello)" 
    
And building your own set of rules is possible as well:

    MyRules = Myrrha::ToRubyLiteral.dup.append do |r|
      r.coercion(Foo) do |foo, _|
        "Foo.new(#{foo.arg.inspect})"
      end
    end

    # Myrrha.to_ruby_literal is actually a shortcut for:
    Myrrha::ToRubyLiteral.apply(Foo.new(:hello))
    # => "Marshal.load('...')"
    
    MyRules.apply(Foo.new(:hello))
    # => "Foo.new(:hello)" 
    
### Limitation

As the feature fallbacks to marshaling, everything which is marshalable will
work. As usual, <code>to\_ruby\_literal(Proc)</code> won't work. 

## The general coercion framework

A set of coercion rules can simply be created from scratch as follows:

    Rules = Myrrha.coercions do |r|
    
      # `upon` rules are tried in priority if PRE holds
      r.upon(SourceDomain) do |value, requested_domain|
     
        # PRE: - user wants to coerce `value` to a requested_domain
        #      - belongs_to?(value, SourceDomain)
        
        # implement the coercion or throw(:newrule)
        returned_value = something(value)
        
        # POST: belongs_to?(returned_value, requested_domain)
        
      end
      
      # `coercion` rules are then tried in order if PRE holds
      r.coercion(SourceDomain, TargetDomain) do |value, requested_domain|
     
        # PRE: - user wants to coerce `value` to a requested_domain
        #      - belongs_to?(value, SourceDomain)
        #      - subdomain?(TargetDomain, requested_domain)
        
        # implement the coercion or throw(:newrule)
        returned_value = something(value) 
        
        # POST: returned_value belongs to requested_domain
        
      end
      
      # fallback rules are tried if everything else has failed
      r.fallback(SourceDomain) do |value, requested_domain|
      
        # exactly the same as upon rules
      
      end
    
    end
    
When the user invokes <code>Rules.apply(value, domain)</code> all rules for 
which PRE holds are executed in order, until one succeed (chain of 
responsibility design pattern). This means that coercions always execute in 
<code>O(number of rules)</code>.

### Specifying converters

A converter is the third (resp. second) element specified in a coercion rules
(resp. an upon or fallback rule). A converter is generally a Proc of arity 2,
which is passed the source value and requested target domain.

    Myrrha.coercions do |r|
      r.coercion String, Numeric, lambda{|value,requested_domain|
        # this is converter code
      }
    end
    convert("12", Integer)
    
A converter may also be specified as an array of domains. In this case, it is
assumed that they for a path inside the convertion graph. Consider for example
the following coercion rules (contrived example)

    rules = Myrrha.coercions do |r|
      r.coercion String,  Symbol, lambda{|s,t| s.to_sym }   # 1
      r.coercion Float,   String, lambda{|s,t| s.to_s   }   # 2
      r.coercion Integer, Float,  lambda{|s,t| Float(s) }   # 3
      r.coercion Integer, Symbol, [Float, String]           # 4
    end
    
The last rule specifies a convertion path, through intermediate domains. The 
complete rule specifies that applying the following path will work

    Integer -> Float -> String -> Symbol
            #3       #2        #1
 
Indeed,

    rules.coerce(12, Symbol)      # => :"12.0" 
  
### Semantics of <code>belongs\_to?</code> and <code>subdomain?</code> 

The pseudo-code given above relies on two main abstractions. Suppose the user 
makes a call to <code>coerce(value, requested_domain)</code>:

* <code>belongs\_to?(value, SourceDomain)</code> is true iif
  * <code>SourceDomain</code> is a <code>Proc</code> of arity 2, and 
    <code>SourceDomain.call(value, requested_domain)</code> yields true
  * <code>SourceDomain</code> is a <code>Proc</code> of arity 1, and 
    <code>SourceDomain.call(value)</code> yields true
  * <code>SourceDomain === value</code> yields true

* <code>subdomain?(SourceDomain,TargetDomain)</code> is true iif
  * <code>SourceDomain == TargetDomain</code> yields true
  * TargetDomain respond to <code>:superdomain_of?</code> and answers true on 
    SourceDomain 
  * SourceDomain and TargetDomain are both classes and the latter is a super 
    class of the former 
    
### Advanced rule examples

    Rules = Myrrha.coercions do |r|
    
      # A 'catch-all' upon rule, always fired
      catch_all = lambda{|v,rd| true} 
      r.upon(catch_all) do |value, requested_domain|
        if you_can_coerce?(value)
          # then do it!
        else
          throw(:next_rule)
        end
      end
      
      # Delegate every call to the requested domain if it responds to compile
      compilable = lambda{|v,rd| rd.respond_to?(:compile)} 
      r.upon(compilable) do |value, requested_domain|
        requested_domain.compile(value)
      end  
      
      # A fallback strategy if everything else fails
      r.fallback(Object) do |value, requested_domain|
        # always fired after everything else
        # this is your last change, an Myrrha::Error will be raised if you fail
      end
      
    end

### Factoring domains through specialization by constraint

Specialization by constraint (SByC) is a theory of types for which the following
rules hold:

* A type (aka domain) is a set of values
* A sub-type is a subset
* A sub-type can therefore be specified through a predicate on the super domain

For example, "positive integers" is a sub type of "integers" where the predicate
is "value > 0". 

Myrrha comes with a small feature allowing you to create types 'ala' SByC:

    PosInt = Myrrha.domain(Integer){|i| i > 0}
    PosInt.name       # => "PosInt"
    PosInt.class      # => Class
    PosInt.superclass # => Integer
    PosInt.ancestors  # => [PosInt, Integer, Numeric, Comparable, Object, Kernel, BasicObject]
    PosInt === 10     # => true
    PosInt === -1     # => false
    PosInt.new(10)    # => 10
    PosInt.new(-10)   # => ArgumentError, "Invalid value -10 for PosInt"
    
Note that the feature is very limited, and is not intended to provide a truly
coherent typing framework. For example:

    10.is_a?(PosInt)    # => false
    10.kind_of?(PosInt) # => false 
      
Instead, Myrrha domains are only provided as an helper to build sound coercions 
rules easily while 1) keeping a Class-based approach to source and target 
domains and 2) having friendly error messages 3) really supporting true 
reasoning on types and value:

    # Only a rule that converts String to Integer
    rules = Myrrha.coercions do |r|
      r.coercion String, Integer, lambda{|s,t| Integer(s)}  
    end 
    
    # it succeeds on both integers and positive integers
    rules.coerce("12", Integer)   # => 12
    rules.coerce("12", PosInt)    # => 12
    
    # and correctly fails in each case!
    rules.coerce("-12", Integer)  # => -12
    rules.coerce("-12", PosInt)   # => ArgumentError, "Invalid value -12 for PosInt"
    
    
    
