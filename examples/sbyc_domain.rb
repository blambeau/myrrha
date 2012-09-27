require 'myrrha'

PosInt = Domain.sbyc(Integer){|i| i>0}

###
  
PosInt.class
PosInt.superclass
PosInt.ancestors
PosInt === 10
PosInt === -1
PosInt.new(10)
begin
  PosInt.new(-10)
  raise "Unexpected case: PosInt.new(-10) succeeds"
rescue ArgumentError => ex
  puts ex.message
end

###

10.is_a?(PosInt)
10.kind_of?(PosInt)

###

rules = Myrrha.coercions do |r|
  r.coercion String, Integer, lambda{|s,t| Integer(s)}  
end 
rules.coerce("12", Integer)
rules.coerce("12", PosInt)
rules.coerce("-12", Integer)
begin
  rules.coerce("-12", PosInt)
  raise "Unexpected case: rules.coerce('-12', PosInt) succeeds"
rescue Myrrha::Error => ex
  puts ex.message
end
