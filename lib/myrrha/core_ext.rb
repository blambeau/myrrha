require 'myrrha'
Boolean = Myrrha::Boolean

# 
# Coerces _value_ to an instance of _domain_
#
def coerce(value, domain)
  Myrrha::Ruby.coerce(value, domain)
end