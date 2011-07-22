require 'myrrha'
module Myrrha

  # These are all classes for which using inspect is safe for to_ruby_literal
  TO_RUBY_THROUGH_INSPECT = [ NilClass, TrueClass, FalseClass, 
                              Fixnum, Bignum, Float, 
                              String, Symbol, Class, Module, Regexp ]
  
  # Defines basic coercions for implementing to_ruby_literal
  ToRubyLiteral = coercions do |r|
    r.main_target_domain = :to_ruby_literal
    
    r.upon(Object) do |s,t|
      s.to_ruby_literal{ throw :nextrule }
    end
    
    # On safe .inspect 
    safe = lambda{|x| TO_RUBY_THROUGH_INSPECT.include?(x.class)}
    r.coercion(safe) do |s,t| 
      s.inspect
    end
    
    # Best-effort on Range or let it be marshalled
    r.coercion(Range) do |s,t|
      (TO_RUBY_THROUGH_INSPECT.include?(s.first.class) &&
       TO_RUBY_THROUGH_INSPECT.include?(s.last.class)) ?
        s.inspect : throw(:nextrule)
    end
    
    # Be friendly on array
    r.coercion(Array) do |s,t|
      "[" + s.collect{|v| r.apply(v)}.join(', ') + "]"
    end
    
    # As well as on Hash
    r.coercion(Hash) do |s,t|
      "{" + s.collect{|k,v| 
        r.apply(k) + " => " + r.apply(v) 
      }.join(', ') + "}"
    end
    
    # Use Marshal by default
    r.fallback(Object) do |s,t| 
      "Marshal.load(#{Marshal.dump(s).inspect})"
    end
    
  end
  
  #
  # Converts `value` to a ruby literal
  #
  # @param [Object] value any ruby value
  # @return [String] a representation `s` of `value` such that 
  #         <code>Kernel.eval(s) == value</code> is true
  #
  def self.to_ruby_literal(value = self)
    block_given? ? 
      yield : 
      ToRubyLiteral.apply(value)
  end
  
end # module Myrrha

class Object

  #
  # Converts self to a ruby literal
  #
  # @return [String] a representation `s` of self such that 
  #         <code>Kernel.eval(s) == value</code> is true
  #
  def to_ruby_literal
    block_given? ? yield : Myrrha.to_ruby_literal(self)
  end

end if Myrrha.core_ext?