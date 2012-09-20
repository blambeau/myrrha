require 'myrrha'
module Myrrha
  
  #
  # Defines the missing Boolean as a Myrrha's domain
  #
  Boolean = Myrrha.domain(Object, [TrueClass, FalseClass]){|x| 
    (x==true) || (x==false)
  }

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
  Coerce = coercions do |g|

    # Returns a constant denoted by `s`
    def g.constant_lookup(s, target_domain)
      found = (s.split('::') - [""]).inject(Kernel){|cur,n|
        cur.const_get(n.to_sym)
      }
      belongs_to?(found, target_domain) ? found : throw(:nextrule)
    end

    # NilClass should return immediately
    g.upon(NilClass) do |s,t|
      nil
    end

    # Use t.coerce if it exists
    g.upon(lambda{|s,t| t.respond_to?(:coerce)}) do |s,t|
      t.coerce(s)
    end

    # Specific basic rules
    g.coercion Object,  String, lambda{|s,t| String(s)                     }
    g.coercion String, Integer, lambda{|s,t| Integer(s)                    }
    g.coercion String,   Float, lambda{|s,t| Float(s)                      }
    g.coercion String, Boolean, lambda{|s,t| Boolean(s)                    }
    g.coercion Integer,  Float, lambda{|s,t| Float(s)                      }
    g.coercion String,  Symbol, lambda{|s,t| s.to_sym                      }
    g.coercion String,  Regexp, lambda{|s,t| Regexp.compile(s)             }
    g.coercion Symbol,   Class, lambda{|s,t| g.constant_lookup(s.to_s, t)  }
    g.coercion Symbol,  Module, lambda{|s,t| g.constant_lookup(s.to_s, t)  }
    g.coercion String,   Class, lambda{|s,t| g.constant_lookup(s, t)       }
    g.coercion String,  Module, lambda{|s,t| g.constant_lookup(s, t)       }
    g.coercion String,    Time, lambda{|s,t| require 'time'; Time.parse(s) }

    # By default, we try to invoke :parse on the class
    g.fallback(String) do |s,t|
      t.respond_to?(:parse) ? t.parse(s.to_str) : throw(:nextrule)
    end

  end # Coerce

  def self.coerce(value, domain)
    Coerce.apply(value, domain)
  end

end # module Myrrha

if Myrrha.core_ext?
  Boolean = Myrrha::Boolean
  def Boolean(s)
    Myrrha::Boolean(s)
  end
  class Object
    private
    def coerce(value, domain)
      Myrrha.coerce(value, domain)
    end
  end
end
