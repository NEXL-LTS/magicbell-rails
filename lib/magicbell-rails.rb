require 'magicbell/rails/engine' # rubocop:disable Naming/FileName

module Magicbell
  module Rails
    Error = Class.new(StandardError)

    cattr_accessor :queue_name, default: :default
    cattr_accessor :api_key, default: ENV['MAGICBELL_API_KEY']
    cattr_accessor :api_secret, default: ENV['MAGICBELL_API_SECRET']

    def self.bell(args)
      Notification.bell(args)
    end

    def self.notification_preferences(args)
      NotificationPreference.notification_preferences(args)
    end
  end
end
