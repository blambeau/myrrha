require_relative "myrrha/version"
require_relative "myrrha/loader"
require_relative 'myrrha/errors'
require_relative 'myrrha/ext/domain'
#
# Myrrha -- the missing coercion framework for Ruby
#
module Myrrha

  require_relative 'myrrha/coercions'

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
