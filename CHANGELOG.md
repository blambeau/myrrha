# 2.0.0 / FIX ME

* Removed support for ruby 1.8.7
* Coercions#subdomain? and Coercions#belongs_to? are now protected
* In case of coercion failure, Myrrha::Error keeps the first coercion error under `cause`
  (that might be nil if no rule was triggered or no rule explcitely failed).

* Defining domains through subclassing and specialization by constraints must now be made
  as shown below. Factored domains gain a Coercions instance under `coercions`.

    class NegInt < Integer
      extend Myrrha::Domain::SByC.new(Integer, [], lambda{|i| i<0})

      coercions do |c|
        c.coercion(String){|v,t| ...}
      end
    end

* Added a Domain::Impl module for implementing domains from scratch (vs. sbyc). Factored
  domains have a default constructor taking components as parameters, an attribute reader
  for each component as well as hash and equality methods properly defined. They also have
  a Coercions instance under `coercions`.

    class Point
      include Domain::Impl.new(:x, :y)

      coercions do |c|
        c.coercion(String){|v,t| ...}
      end
    end

# 1.2.2 / 2012-01-26

* Ensure that inheritance intuitively applies when duplicating a set of coercion
  rules. Rules that, in the parent, rely on the recursive application of other 
  rules (such as recursively applying coercions on arrays) will now correctly 
  use the rules defined on the duplicated Coercions object.

  In particular, this means that the following scenario now correctly works:

      Dupped = Myrrha::ToRubyLiteral.dup.append do |r|
        r.coercion(Foo){|s,_| ...}
      end
      Dupped.apply([1, Foo.new])

  In the scenario above, Foo was marshalled as the new rules was not used by 
  the Array rule, defined on the parent.

# 1.2.1 / 2011-08-31

* Regenerated gem using Ruby 1.8.7, to avoid Rubygems/Syck/Ruby issues (see
  https://github.com/blambeau/viiite/issues/2)

# 1.2.0 / 2011-08-15

* Added the ability to created SByC domains through simple module extension:

      NegInt = Myrrha.domain(Integer){|i| i < 0}
      
  can also be built the following way:

      class NegInt < Integer
        extend Myrrha::Domain
        
        def self.predicate
          @predicate ||= lambda{|i| i < 0}
        end
        
      end

* Cleaned the development dependencies, travis-ci.org continuous integration,
  and ruby.noe template.

# 1.1.0 / 2011-07-28

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

* Myrrha::Boolean (Boolean with core extensions) is now a factored domain (see
  below). Therefore, it is now a true Class instance. 

## Enhancements to the general coercion mechanism

* An optimistic coercion is tried when a rule is encountered whose target 
  domain is a super domain of the requested one. Coercion only succeeds if
  the coerced value correctly belongs to the latter domain. Example:
  
      rules = Myrrha.coercions do |r|
        r.coercion String, Numeric, lambda{|s,t| Integer(s)} 
      end 
      rules.coerce("12", Integer) # => 12 in 1.1.0 while it failed in 1.0.0
      rules.coerce("12", Float)   # => Myrrha::Error

* You can now specify a coercion path, through an array of domains. For 
  example (completely contrived, of course):

      rules = Myrrha.coercions do |r|
        r.coercion String,  Symbol, lambda{|s,t| s.to_sym }
        r.coercion Float,   String, lambda{|s,t| s.to_s   }
        r.coercion Integer, Float,  lambda{|s,t| Float(s) }
        r.coercion Integer, Symbol, [Float, String] 
      end
      rules.coerce(12, Symbol)      # => :"12.0" as Symbol(String(Float(12)))

* You can now define domains through specialization by constraint (sbyc) on ruby 
  classes, using Myrrha.domain:
  
      # Create a positive integer domain, as ... positive integers
      PosInt = Myrrha.domain(Integer){|i| i > 0 }
  
  Created domain is a real Class instance, that correctly responds to :=== 
  and :superclass. The feature is mainly introduced for supporting the following 
  kind of coercion scenarios (see README for more about this):
  
      rules = Myrrha.coercions do |r|
        r.coercion String, Integer, lambda{|s,t| Integer(s)}  
      end 
      rules.coerce("12",  PosInt) # => 12
      rules.coerce("-12", PosInt) # => ArgumentError, "Invalid value -12 for PosInt"  

## Bug fixes

* Fixed Coercions#dup when a set of rules has a main target domain. This fixes
  the duplication of ToRubyLiteral rules, among others.

# 1.0.0 / 2011-07-22

## Enhancements

  * Birthday!
