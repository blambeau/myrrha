require_relative "myrrha/version"
require_relative "myrrha/loader"
require_relative 'myrrha/errors'
#
# Myrrha -- the missing coercion framework for Ruby
#
module Myrrha

  require_relative 'myrrha/domain'
  require_relative 'myrrha/coercions'

  # Creates a domain instance by specialization by constraint
  #
  # @param [Class] superdom the superdomain of the created domain
  # @param [Proc] pred the domain predicate
  # @return [Class] the created domain
  def self.domain(superdom = Object, subdoms=nil, &pred)
    dom = Class.new(superdom).extend(Domain)
    dom.instance_eval {
      @subdomains = subdoms
      @superdomain = superdom
      @predicate = pred
    }
    dom
  end

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

  # Myrrha main options
  OPTIONS = {
    :core_ext => false
  }

  # Install core extensions?
  def self.core_ext?
    OPTIONS[:core_ext]
  end

end # module Myrrha
