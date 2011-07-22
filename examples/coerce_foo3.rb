require 'myrrha/coerce'

class Foo
  def initialize(arg)
    @arg = arg
  end
end

MyRules = Myrrha::CoerceRules.dup.append do |r|
  r.coercion(Symbol, Foo) do |value, _|
    Foo.new(value)
  end
end 

begin
  Myrrha.coerce(:hello, Foo)
  raise "Unexpected"
rescue Myrrha::Error
  # => Myrrha::Error: Unable to coerce `hello` to Foo
end

MyRules.coerce(:hello, Foo) 
# =>  #<Foo:0x8b7d254 @arg=:hello>
