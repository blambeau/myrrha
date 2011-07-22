module Myrrha

  # These are all classes for which using inspect is safe for to_ruby_literal
  TO_RUBY_THROUGH_INSPECT = [ NilClass, TrueClass, FalseClass, 
                              Fixnum, Bignum, Float, 
                              String, Symbol, Class, Module, Regexp ]
  
  # Defines basic coercions for implementing to_ruby_literal
  ToRubyLiteralRules = coercions do |r|
    safe = lambda{|x| TO_RUBY_THROUGH_INSPECT.include?(x.class)}
    r.coercion(safe, :to_ruby_literal) do |s,t| 
      s.inspect
    end
    r.coercion(Range, :to_ruby_literal) do |s,t|
      (TO_RUBY_THROUGH_INSPECT.include?(s.first.class) &&
       TO_RUBY_THROUGH_INSPECT.include?(s.last.class)) ?
        s.inspect : throw(:nextrule)
    end
    r.coercion(Array, :to_ruby_literal) do |s,t|
      "[" + s.collect{|v| r.coerce(v, :to_ruby_literal)}.join(', ') + "]"
    end
    r.coercion(Hash, :to_ruby_literal) do |s,t|
      "{" + s.collect{|k,v| 
        r.coerce(k, :to_ruby_literal) + " => " + r.coerce(v, :to_ruby_literal) 
      }.join(', ') + "}"
    end
    r.fallback(Object) do |s,t| 
      "Marshal.load(#{Marshal.dump(s).inspect})"
    end
  end
  
  def self.to_ruby_literal(value = self)
    ToRubyLiteralRules.coerce(value, :to_ruby_literal)
  end
  
end # module Myrrha

if Myrrha.core_ext?

  class Object
  
    def to_ruby_literal
      Myrrha.to_ruby_literal(self)
    end
  
  end

end
