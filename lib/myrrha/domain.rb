module Myrrha
  module Domain

    # Creates a domain instance by specialization by constraint
    #
    # @param [Class] superdom the superdomain of the created domain
    # @param [Proc] pred the domain predicate
    # @return [Class] the created domain
    def self.sbyc(superdom = Object, subdoms = [], &pred)
      Class.new(superdom).extend SByC.new(superdom, subdoms, pred)
    end

  end # module Domain
end # module Myrrha
require_relative 'domain/value_methods'
require_relative 'domain/coercion_methods'
require_relative 'domain/scalar'
require_relative 'domain/sbyc'
