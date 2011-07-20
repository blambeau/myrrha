#
# Coercion graph
#
module Myrrha
  
  # Raised when a coercion fails
  class Error < StandardError; end
      
  # 
  # Defines a coercion graph
  #
  class Coercions
    
    def initialize
      @rules = []
      yield(self) if block_given?
    end
    
    def coercion(source, target, converter = nil, &convproc)
      @rules << [source, target, converter || convproc] 
    end
    
    def coerce(value, target_domain)
      return value if belongs_to?(value, target_domain)
      error = nil
      @rules.each do |from,to,converter|
        next unless belongs_to?(value, from)
        next unless (ANY==to) || subdomain?(to, target_domain)
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
    
    def belongs_to?(value, domain)
      if domain.is_a?(Proc) && (RUBY_VERSION < "1.9")
        domain.call(value)
      else
        domain === value
      end
    end
    
    def subdomain?(child, parent)
      return true if child == parent
      (child.respond_to?(:superclass) && child.superclass) ? 
        subdomain?(child.superclass, parent) :
        false
    end
    
    def convert(value, target_domain, converter)
      if converter.respond_to?(:call)
        case (converter.respond_to?(:arity) ? converter.arity : 1)
        when 1
          converter.call(value)
        when 2
          converter.call(value, target_domain)
        else
          raise ArgumentError, "Unexpected converter arity #{converter.arity}"
        end
      elsif converter.is_a?(Class)
        converter.new(value)
      else
        raise ArgumentError, "Unable to use #{converter} for coercing"
      end
    end
    
  end # class Coercions
  
  ANY = Object.new

  # Defines the missing Boolean type
  module Boolean
    def self.superclass; Object; end
    def self.===(val)
      (val == true) || (val == false)
    end
  end
  
  # Coerces _s_ to a Boolean
  def self.Boolean(s)
    if s.strip == "true"
      true
    elsif s.strip == "false"
      false
    else
      raise ArgumentError, "invalid value for Boolean: \"#{s}\""
    end
  end
  
  # Tries to parse _s_ thanks to the class _t_
  def self.Parse(s,t)
    if t.respond_to?(:parse)
      t.parse(s)
    else
      raise ArgumentError, "#{t} does not parse"
    end
  end
  
  Ruby = Coercions.new do |g|
    g.coercion String, Integer, lambda{|s,t| Integer(s)        }
    g.coercion String,   Float, lambda{|s,t| Float(s)          }
    g.coercion String, Boolean, lambda{|s,t| Boolean(s)        }
    g.coercion Integer,  Float, lambda{|s,t| Float(s)          }
    g.coercion String,  Symbol, lambda{|s,t| s.to_sym          }
    g.coercion String,  Regexp, lambda{|s,t| Regexp.compile(s) }
    g.coercion String,     ANY, lambda{|s,t| Parse(s,t)        }
  end
  
end # module Myrrha
require "myrrha/version"
require "myrrha/loader"