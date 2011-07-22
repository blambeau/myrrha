require "myrrha/to_ruby_literal"

class Foo
  attr_reader :arg
  def initialize(arg)
    @arg = arg
  end
end

Myrrha::ToRubyLiteralRules.append do |r|
  r.coercion(Foo, :to_ruby_literal) do |foo, _|
    "Foo.new(#{foo.arg.inspect})"
  end
end

Myrrha.to_ruby_literal(Foo.new(:hello))
# => "Foo.new(:hello)" 
