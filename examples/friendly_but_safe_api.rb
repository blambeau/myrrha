require File.expand_path('../examples_helper', __FILE__)

#
# Sometimes building friendly public APIs requires some type flexibility 
# at the public interface, that is coercion.
#
# In the example below, the API class defines a public interface. The Foo 
# class is a pseudo-internal class: it is not intended to be instantiated 
# by users, but can be manipulated once obtained (typically reused as an 
# argument for a later call to the API). An array of symbol is a good kind 
# of Foo literals. Therefore, the API should allow both Foo instance and 
# arrays of symbols in a 'flexible but safe' way. 
#
class API

  # Foo is an internal class, that users should not instantiate directly. 
  # Instances of Foo can are sometimes returned by internals, are reused 
  # later as API arguments (see below).
  class Foo
    
    attr_reader :elements
    
    def initialize(elements)
      @elements = elements
    end
    
    def reverse
      Foo.new(elements.reverse)
    end
    
    def inspect
      "Foo(#{elements.inspect})"
    end
    alias :to_s :inspect
  
  end
  
  # We define a simple rule for coercing arrays of symvols
  # as Foo instances
  Coercions = Myrrha.coercions do |r|
    FriendlyFoo = lambda{|v| v.is_a?(Array) and v.all?{|s| s.is_a?(Symbol)}}
    r.coercion FriendlyFoo, Foo, lambda{|v| Foo.new(v)}
  end
    
  #
  # Reverses a Foo.
  #
  # This method may be used with a Foo instance. It also accepts an array of 
  # symbols as a friendly Foo literal. 
  #
  def self.reverse(foo)
    Coercions.coerce(foo, Foo).reverse
  end

end # class API

# An initial call with an array of symbols work
puts(x = API.reverse([:a, :b]))

# And so is a call with a Foo instance
puts(y = API.reverse(x))

# An invalid call will simply fail
begin
  API.reverse("hello")
  true.should eq(false)
rescue Myrrha::Error => ex
  puts ex.message
end 

# this is for testing purposes
API.reverse([:a, :b]).should be_a(API::Foo)
API.reverse(API.reverse([:a, :b])).should be_a(API::Foo)