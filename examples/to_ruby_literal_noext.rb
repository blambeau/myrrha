require 'date'
require 'myrrha/to_ruby_literal'

Myrrha.to_ruby_literal(1)              # => 1
Myrrha.to_ruby_literal(Date.today)     # => Marshal.load("...")
