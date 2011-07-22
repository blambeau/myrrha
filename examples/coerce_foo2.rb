require 'myrrha/coerce'

class Foo
  def initialize(arg)
    @arg = arg
  end
end

Myrrha::Coerce.append do |r|
  r.coercion(Symbol, Foo) do |value, _|
    Foo.new(value)
  end
end 

Myrrha.coerce(:hello, Foo) 
# => #<Foo:0x8866f84 @arg=:hello>

