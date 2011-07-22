require "myrrha/to_ruby_literal"

class Foo
  attr_reader :arg
  def initialize(arg)
    @arg = arg
  end
end

MyRules = Myrrha::ToRubyLiteralRules.dup.append do |r|
  r.coercion(Foo, :to_ruby_literal) do |foo, _|
    "Foo.new(#{foo.arg.inspect})"
  end
end

Myrrha::ToRubyLiteralRules.coerce(Foo.new(:hello), :to_ruby_literal)
# => "Marshal.load('...')"

MyRules.coerce(Foo.new(:hello), :to_ruby_literal)
# => "Foo.new(:hello)" 
