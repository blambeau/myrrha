module Myrrha
  # Defines a set of coercion rules
  #
  class Coercions

    # @return [Domain] The main target domain, if any
    attr_accessor :main_target_domain

    # Creates an empty list of coercion rules
    def initialize(&defn)
      @definitions = []
      @upons = []
      @rules = []
      @fallbacks = []
      @appender = :<<
      @main_target_domain = nil
      extend_rules(:<<, defn) if defn
    end

    # Appends the list of rules with new ones.
    #
    # New upon, coercion and fallback rules will be put after the already
    # existing ones, in each case.
    #
    # Example:
    #
    #   rules = Myrrha.coercions do ... end
    #   rules.append do |r|
    #
    #     # [previous coercion rules would come here]
    #
    #     # install new rules
    #     r.coercion String, Float, lambda{|v,t| Float(t)}
    #   end
    #
    def append(&proc)
      extend_rules(:<<, proc)
    end

    # Prepends the list of rules with new ones.
    #
    # New upon, coercion and fallback rules will be put before the already
    # existing ones, in each case.
    #
    # Example:
    #
    #   rules = Myrrha.coercions do ... end
    #   rules.prepend do |r|
    #
    #     # install new rules
    #     r.coercion String, Float, lambda{|v,t| Float(t)}
    #
    #     # [previous coercion rules would come here]
    #
    #   end
    #
    def prepend(&proc)
      extend_rules(:unshift, proc)
    end

    # Adds an upon rule for a source domain.
    #
    # Example:
    #
    #   Myrrha.coercions do |r|
    #
    #     # Don't even try something else on nil
    #     r.upon(NilClass){|s,t| nil}
    #     [...]
    #
    #   end
    #
    # @param source [Domain] a source domain (mimic Domain)
    # @param converter [Converter] an optional converter (mimic Converter)
    # @param convproc [Proc] used when converter is not specified
    # @return self
    #
    def upon(source, converter = nil, &convproc)
      @upons.send(@appender, [source, nil, converter || convproc])
      self
    end

    # Adds an upon rule that works by delegation if the value responds to `method`.
    #
    # Example:
    #
    #     Myrrha.coercions do |r|
    #       r.delegate(:to_foo)
    #
    #       # is a shortcut for
    #       r.upon(lambda{|v,_| v.respond_to?(:to_foo)}){|v,_| v.to_foo}
    #     end
    #
    def delegate(method, &convproc)
      convproc ||= lambda{|v,t| v.send(method) }
      upon(lambda{|v,t| v.respond_to?(method) }, convproc)
    end

    # Adds a coercion rule from a source to a target domain.
    #
    # The conversion can be provided through `converter` or via a block
    # directly. See main documentation about recognized converters.
    #
    # Example:
    #
    #   Myrrha.coercions do |r|
    #
    #     # With an explicit proc
    #     r.coercion String, Integer, lambda{|v,t|
    #       Integer(v)
    #     }
    #
    #     # With an implicit proc
    #     r.coercion(String, Float) do |v,t|
    #       Float(v)
    #     end
    #
    #   end
    #
    # @param source [Domain] a source domain (mimicing Domain)
    # @param target [Domain] a target domain (mimicing Domain)
    # @param converter [Converter] an optional converter (mimic Converter)
    # @param convproc [Proc] used when converter is not specified
    # @return self
    #
    def coercion(source, target = main_target_domain, converter = nil, &convproc)
      @rules.send(@appender, [source, target, converter || convproc])
      self
    end

    # Adds a fallback rule for a source domain.
    #
    # Example:
    #
    #   Myrrha.coercions do |r|
    #
    #     # Add a 'last chance' rule for Strings
    #     r.fallback(String) do |v,t|
    #       # the user wants _v_ to be converted to a value of domain _t_
    #     end
    #
    #   end
    #
    # @param source [Domain] a source domain (mimic Domain)
    # @param converter [Converter] an optional converter (mimic Converter)
    # @param convproc [Proc] used when converter is not specified
    # @return self
    #
    def fallback(source, converter = nil, &convproc)
      @fallbacks.send(@appender, [source, nil, converter || convproc])
      self
    end

    # Coerces `value` to an element of `target_domain`
    #
    # This method tries each coercion rule, then each fallback in turn. Rules
    # for which source and target domain match are executed until one succeeds.
    # A Myrrha::Error is raised if no rule matches or executes successfuly.
    #
    # @param [Object] value any ruby value
    # @param [Domain] target_domain a target domain to convert to (mimic Domain)
    # @return self
    #
    def coerce(value, target_domain = main_target_domain)
      return value if belongs_to?(value, target_domain)
      error = nil
      each_rule do |from,to,converter|
        next unless from.nil? or belongs_to?(value, from, target_domain)
        begin
          catch(:nextrule) do
            if to.nil? or subdomain?(to, target_domain)
              got = convert(value, target_domain, converter)
              return got
            elsif subdomain?(target_domain, to)
              got = convert(value, to, converter)
              return got if belongs_to?(got, target_domain)
            end
          end
        rescue => ex
          error = ex unless error
        end
      end
      raise Error.new("Unable to coerce `#{value}` to #{target_domain}", error)
    end
    alias :apply :coerce

    # Duplicates this set of rules in such a way that the original will not
    # be affected by any change made to the copy.
    #
    # @return [Coercions] a copy of this set of rules
    #
    def dup
      c = Coercions.new
      @definitions.each do |defn|
        c.extend_rules(*defn)
      end
      c
    end

  protected

    # Returns true if `value` can be considered as a valid element of the
    # domain `domain`, false otherwise.
    #
    # @param [Object] value any ruby value
    # @param [Domain] domain a domain (mimic Domain)
    # @return [Boolean] true if `value` belongs to `domain`, false otherwise
    #
    def belongs_to?(value, domain, target_domain = domain)
      if domain.is_a?(Proc) and domain.arity==2
        domain.call(value, target_domain)
      else
        domain.respond_to?(:===) && (domain === value)
      end
    end

    # Returns `true` if `child` can be considered a valid sub domain of
    # `parent`, false otherwise.
    #
    # @param [Domain] child a domain (mimic Domain)
    # @param [Domain] parent another domain (mimic Domain)
    # @return [Boolean] true if `child` is a subdomain of `parent`, false
    #         otherwise.
    #
    def subdomain?(child, parent)
      if child == parent
        true
      elsif parent.respond_to?(:super_domain_of?)
        parent.super_domain_of?(child)
      elsif child.respond_to?(:superclass) && child.superclass
        subdomain?(child.superclass, parent)
      else
        false
      end
    end

    # Extends existing rules
    def extend_rules(appender, block)
      @definitions << [appender, block]
      @appender = appender
      block.call(self)
      self
    end

    # Yields each rule in turn (upons, coercions then fallbacks)
    def each_rule(&proc)
      @upons.each(&proc)
      @rules.each(&proc)
      @fallbacks.each(&proc)
    end

    # Calls converter on a (value,target_domain) pair.
    def convert(value, target_domain, converter)
      if converter.respond_to?(:call)
        converter.call(value, target_domain)
      elsif converter.is_a?(Array)
        path = converter + [target_domain]
        path.inject(value){|cur,ndom| coerce(cur, ndom)}
      else
        raise ArgumentError, "Unable to use #{converter} for coercing"
      end
    end

  end # class Coercions
end # module Myrrha
