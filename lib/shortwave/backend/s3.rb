require 'aws-sdk'
require_relative 'base'

module Shortwave
  module Backend
    class S3 < Base

      class << self
        attr_accessor :aws_bucket
        attr_accessor :aws_credentials
        attr_accessor :aws_store_attributes
      end

      def initialize(attachment)
        super(attachment)

        @client = Aws::S3::Client.new(self.class.aws_credentials)
        @s3 = Aws::S3::Resource.new(client: @client)
      end

      def write(io)
        s3obj.put(self.class.aws_store_attributes.merge(body: io))
      end

      def read
        # get(response_target: Proc.new(block) { fiber_stream.write(block) })
        return s3obj.get.body
      end

      def delete!
        s3obj.delete
      end

      def s3obj
        merged_path = [self.class.store_path, @attachment.path].join('/')
        @s3.bucket(self.class.aws_bucket).object(merged_path)
      end
    end
  end
end
