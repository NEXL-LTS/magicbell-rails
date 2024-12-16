# frozen_string_literal: true

require 'magicbell'
require 'magicbell/rails/client'

module Magicbell
  module Rails
    class UpdateNotificationPreferencesJob < ApplicationJob
      queue_as Rails.queue_name

      def perform(notification_preference)
        return if Rails.api_secret.blank?

        magicbell = Magicbell::Rails::Client.new(
          api_key: Rails.api_key,
          api_secret: Rails.api_secret,
          user_external_id: notification_preference.user_external_id,
          user_hmac: notification_preference.user_hmac
        )

        options = {
          body: notification_preference.to_bell_hash.to_json
        }

        magicbell.put(
          'https://api.magicbell.com/notification_preferences',
          options
        )
      end
    end
  end
end
