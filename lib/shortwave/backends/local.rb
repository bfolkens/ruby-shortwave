require_relative 'base'

module Shortwave
  module Backend
    class Local < Base

      def write(io)
        FileUtils.mkdir_p(File.dirname(file_path))

        File.open(file_path, 'wb') do |f|
          FileUtils.copy_stream io, f
        end
      end

      def read
        File.open(file_path, 'rb') do |f|
          return f.read
        end
      end

      def delete!
        File.unlink(file_path)
      rescue Errno::ENOENT
        # Ignore missing file
      end

      def file_path
        File.join(@@store_path, @attachment.path)
      end
    end
  end
end
