module Lineup
  class Version
    MAJOR = 0
    MINOR = 5
    PATCH = 0

    class << self
      def to_s
        [MAJOR, MINOR, PATCH].join('.')
      end
    end
  end
end
