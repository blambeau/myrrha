require "myrrha/to_ruby_literal"

class Foo
  attr_reader :arg
  def initialize(arg)
    @arg = arg
  end
  def to_ruby_literal
    "Foo.new(#{arg.inspect})"
  end
end

Myrrha.to_ruby_literal(Foo.new(:hello))
# => "Foo.new(:hello)" 
