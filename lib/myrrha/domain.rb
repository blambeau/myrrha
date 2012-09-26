module Myrrha
  module Domain

    # Creates a domain instance by specialization by constraint
    #
    # @param [Class] superdom the superdomain of the created domain
    # @param [Proc] pred the domain predicate
    # @return [Class] the created domain
    def self.native(superdom = Object, subdoms=nil, &pred)
      dom = Class.new(superdom).extend(Native)
      dom.instance_eval {
        @subdomains = subdoms
        @superdomain = superdom
        @predicate = pred
      }
      dom
    end

    # Returns a module containing instance methods for building a domain.
    #
    # @return [Module] a module to be included in a domain implementation.
    def self.impl(*component_names)
      Domain::Impl.new(component_names)
    end

  end # module Domain
end # module Myrrha
require_relative 'domain/value_methods'
require_relative 'domain/coercion_methods'
require_relative 'domain/impl'
require_relative 'domain/native'
