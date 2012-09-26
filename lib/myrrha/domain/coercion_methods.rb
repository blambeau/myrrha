module Myrrha
  module Domain
    module CoercionMethods

      def coercions(&bl)
        @coercions ||= Coercions.new{|c| c.main_target_domain = self}
        @coercions.append(&bl) if bl
        @coercions
      end

      def coerce(arg)
        coercions.coerce(arg, self)
      end

    end # module CoercionMethods
  end # module Domain
end # module Myrrha
