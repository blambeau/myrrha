module Myrrha
  module Domain
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
  end # module Domain
end # module Myrrha