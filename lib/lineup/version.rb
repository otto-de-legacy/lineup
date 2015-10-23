module Lineup
  class Version
    MAJOR = 0
    MINOR = 2
    PATCH = 1

    class << self
      def to_s
        [MAJOR, MINOR, PATCH].join('.')
      end
    end
  end
end
