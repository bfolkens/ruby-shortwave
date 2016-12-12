module Shortwave
  module Pipeline
    class IO
      def initialize(io)
        @io = io
        @size = nil
      end

      def size
        @size
      end

      def rewind
        @io.rewind
      end

      def reader
        Fiber.new {
          @size = @io.size
          Fiber.yield @io.readpartial(BUFFER_SIZE)
        }
      end
    end
  end
end
