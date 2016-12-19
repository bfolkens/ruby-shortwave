require 'iobuffer'
require 'fiber'

module Shortwave
  module Pipeline
    class Source < Base
      attr_accessor :chunk_read_delegate
      attr_reader :pos

      def close
        @first_byte = true
        @iobuffer.close
      end

      def read(size = nil, buffer = nil)
        if @memo.pos < @memo.size
          # Read from the memo if we're behind
          read_memo(size, buffer)
        else
          # Read from the source if we're caught-up
          read_fiber(size, buffer)
        end
      end

      def size
        @size || @size = @fiber_delegate.resume
      end

      def rewind
        @memo.seek(0)
      end

      protected

      def reset
        @size = nil
        @first_byte = true
        @iobuffer = ::IO::Buffer.new
        @memo = StringIO.new
        @fiber_delegate = Fiber.new { process }
      end

      def read_fiber(size = nil, buffer = nil)
        if @fiber_delegate.alive?
          # Make sure to consume the first yield if we haven't yet
          @size = @fiber_delegate.resume if @first_byte

          # The remainder of yields return the remaining bytes
          remaining = @fiber_delegate.resume
        end

        data = size.nil? ? @iobuffer.read : @iobuffer.read(size)
        data.tap do |chunk|
          @memo << chunk
          @memo.seek(@memo.size) # follow the tail unless we rewind

          chunk_read_delegate.call(@memo, chunk) unless chunk_read_delegate.nil?
          buffer.replace(chunk) unless buffer.nil?
        end
      end

      def read_memo(size = nil, buffer = nil)
        remaining = @memo.size - @memo.pos
        memo_read_size = size > remaining ? remaining : size
        @memo.read(memo_read_size, buffer)
      end
    end
  end
end
