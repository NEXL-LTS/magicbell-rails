require 'magicbell/rails/engine' # rubocop:disable Naming/FileName
require 'magicbell'

module Magicbell
  module Rails
    Error = Class.new(StandardError)

    cattr_accessor :queue_name, default: :default
    cattr_accessor :api_key, default: ENV['MAGICBELL_API_KEY']
    cattr_accessor :api_secret, default: ENV['MAGICBELL_API_SECRET']

    def self.bell(args)
      Notification.bell(args)
    end

    def self.fetch_categories(external_id:)
      UserCategory.fetch(external_id:)
    end

    def self.update_notification_preferences(external_id:, payload:)
      NotificationPreference.update(external_id:, payload: payload)
    end

    def self.client
      MagicBell::Client.new(
        api_key: Magicbell::Rails.api_key,
        api_secret: Magicbell::Rails.api_secret
      )
    end
  end
end
