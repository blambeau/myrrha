# 1.1.0 / FIX ME

## Enhancements to coerce()

* Added coercion rules from Symbol/String to Module/Class

      coerce("Integer", Class)          # => Integer
      coerce(:Integer, Class)           # => Integer
      coerce("Myrrha::Version", Module) # => Myrrha::Version
      [... and so on ...]
      
* Added coercion rule from any Object to String through ruby's String(). Note 
  that even with this coercion rule, coerce(nil, String) returns nil as that 
  rule has higher priority.
      
* require('time') is automatically issued when trying to coerce a String to 
  a Time. Time.parse is obviously needed.   

## Bug fixes

* Fixed Coercions#dup when a set of rules has a main target domain. This fixes
  the duplication of ToRubyLiteral rules, among others. 

# 1.0.0 / 2011-07-22

## Enhancements

  * Birthday!
