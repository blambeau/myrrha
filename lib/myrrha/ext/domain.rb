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

    def [](first = NOT_PROVIDED, *args)
      if first == NOT_PROVIDED
        coerce([])
      elsif args.empty?
        coerce(first)
      else
        coerce(args.unshift(first))
      end
    end

    NOT_PROVIDED = Object.new
  end # module CoercionMethods
  include CoercionMethods
end # module Domain