module Myrrha
  
  #
  # Defines the missing Boolean type.
  #
  # This module mimics a Ruby missing Boolean type. 
  #
  module Boolean

    #
    # Returns Object, as the superclass of Boolean
    #
    # @return [Class] Object
    #
    def self.superclass; Object; end
      
    #
    # Returns true if `val` is <code>true</code> or <code>false</code>, false 
    # otherwise.
    #
    def self.===(val)
      (val == true) || (val == false)
    end
    
  end # module Boolean
  
  #
  # Coerces _s_ to a Boolean
  #
  # This method mimics Ruby's Integer(), Float(), etc. for Boolean values.
  #
  # @param [Object] s a Boolean or a String 
  # @return [Boolean] true if `s` is already true of the string 'true',
  #                   false if `s` is already false of the string 'false'.
  # @raise [ArgumentError] if `s` cannot be coerced to a boolean. 
  #
  def self.Boolean(s)
    if (s==true || s.to_str.strip == "true")
      true
    elsif (s==false || s.to_str.strip == "false")
      false
    else
      raise ArgumentError, "invalid value for Boolean: \"#{s}\""
    end
  end
  
  # Defines basic coercions for Ruby, mostly from String 
  CoerceRules = coercions do |g|
    
    # NilClass should return immediately
    g.upon(NilClass) do |s,t| 
      nil
    end
    
    # Use t.coerce if it exists
    g.upon(lambda{|s,t| t.respond_to?(:coerce)}) do |s,t|
      t.coerce(s)
    end
    
    # Specific basic rules
    g.coercion String, Integer, lambda{|s,t| Integer(s)        }
    g.coercion String,   Float, lambda{|s,t| Float(s)          }
    g.coercion String, Boolean, lambda{|s,t| Boolean(s)        }
    g.coercion Integer,  Float, lambda{|s,t| Float(s)          }
    g.coercion String,  Symbol, lambda{|s,t| s.to_sym          }
    g.coercion String,  Regexp, lambda{|s,t| Regexp.compile(s) }
      
    # By default, we try to invoke :parse on the class 
    g.fallback(String) do |s,t| 
      t.respond_to?(:parse) ? t.parse(s.to_str) : throw(:nextrule) 
    end
    
  end # CoerceRules

  def self.coerce(value, domain)
    CoerceRules.coerce(value, domain)
  end
    
end # module Myrrha

if Myrrha.core_ext?
  Boolean = Myrrha::Boolean
  def Boolean(s)
    Myrrha::Boolean(s)
  end
  def coercion(value, domain)
    Myrrha.coerce(value, domain)
  end 
end