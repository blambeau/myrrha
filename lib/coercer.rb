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
          return converter.call(value)
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
  
  Ruby = Graph.new do |g|
    g.coercion String, Integer, lambda{|s| Integer(s)}
    g.coercion String, Float,   lambda{|s| Float(s)  }
    g.coercion String, Boolean, lambda{|s| Boolean(s)}
  end
  
end # module Coercer
require "coercer/version"
require "coercer/loader"
