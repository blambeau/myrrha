#
# Myrrha -- the missing coercion framework for Ruby
#
module Myrrha
  
  #
  # Raised when a coercion fails
  #
  class Error < StandardError; end
  
  #
  # Builds a set of coercions rules. 
  #
  # Example:
  #
  #   rules = Myrrha.coercions do |c|
  #     c.coercion String, Integer, lambda{|s,t| Integer(s)}
  #     #
  #     # [...]
  #     #
  #     c.fallback String, lambda{|s,t| ... }
  #   end
  #
  def self.coercions(&block)
    Coercions.new(&block)
  end
  
  #
  # Creates a domain instance
  #
  # Example:
  #
  #   # from a class
  #   Myrrha.domain(Integer)  # => ClassDomain<Integer>
  #
  #   # from a proc 
  #   Myrrha.domain(:Name){|v| v.is_a?(Symbol)}
  #
  def self.domain(name, superdomain = nil, predicate = nil, &pred)
    if superdomain.nil? and predicate.nil? and pred.nil?
      Domain.coerce(name)
    else
      Domain::PredicateDomain.new(name, superdomain, predicate || pred)
    end
  end
  
  # 
  # Encapsulates the notion of abstract domain
  #
  class Domain
    
    #
    # Coerces `arg` to a domain
    #
    def self.coerce(arg)
      case arg
      when Class
        ClassDomain.new(arg)
      when Proc
        PredicateDomain.new(:Unnamed, nil, arg)
      else
        if arg.respond_to?(:===)
          PredicateDomain.new(:Unnamed, nil, arg)
        else
          raise ArgumentError, "Invalid value for Domain(): #{arg.inspect}"
        end
      end
    end
    
    #
    # Defines a Domain through a ruby Class
    # 
    class ClassDomain < Domain
      
      # Coerced ruby class
      attr_reader :clazz
      
      #
      # Creates a ClassDomain instance
      # 
      def initialize(clazz)
        @clazz = clazz
      end
      
      #
      # Returns this domain name
      #
      # @return [Symbol] the domain name
      #
      def name
        clazz.name.to_sym
      end
      
      #
      # Returns true if <code>@clazz === value</code>, false otherwise
      #
      def is_value?(value, target_domain = nil)
        @clazz === value
      end
      alias :=== :is_value?
      
      #
      # Checks if this domain is a sub domain of `domain`
      #
      # @return [Boolean] true if `domain` is a ClassDomain and its class
      #         is a superclass of this domain class
      #
      def subdomain_of?(domain)
        domain.is_a?(ClassDomain) && 
        is_subclass?(self.clazz, domain.clazz) 
      end
      
      # Returns a string representation
      def to_s
        name.to_s
      end
      
      # Returns a string inspection
      def inspect
        "Domain<#{to_s}>"
      end
      
      private 
      
      # Checks if `child` is a subclass of `parent`
      def is_subclass?(child, parent)
        (child == parent) || 
        (child.superclass && is_subclass?(child.superclass, parent))
      end
      
    end # class ClassDomain
    
    #
    # Defines a Domain through a predicate
    #
    class PredicateDomain < Domain
      
      # @return [Symbol] domain name
      attr_reader :name
      
      # @return [Domain] super domain
      attr_reader :super_domain
      
      #
      # Creates a domain instance
      #
      def initialize(name, super_domain, predicate)
        @name = name
        @super_domain = super_domain
        @predicate = predicate
      end
      
      #
      # Checks if `value` belongs to the domain with the predicate.
      #
      def is_value?(value, target_domain = nil)
        p = @predicate
        res = if p.respond_to?(:call)
          p.respond_to?(:arity) && (p.arity == 2) ?
            p.call(value, target_domain) :
            p.call(value)
        else
          p === value
        end
        res ? res : 
          (super_domain ? super_domain.is_value?(value, target_domain) : false)
      end
      alias :=== :is_value?
      
      # 
      # Checks if this domain is a sub domain of `domain`
      #
      def subdomain_of?(domain)
        (domain == self) ||
        (super_domain && super_domain.subdomain_of?(domain))
      end
      
      # Returns a string representation
      def to_s
        name.to_s
      end
      
      # Returns a string inspection
      def inspect
        "PredicateDomain<#{to_s}>"
      end
      
    end # class PredicateDomain
    
  end # class Domain
  
  # 
  # Defines a set of coercion rules
  #
  class Coercions
    
    # @return [Domain] The main target domain, if any
    attr_accessor :main_target_domain
    
    #
    # Creates an empty list of coercion rules
    #
    def initialize(upons = [], rules = [], fallbacks = [], main_target_domain = nil)
      @upons = upons
      @rules = rules
      @fallbacks = fallbacks
      @appender = :<<
      @main_target_domain = main_target_domain
      yield(self) if block_given?
    end
    
    # (see Myrrha.domain)
    def domain(*args, &pred)
      Myrrha.domain(*args, &pred)
    end
    
    #
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
    
    #
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
    
    #
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
      rule = rule([source, nil, converter || convproc])
      @upons.send(@appender, rule)
      self
    end
    
    #
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
      rule = rule([source, target, converter || convproc])
      @rules.send(@appender, rule)
      self
    end
    
    #
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
      rule = [source, nil, converter || convproc]
      @fallbacks.send(@appender, rule)
      self
    end
    
    #
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
        next unless to.nil?   or subdomain?(to, target_domain)
        begin
          catch(:nextrule){
            return convert(value, target_domain, converter)
          }
        rescue => ex
          error = ex.message unless error
        end
      end
      msg = "Unable to coerce `#{value}` to #{target_domain}"
      msg += " (#{error})" if error
      raise Error, msg
    end
    alias :apply :coerce
    
    #
    # Returns true if `value` can be considered as a valid element of the 
    # domain `domain`, false otherwise.
    #
    # @param [Object] value any ruby value
    # @param [Domain] domain a domain (mimic Domain)
    # @return [Boolean] true if `value` belongs to `domain`, false otherwise
    #
    def belongs_to?(value, domain, target_domain = domain)
      case domain
      when Domain
        domain.is_value?(value, target_domain)
      when Proc
        belongs_to? value, Domain.coerce(domain), target_domain
      else 
        if domain.respond_to?(:===) 
          belongs_to? value, Domain.coerce(domain), target_domain
        else 
          false
        end
      end
    end
    
    #
    # Returns `true` if `child` can be considered a valid sub domain of 
    # `parent`, false otherwise.
    #
    # @param [Domain] child a domain (mimic Domain)
    # @param [Domain] parent another domain (mimic Domain)
    # @return [Boolean] true if `child` is a subdomain of `parent`, false 
    #         otherwise.
    #
    def subdomain?(child, parent)
      return true if child == parent
      if child.is_a?(Domain) && parent.is_a?(Domain)
        child.subdomain_of?(parent)
      else
        (child.respond_to?(:superclass) && child.superclass) ? 
          subdomain?(child.superclass, parent) :
          false
      end
    end
    
    #
    # Duplicates this set of rules in such a way that the original will not
    # be affected by any change made to the copy.
    #
    # @return [Coercions] a copy of this set of rules
    # 
    def dup
      Coercions.new(@upons.dup, @rules.dup, @fallbacks.dup, main_target_domain)
    end
    
    private
    
    # Coerces `args` to a rule triple 
    def rule(args)
      args
    end
    
    # Extends existing rules
    def extend_rules(appender, block)
      @appender = appender
      block.call(self)
      self
    end
    
    #
    # Yields each rule in turn (upons, coercions then fallbacks)
    #
    def each_rule(&proc)
      @upons.each(&proc)
      @rules.each(&proc)
      @fallbacks.each(&proc)
    end
    
    #
    # Calls converter on a (value,target_domain) pair.
    # 
    def convert(value, target_domain, converter)
      if converter.respond_to?(:call)
        converter.call(value, target_domain)
      else
        raise ArgumentError, "Unable to use #{converter} for coercing"
      end
    end
    
  end # class Coercions
    
  # Myrrha main options
  OPTIONS = {
    :core_ext => false
  }
  
  # Install core extensions?
  def self.core_ext?
    OPTIONS[:core_ext]
  end
  
end # module Myrrha
require "myrrha/version"
require "myrrha/loader"