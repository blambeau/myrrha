require 'myrrha/with_core_ext'
require 'myrrha/coerce'
require 'date'

values = ["12", "true", "2011-07-20"]
types  = [Integer, Boolean, Date]
values.zip(types).collect do |value,domain|
  coerce(value, domain)
end
# => [12, true, #<Date: 2011-07-20 (...)>]
