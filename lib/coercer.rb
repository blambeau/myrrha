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
    
    def coerce(value, domain)
      source_domain = value.class
      source_node = node(source_domain, false)
      unless source_node
        raise Error, "No such source domain #{source_domain}"
      end
      edge = source_node.out_edges.find{|e| 
        e.target.domain == domain
      }
      edge.converter.call(value)
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
