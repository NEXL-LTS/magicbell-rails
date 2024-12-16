# frozen_string_literal: true

require 'magicbell'

module Magicbell
  module Rails
    class UpdateNotificationPreferencesJob < ApplicationJob
      queue_as Rails.queue_name

      def perform(notification_preference)
        return if Rails.api_secret.blank?

        magicbell = MagicBell::Client.new(
          api_key: Rails.api_key,
          api_secret: Rails.api_secret
        )

        # Build base headers that are always required
        headers = {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-Magicbell-Api-Key' => Rails.api_key,
          'X-Magicbell-Api-Secret' => Rails.api_secret,
          'X-Magicbell-User-External-Id' => notification_preference.user_external_id
        }

        # Add HMAC header only if it's not nil
        headers['X-Magicbell-User-Hmac'] = notification_preference.user_hmac if notification_preference.user_hmac

        magicbell.put(
          'https://api.magicbell.com/notification_preferences',
          body: notification_preference.to_bell_hash.to_json,
          headers: headers
        )
      end
    end
  end
end
