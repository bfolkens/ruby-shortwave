require_relative 'base'

module Shortwave
  module Backend
    class Noop < Base

      def write(io)
        # Noop        
      end

      def read
        # Noop
      end

      def delete!
        # Noop
      end

      def file_path
        # Noop
      end
    end
  end
end
