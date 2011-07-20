#
# Coercion graph
#
module Coercer
  
  class Error < StandardError; end
  
  # 
  # Defines a coercion graph
  #
  class Graph
    
    class Node
      attr_accessor :domain
      def initialize(domain)
        @domain = domain
      end
      def out_edges
        @out_edges || []
      end
      def add_out_edge(edge)
        @out_edges ||= []
        @out_edges << edge
      end
    end
    
    class Edge
      attr_reader :source
      attr_reader :target
      attr_reader :converter
      def initialize(source, target, converter)
        @source = source
        @target = target
        @converter = converter
      end
    end
    
    def initialize
      @nodes = []
      yield(self) if block_given?
    end
    
    def coercion(source, target, converter = nil, &convproc)
      converter ||= convproc
      connect(node(source, true), node(target, true), converter)
    end
    
    def coerce(value, target_domain)
      # 1) return value if it already belongs to the domain
      return value if belongs_to?(value, target_domain)
      
      error = nil
      # 2) find the corresponding source domain
      @nodes.each do |source_node|
        next unless belongs_to?(value, source_node.domain)
        
        # 3) look at the edges
        source_node.out_edges.each do |edge|
          next unless subdomain?(edge.target.domain, target_domain)

          # 4) apply coercion
          begin
            return edge.converter.call(value)
          rescue => ex
            error = ex.message unless error
          end
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
    
    protected
    
    def node(domain, create)
      found = @nodes.find{|n| n.domain == domain}
      if found.nil? && create
        found = Node.new(domain)
        @nodes << found
      end
      found
    end
    
    def connect(source, target, converter)
      edge = Edge.new(source, target, converter)
      source.add_out_edge(edge)
    end
    
  end # class Graph
  
end # module Coercer
require "coercer/version"
require "coercer/loader"
