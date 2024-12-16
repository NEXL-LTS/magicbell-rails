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

        headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'X-MAGICBELL-API-KEY' => Rails.api_key,
          'X-MAGICBELL-API-SECRET' => Rails.api_secret,
          'X-MAGICBELL-USER-EXTERNAL-ID' => notification_preference.user_external_id,
          'X-MAGICBELL-USER-HMAC' => notification_preference.user_hmac
        }.compact

        magicbell.put(
          'https://api.magicbell.com/notification_preferences',
          body: notification_preference.to_bell_hash.to_json,
          headers: headers
        )
      end
    end
  end
end
