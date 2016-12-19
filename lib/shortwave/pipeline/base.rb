module Shortwave
  module Pipeline
    class Base
      def |(destination)
        destination.pipeline = self
      end
    end
  end
end
