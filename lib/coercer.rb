#
# Coercion graph
#
module Coercer
  
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
      # 1) return value if it already belongs to the domain
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
  
end # module Coercer
require "coercer/version"
require "coercer/loader"
