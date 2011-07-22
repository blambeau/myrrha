require 'myrrha/coerce'

class Foo
  def initialize(arg)
    @arg = arg
  end
  def self.coerce(arg)
    Foo.new(arg)
  end
end

Myrrha.coerce(:hello, Foo) 
