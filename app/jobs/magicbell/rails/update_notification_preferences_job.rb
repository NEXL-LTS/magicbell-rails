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
          api_secret: Rails.api_secret
        )

        # Build user-specific headers only
        headers = {
          'X-MAGICBELL-USER-EXTERNAL-ID' => notification_preference.user_external_id
        }

        # Add HMAC header only if it's present
        headers['X-MAGICBELL-USER-HMAC'] = notification_preference.user_hmac if notification_preference.user_hmac.present?

        options = {
          body: notification_preference.to_bell_hash.to_json,
          headers: headers
        }

        magicbell.put(
          'https://api.magicbell.com/notification_preferences',
          options
        )
      end
    end
  end
end
