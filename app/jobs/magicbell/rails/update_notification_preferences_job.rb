# frozen_string_literal: true

require 'magicbell'
require_relative '../../../lib/magicbell/rails/client'

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

        # Build complete options hash with all required headers
        headers = {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-MAGICBELL-API-KEY' => Rails.api_key,
          'X-MAGICBELL-API-SECRET' => Rails.api_secret,
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
