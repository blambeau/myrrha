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
      
      # 2) find the corresponding source domain
      source_node = @nodes.find{|n| belongs_to?(value, n.domain)}
      unless source_node
        raise Error, "No source domain for #{value}"
      end
      
      # 3) look at the edges and find the good one
      edge = source_node.out_edges.find{|e| 
        e.target.domain == target_domain
      }
      unless edge
        raise Error, "No such edge #{source_node.domain} -> #{target_domain}"
      end
      
      # 4) apply coercion
      edge.converter.call(value)
    end
    
    def belongs_to?(value, domain)
      value.class == domain
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
