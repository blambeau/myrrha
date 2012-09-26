module Myrrha
  module Domain
    class SByC < Module

      def initialize(super_domain, sub_domains, predicate)
        @super_domain = super_domain
        @sub_domains = sub_domains
        @predicate = predicate
        define
      end

    private

      def define
        define_super_domain_method
        define_sub_domains_method
        define_predicate_method
        include_type_methods
      end

      def define_super_domain_method
        super_domain = @super_domain
        define_method(:super_domain){ super_domain }
      end

      def define_sub_domains_method
        sub_domains = @sub_domains
        define_method(:sub_domains){ sub_domains }
      end

      def define_predicate_method
        predicate = @predicate
        define_method(:predicate){ predicate }
      end

      def include_type_methods
        module_eval{ include TypeMethods }
      end

      module TypeMethods

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
          super_domain || super
        end

        # Returns true if clazz if an explicit sub domain of self or if it's the case in Ruby.
        def superdomain_of?(child)
          sub_domains.include?(child)
        end

        # Checks if `value` belongs to this domain
        def ===(value)
          (superclass === value) && predicate.call(value)
        end

      end # module TypeMethods

    end # module SByC
  end # module Domain
end # module Myrrha
