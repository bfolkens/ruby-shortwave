require 'excon'

module Shortwave
  module Pipeline
    class Excon < Source
      def initialize(url)
        reset
        @conn = ::Excon.new(url, tcp_nodelay: true, connect_timeout: 6, ssl_verify_peer: false)
      end

      def process
        @conn.get(response_block: -> (chunk, remaining, total) {
          if @first_byte
            @first_byte = false
            Fiber.yield(total)
          end

          @iobuffer << chunk
          Fiber.yield
        })
      end
    end
  end
end
