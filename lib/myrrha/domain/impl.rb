module Myrrha
  module Domain
    class Impl < Module

      def initialize(component_names)
        @component_names = component_names.freeze
        define_initialize
        define_component_readers
        include_value_methods
      end

      def included(clazz)
        define_component_names_on(clazz)
        define_coercion_methods_on(clazz)
        super
      end

    private

      def define_initialize
        component_names = @component_names
        define_method(:initialize){|*args|
          component_names.zip(args).each do |n,arg|
            instance_variable_set(:"@#{n}", arg)
          end
        }
      end

      def define_component_readers
        @component_names.each do |n|
          define_method(n){ instance_variable_get(:"@#{n}") }
        end
      end

      def include_value_methods
        module_eval{ include ValueMethods }
      end

      module ValueMethods

        # Parts of this module have been extracted from Virtus, MIT Copyright (c) 2011-2012
        # Piotr Solnica.

        # Returns a hash code for the value
        #
        # @return Integer
        #
        # @api public
        def hash
          component_names.map{|key| send(key).hash }.reduce(self.class.hash, :^)
        end

        # Compare the object with other object for equality
        #
        # @example
        #   object.eql?(other)  # => true or false
        #
        # @param [Object] other
        #   the other object to compare with
        #
        # @return [Boolean]
        #
        # @api public
        def eql?(other)
          instance_of?(other.class) and cmp?(__method__, other)
        end

        # Compare the object with other object for equivalency
        #
        # @example
        #   object == other  # => true or false
        #
        # @param [Object] other
        #   the other object to compare with
        #
        # @return [Boolean]
        #
        # @api public
        def ==(other)
          return false unless self.class <=> other.class
          cmp?(__method__, other)
        end

      private

        def cmp?(comparator, other)
          component_names.all?{|key| send(key).send(comparator, other.send(key)) }
        end

        def component_names
          self.class.component_names
        end

      end # module ValueMethods

      def define_component_names_on(clazz)
        component_names = @component_names
        clazz.define_singleton_method(:component_names){
          component_names
        }
      end

      def define_coercion_methods_on(clazz)
        clazz.extend(CoercionMethods)
      end

      module CoercionMethods

        def coercions(&bl)
          @coercions ||= Coercions.new
          @coercions.append(&bl) if bl
          @coercions
        end

        def coerce(arg)
          coercions.coerce(arg, self)
        end

      end # module CoercionMethods

    end # class Impl
  end # module Domain
end # module Myrrha
