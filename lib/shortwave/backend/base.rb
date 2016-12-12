module Shortwave
  module Backend
    class Base
      class << self
        attr_accessor :store_path
      end

      def initialize(attachment)
        @attachment = attachment
      end
    end
  end
end
