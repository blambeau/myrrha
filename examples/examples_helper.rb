$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "myrrha"
class Object
  
  def eq(x)
    lambda{|y| raise("Expected #{x} but was #{y} ") unless x == y}
  end
  
  def be_a(clazz)
    lambda{|y| raise("Expected #{y.inspect} to be a #{clazz}") unless y.is_a?(clazz)}
  end
  
  def should(matcher)
    matcher.call(self)
  end
  
end