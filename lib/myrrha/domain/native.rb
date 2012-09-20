module Myrrha
  module Domain
    module Native

      # Creates a new instance of this domain
      def new(*args)
        if (args.size == 1) && (superclass===args.first)
          raise ArgumentError, "Invalid value #{args.join(' ')} for #{self}" unless self===args.first
          args.first
        elsif superclass.respond_to?(:new)
          new(super(*args))
        else
          raise ArgumentError, "Invalid value #{args.join(' ')} for #{self}"
        end
      end

      # (see Class.superclass)
      def superclass
        superdomain || super
      end

      # Returns the super domain if installed
      def superdomain
        @superdomain
      end

      # Returns true if clazz if an explicit sub domain of self or if it's the case in Ruby.
      def superdomain_of?(child)
        Array(@subdomains).include?(child)
      end

      # Checks if `value` belongs to this domain
      def ===(value)
        (superclass === value) && predicate.call(value)
      end

      # Returns the specialization by constraint predicate
      #
      # @return [Proc] the domain predicate
      def predicate
        @predicate
      end

    end # module Native
  end # module Domain
end # module Myrrha