module Shortwave
  module Callbacks
    def self.included(base)
      base.extend ClassMethods
    end

    class CallbackDelegator
      def initialize(callbacks, obj)
        @callbacks = callbacks
        @callback_skip_list = {}
        @obj = obj
      end

      def attach(pipeline)
        pipeline.chunk_read_delegate = lambda { |memo, chunk|
          each_callback(:after_attachment_bytes_read, @obj, memo, chunk)
        }
      end

      protected

      def each_callback(name, obj, memo, chunk)
        @callback_skip_list[name] ||= []

        @callbacks[name].each_with_index do |args, i|
          next if @callback_skip_list[name].include?(i)

          options, l = args
          if memo.size > options[:count]
            l.call(obj, chunk)
            @callback_skip_list[name] << i
          end
        end
      end
    end

    module ClassMethods
      @@callbacks = {}

      def after_attachment_bytes_read(options = {}, &block)
        options.reverse_merge! count: 1024
        add_callback(:after_attachment_bytes_read, options, block)
      end

      protected

      def add_callback(name, *args)
        @@callbacks[name] ||= []
        @@callbacks[name] << args
      end

      def callbacks
        @@callbacks
      end
    end

    def install_shortwave_callbacks_to(pipeline)
      CallbackDelegator.new(self.class.send(:callbacks), self).attach(pipeline)
    end
  end
end
