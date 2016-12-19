require 'active_support/concern'

module Shortwave
  module ActiveRecord
    module CallbackHelper
      extend ActiveSupport::Concern

      module ClassMethods
        def install_activerecord_callbacks_for(attribute)
          class_eval <<-RUBY
            after_save do
              #{attribute}.persist! if #{attribute}_changed?
            end

            after_destroy do
              #{attribute}.remove!
            end
          RUBY
        end
      end
    end
  end
end
