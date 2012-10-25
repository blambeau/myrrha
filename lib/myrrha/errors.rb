module Myrrha

  # Raised when a coercion fails
  class Error < StandardError
    attr_accessor :cause
    def initialize(msg, cause = $!)
      super(msg)
      @cause = cause
    end
  end

end # module Myrrha
