#
# Myrrha -- the missing coercion framework for Ruby
#
module Myrrha
  
  #
  # Raised when a coercion fails
  #
  class Error < StandardError; end
  
  #
  # Builds a set of coercions rules. 
  #
  # Example:
  #
  #   rules = Myrrha.coercions do |c|
  #     c.coercion String, Integer, lambda{|s,t| Integer(s)}
  #     #
  #     # [...]
  #     #
  #     c.fallback String, lambda{|s,t| ... }
  #   end
  #
  def self.coercions(&block)
    Coercions.new(&block)
  end
    
  # 
  # Defines a set of coercion rules
  #
  class Coercions
    
    #
    # Creates an empty list of coercion rules
    #
    def initialize
      @rules = []
      @fallbacks = []
      yield(self) if block_given?
    end
    
    #
    # Appends the list of rules with new ones.
    #
    # New coercion and fallback rules will be put after the already existing 
    # ones, in both case. However, coercion rules always stay before fallback
    # ones.    
    #
    # Example:
    #
    #   rules = Myrrha.coercions do ... end
    #   rules.append do |r|
    #     r.coercion String, Float, lambda{|v,t| Float(t)}
    #   end
    #
    def append
      yield(self) if block_given?
      self
    end
    
    #
    # Adds a coercion rule from a source to a target domain.
    #
    # The conversion can be provided through `converter` or via a block
    # directly. See main documentation about recognized converters.
    #
    # Example:
    #
    #   Myrrha.coercions do |r|
    #     
    #     # With an explicit proc
    #     r.coercion String, Integer, lambda{|v,t| 
    #       Integer(v)
    #     } 
    #
    #     # With an implicit proc
    #     r.coercion(String, Float) do |v,t| 
    #       Float(v)
    #     end
    #
    #   end
    #
    # @param source [Domain] a source domain (mimicing Domain) 
    # @param target [Domain] a target domain (mimicing Domain)
    # @param converter [Converter] an optional converter (mimic Converter)
    # @param convproc [Proc] used when converter is not specified
    # @return self
    #
    def coercion(source, target, converter = nil, &convproc)
      @rules << [source, target, converter || convproc]
      self
    end
    
    #
    # Adds a fallback rule for a source domain.
    #
    # Conventions about converters are exactly the same as with coercion.
    #
    # Example:
    #
    #   Myrrha.coercions do |r|
    #     
    #     # With an explicit proc 
    #     r.fallback String, lambda{|v,t| 
    #       # the user wants _v_ to be converted to a value of domain _t_
    #     }
    #
    #   end
    #
    # @param source [Domain] a source domain (mimic Domain) 
    # @param converter [Converter] an optional converter (mimic Converter)
    # @param convproc [Proc] used when converter is not specified
    # @return self
    #
    def fallback(source, converter = nil, &convproc)
      @fallbacks << [source, nil, converter || convproc]
    end
    
    #
    # Coerces `value` to an element of `target_domain`
    #
    # This method tries each coercion rule, then each fallback in turn. Rules 
    # for which source and target domain match are executed until one succeeds.
    # A Myrrha::Error is raised if no rule matches or executes successfuly.
    #
    # @param [Object] value any ruby value
    # @param [Domain] target_domain a target domain to convert to (mimic Domain)
    # @return self
    #
    def coerce(value, target_domain)
      return value if belongs_to?(value, target_domain)
      error = nil
      (@rules + @fallbacks).each do |from,to,converter|
        next unless from.nil? or belongs_to?(value, from)
        next unless to.nil?   or subdomain?(to, target_domain)
        begin
          return convert(value, target_domain, converter)
        rescue => ex
          error = ex.message unless error
        end
      end
      msg = "Unable to coerce `#{value}` to #{target_domain}"
      msg += " (#{error})" if error
      raise Error, msg
    end
    
    #
    # Returns true if `value` can be considered as a valid element of the 
    # domain `domain`, false otherwise.
    #
    # @param [Object] value any ruby value
    # @param [Domain] domain a domain (mimic Domain)
    # @return [Boolean] true if `value` belongs to `domain`, false otherwise
    #
    def belongs_to?(value, domain)
      if domain.is_a?(Proc) && (RUBY_VERSION < "1.9")
        domain.call(value)
      else
        domain === value
      end
    end
    
    #
    # Returns `true` if `child` can be considered a valid sub domain of 
    # `parent`, false otherwise.
    #
    # @param [Domain] child a domain (mimic Domain)
    # @param [Domain] parent another domain (mimic Domain)
    # @return [Boolean] true if `child` is a subdomain of `parent`, false 
    #         otherwise.
    #
    def subdomain?(child, parent)
      return true if child == parent
      (child.respond_to?(:superclass) && child.superclass) ? 
        subdomain?(child.superclass, parent) :
        false
    end
    
    private
    
    #
    # Calls converter on a (value,target_domain) pair.
    # 
    def convert(value, target_domain, converter)
      if converter.respond_to?(:call)
        converter.call(value, target_domain)
      else
        raise ArgumentError, "Unable to use #{converter} for coercing"
      end
    end
    
  end # class Coercions
  
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
  
  #
  # Tries to parse `s` thanks to the class `t`
  #
  # This method implements a typical fallback rule for coercing strings to
  # other domains. It looks for a :parse method on `t` and uses it on `s`
  # when found. Otherwise, it raises an ArgumentError.
  #
  # @param [String] s any String
  # @param [Domain] t a domain (mimic Domain)
  # @return [Object] the result of <code>t.parse(s.to_str)</code> if :parse is
  #         defined.
  # @raise [ArgumentError] is no such parse method is found.
  #
  def self.Parse(s,t)
    if t.respond_to?(:parse)
      t.parse(s.to_str)
    else
      raise ArgumentError, "#{t} does not parse"
    end
  end
  
  # Defines basic coercions for Ruby, mostly from String 
  CoerceRules = coercions do |g|
    g.coercion String, Integer, lambda{|s,t| Integer(s)        }
    g.coercion String,   Float, lambda{|s,t| Float(s)          }
    g.coercion String, Boolean, lambda{|s,t| Boolean(s)        }
    g.coercion Integer,  Float, lambda{|s,t| Float(s)          }
    g.coercion String,  Symbol, lambda{|s,t| s.to_sym          }
    g.coercion String,  Regexp, lambda{|s,t| Regexp.compile(s) }
    g.fallback NilClass,        lambda{|s,t| nil               }
    g.fallback String,          lambda{|s,t| Parse(s,t)        }
  end
  
  # These are all classes for which using inspect is safe for to_ruby_literal
  TO_RUBY_THROUGH_INSPECT = [ NilClass, TrueClass, FalseClass, 
                              Fixnum, Bignum, Float, 
                              String, Symbol, Class, Module, Regexp ]
  
  # Defines basic coercions for implementing to_ruby_literal
  ToRubyLiteralRules = coercions do |r|
    safe = lambda{|x| TO_RUBY_THROUGH_INSPECT.include?(x.class)}
    r.coercion(safe, :to_ruby_literal) do |s,t| 
      s.inspect
    end
    r.coercion(Range, :to_ruby_literal) do |s,t|
      if TO_RUBY_THROUGH_INSPECT.include?(s.first.class) &&
         TO_RUBY_THROUGH_INSPECT.include?(s.last.class)
        s.inspect
      else
        raise ArgumentError
      end
    end
    r.coercion(Array, :to_ruby_literal) do |s,t|
      "[" + s.collect{|v| r.coerce(v, :to_ruby_literal)}.join(', ') + "]"
    end
    r.coercion(Hash, :to_ruby_literal) do |s,t|
      "{" + s.collect{|k,v| 
        r.coerce(k, :to_ruby_literal) + " => " + r.coerce(v, :to_ruby_literal) 
      }.join(', ') + "}"
    end
    r.fallback(Object) do |s,t| 
      "Marshal.load(#{Marshal.dump(s).inspect})"
    end
  end
  
  # Encapsulates core extensions to the Object class
  module CoreExt
    
    # 
    # Coerces _value_ to an instance of _domain_
    #
    def coercion(value, clazz)
      CoerceRules.coerce(value, clazz)
    end
    
    #
    # Converts this value to a ruby literal
    #
    def to_ruby_literal
      ToRubyLiteralRules.coerce(self, :to_ruby_literal)
    end
    
    # (see Myrrha.Boolean)
    def Boolean(s)
      Myrrha.Boolean(s)
    end
    
    Boolean = Myrrha::Boolean
  end # module CoreExt
  include CoreExt
  
end # module Myrrha
require "myrrha/version"
require "myrrha/loader"