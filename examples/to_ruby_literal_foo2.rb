require "myrrha/to_ruby_literal"

class Foo
  attr_reader :arg
  def initialize(arg)
    @arg = arg
  end
end

Myrrha::ToRubyLiteral.append do |r|
  r.coercion(Foo) do |foo, _|
    "Foo.new(#{foo.arg.inspect})"
  end
end

Myrrha.to_ruby_literal(Foo.new(:hello))
# => "Foo.new(:hello)" 
