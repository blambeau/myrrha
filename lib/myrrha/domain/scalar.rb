module Myrrha
  module Domain
    class Scalar < Module

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

      def define_component_names_on(clazz)
        component_names = @component_names
        clazz.define_singleton_method(:component_names){ component_names }
      end

      def define_coercion_methods_on(clazz)
        clazz.extend(CoercionMethods)
      end

    end # class Scalar
    Impl = Scalar
  end # module Domain
end # module Myrrha
