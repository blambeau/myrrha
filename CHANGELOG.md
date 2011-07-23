# 1.1.0 / FIX ME

## Enhancements to coerce()

* Added coercion rules from Symbol/String to Module/Class

      coerce("Integer", Class)          # => Integer
      coerce(:Integer, Class)           # => Integer
      coerce("Myrrha::Version", Module) # => Myrrha::Version
      [... and so on ...]
      
* require('time') is automatically issued when trying to coerce a String to 
  a Time. Time.parse is obviously needed.   

# 1.0.0 / 2011-07-22

## Enhancements

  * Birthday!
