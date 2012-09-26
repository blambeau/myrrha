module Myrrha
  module Domain
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
  end # module Domain
end # module Myrrha
