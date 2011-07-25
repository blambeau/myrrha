# 1.1.0 / FIX ME

## Enhancements to coerce()

* Added coercion rules from Symbol/String to Module/Class

      coerce("Integer", Class)          # => Integer
      coerce(:Integer, Class)           # => Integer
      coerce("Myrrha::Version", Module) # => Myrrha::Version
      [... and so on ...]

* Added following coercion rules for Booleans

      coerce("true", TrueClass)         # => true 
      coerce("false", FalseClass)       # => false 

* Added coercion rule from any Object to String through ruby's String(). Note 
  that even with this coercion rule, coerce(nil, String) returns nil as that 
  rule has higher priority.
      
* require('time') is automatically issued when trying to coerce a String to 
  a Time. Time.parse is obviously needed.   

## Enhancements to the general coercion mechanism

* An optimistic coercion is tried when a rule is encountered whose target 
  domain is a super domain of the requested one. Coercion only succeeds if
  the coerced value correctly belongs to the latter domain. Example:
  
      rules = Myrrha.coercions do |r|
        r.coercion String, Numeric, lambda{|s,t| Integer(s)} 
      end 
      rules.coerce("12", Integer) # => 12            # failed in 1.0.0
      rules.coerce("12", Float)   # => Myrrha::Error

* You can now specify an coercion path, through an array of domains. For 
  example (completely contrived, of course):

    rules = Myrrha.coercions do |r|
      r.coercion String,  Symbol, lambda{|s,t| s.to_sym }
      r.coercion Float,   String, lambda{|s,t| s.to_s   }
      r.coercion Integer, Float,  lambda{|s,t| Float(s) }
      r.coercion Integer, Symbol, [Float, String] 
    end
    rules.coerce(12, Symbol)      # => :"12.0" 

## Bug fixes

* Fixed Coercions#dup when a set of rules has a main target domain. This fixes
  the duplication of ToRubyLiteral rules, among others.

# 1.0.0 / 2011-07-22

## Enhancements

  * Birthday!
