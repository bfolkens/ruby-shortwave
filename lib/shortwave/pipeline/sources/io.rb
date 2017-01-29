module Shortwave
  module Pipeline
    class IO < Source
      def initialize(io)
        reset
        @io = io
      end

      def process
        if @first_byte
          @first_byte = false
          Fiber.yield(@io.size)
        end

        @iobuffer << @io.readpartial(::IO::Buffer.default_node_size)
        Fiber.yield
      end
    end
  end
end
