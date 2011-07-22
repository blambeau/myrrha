require "myrrha/to_ruby_literal"

class Foo
  attr_reader :arg
  def initialize(arg)
    @arg = arg
  end
end

MyRules = Myrrha::ToRubyLiteral.dup.append do |r|
  r.coercion(Foo, :to_ruby_literal) do |foo, _|
    "Foo.new(#{foo.arg.inspect})"
  end
end

# Myrrha.to_ruby_literal is actually a shortcut for:
Myrrha::ToRubyLiteral.apply(Foo.new(:hello), :to_ruby_literal)
# => "Marshal.load('...')"

MyRules.apply(Foo.new(:hello), :to_ruby_literal)
# => "Foo.new(:hello)" 
