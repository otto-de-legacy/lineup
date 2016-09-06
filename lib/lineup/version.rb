module Lineup
  class Version
    MAJOR = 0
    MINOR = 7
    PATCH = 2

    class << self
      def to_s
        [MAJOR, MINOR, PATCH].join('.')
      end
    end
  end
end
