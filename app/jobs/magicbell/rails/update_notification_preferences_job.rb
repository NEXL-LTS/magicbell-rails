# frozen_string_literal: true

require 'magicbell'
require 'magicbell/rails/client'

module Magicbell
  module Rails
    class UpdateNotificationPreferencesJob < ApplicationJob
      queue_as Rails.queue_name

      def perform(notification_preference)
        return if Rails.api_secret.blank?

        client = notification_preference.send(:build_magicbell_client)
        client.put('https://api.magicbell.com/notification_preferences', body: notification_preference.to_bell_hash.to_json)
      end
    end
  end
end
