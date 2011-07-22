require 'myrrha/coerce'

Myrrha.coerce("12", Integer)            # => 12
Myrrha.coerce("12.0", Float)            # => 12.0

Myrrha.coerce("true", Myrrha::Boolean)  # => true
