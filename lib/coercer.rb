#
# Coercion graph
#
module Coercer
  
  # Raised when a coercion fails
  class Error < StandardError; end
  
  # 
  # Defines a coercion graph
  #
  class Graph
    
    def initialize
      @edges = []
      yield(self) if block_given?
    end
    
    def coercion(source, target, converter = nil, &convproc)
      @edges << [source, target, converter || convproc] 
    end
    
    def coerce(value, target_domain)
      return value if belongs_to?(value, target_domain)
      error = nil
      @edges.each do |from,to,converter|
        next unless belongs_to?(value, from)
        next unless subdomain?(to, target_domain)
        begin
          return converter.call(value, target_domain)
        rescue => ex
          error = ex.message unless error
        end
      end
      msg = "Unable to coerce `#{value}` to #{target_domain}"
      msg += " (#{error})" if error
      raise Error, msg
    end
    
    def belongs_to?(value, domain)
      domain === value
    end
    
    def subdomain?(child, parent)
      return true if child == parent
      child.superclass ? 
        subdomain?(child.superclass, parent) :
        false
    end
    
  end # class Graph
  
  module Boolean
    def self.superclass; Object; end
    def self.===(val)
      (val == true) || (val == false)
    end
  end
  
  def self.Boolean(s)
    if s.strip == "true"
      true
    elsif s.strip == "false"
      false
    else
      raise ArgumentError, "invalid value for Boolean: \"#{s}\""
    end
  end
  
  def Parse(s,t)
    if t.respond_to?(:parse)
      t.parse(s)
    else
      raise ArgumentError, "#{t} does not parse"
    end
  end
  
  Ruby = Graph.new do |g|
    g.coercion String, Integer, lambda{|s,t| Integer(s)}
    g.coercion String, Float,   lambda{|s,t| Float(s)  }
    g.coercion String, Boolean, lambda{|s,t| Boolean(s)}
    g.coercion Integer, Float,  lambda{|s,t| Float(s)  }
    g.coercion String, Object,  lambda{|s,t| Parse(s,t)}
  end
  
end # module Coercer
require "coercer/version"
require "coercer/loader"
