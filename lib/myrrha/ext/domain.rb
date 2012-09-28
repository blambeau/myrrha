module Domain
  module CoercionMethods

    def coercions(&bl)
      @coercions ||= ::Myrrha::Coercions.new{|c| c.main_target_domain = self}
      @coercions.append(&bl) if bl
      @coercions
    end

    def coerce(arg)
      coercions.coerce(arg, self)
    rescue Myrrha::Error
      domain_error!(arg)
    end

  end # module CoercionMethods
  include CoercionMethods
end # module Domain