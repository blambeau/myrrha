module Domain
  module CoercionMethods

    def coercions(&bl)
      @coercions ||= ::Myrrha::Coercions.new{|c|
        c.main_target_domain = self
        c.error_handler = lambda{|v,t,c|
          raise c if TypeError===c
          domain_error!(v)
        }
      }
      @coercions.append(&bl) if bl
      @coercions
    end

    def coerce(arg)
      coercions.coerce(arg, self)
    end
    alias_method :[], :coerce

  end # module CoercionMethods
  include CoercionMethods
end # module Domain