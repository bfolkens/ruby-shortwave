require 'iobuffer'
require 'fiber'

module Shortwave
  module Pipeline
    class Base
      def close
        @first_byte = true
        @iobuffer.close
      end

      def read(size = nil, buffer = nil)
        if @fiber_delegate.alive?
          # Make sure to consume the first yield if we haven't yet
          @size = @fiber_delegate.resume if @first_byte

          # The remainder of yields return the remaining bytes
          remaining = @fiber_delegate.resume
        end

        data = size.nil? ? @iobuffer.read : @iobuffer.read(size)
        data.tap do |chunk|
          buffer.replace(chunk) unless buffer.nil?
        end
      end

      def size
        @size || @size = @fiber_delegate.resume
      end

      protected

      def reset
        @size = nil
        @first_byte = true
        @iobuffer = ::IO::Buffer.new
        @fiber_delegate = Fiber.new { process }
      end
    end
  end
end
