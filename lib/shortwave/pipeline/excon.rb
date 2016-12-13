require 'iobuffer'

module Shortwave
  module Pipeline
    class Excon
      def initialize(url)
        @conn = ::Excon.new(url, tcp_nodelay: true, connect_timeout: 6, ssl_verify_peer: false)
        @size = nil
        @iobuffer = ::IO::Buffer.new
        @fiber_delegate = Fiber.new { process }
      end

      def open
        @iobuffer
      end

      def close
        @iobuffer.close
        @conn.close
      end

      def read(size = nil, buffer = nil)
        if @fiber_delegate.alive?
          # Make sure to consume the first yield if we haven't yet
          @size = @fiber_delegate.resume if @size.nil?

          # The remainder of yields return the remaining bytes
          remaining = @fiber_delegate.resume
        end

        @iobuffer.read(size).tap do |chunk|
          buffer.replace(chunk) if buffer
        end
      end

      def size
        @size || @size = @fiber_delegate.resume
      end

      def rewind
        @iobuffer.rewind
      end

      protected

      def process
        first_byte = true
        @conn.get(response_block: -> (chunk, remaining, total) {
          if first_byte
            first_byte = false
            Fiber.yield(total)
          end

          @iobuffer << chunk
          Fiber.yield(remaining)
        })
      end
    end
  end
end
