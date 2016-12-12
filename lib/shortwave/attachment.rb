module Shortwave
  class EmptyFilenameException < Exception; end

  class Attachment
    attr_accessor :asset_host
    attr_accessor :backend
    attr_accessor :cache_unsaved_attachments

    def initialize(obj, namespace, source_stream)
      self.asset_host = Shortwave::Config.asset_host
      self.backend = Shortwave::Config.backend.new(self)
      self.cache_unsaved_attachments = Shortwave::Config.cache_unsaved_attachments

      @obj = obj
      @namespace = namespace
      @source_stream = source_stream
    end

    def url
      return nil unless path
      asset_host + '/' + path
    end

    def filename
      @obj.send("#{@namespace.last}_filename")
    end

    def path
      raise EmptyFilenameException.new('Empty filename detected') if filename.to_s.empty?
      cached? ? cache_path : store_path
    end

    def store_path
      [store_dir, filename].join('/')
    end

    def store_dir
      [@namespace, @obj.id.to_s].join('/')
    end

    def cache_key
      @cache_key ||= SecureRandom.uuid
    end

    def cache_path
      [cache_dir, filename].join('/')
    end

    def cache_dir
      (@namespace + [cache_key]).join('/')
    end

    def cached?
      cache_unsaved_attachments and (@obj.new_record? or @obj.id.nil?)
    end

    # TODO: caching in backends
    # def cache!
    #   backend.write(@source_stream)
    # end

    def persist!
      # TODO: backend.persist_cache if cached?
      backend.write(@source_stream)
    end

    def remove!
      backend.delete!
    end

    def read
      backend.read
    end
  end
end
