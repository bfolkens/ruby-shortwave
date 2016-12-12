module Shortwave
  class Config
    class << self
      attr_accessor :asset_host
      attr_accessor :backend
      attr_accessor :cache_unsaved_attachments
    end
  end
end
