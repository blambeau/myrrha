module Myrrha
  module Version

    MAJOR = 2
    MINOR = 0
    TINY  = 0

    def self.to_s
      [ MAJOR, MINOR, TINY ].join('.')
    end

  end
  VERSION = Version.to_s
end
