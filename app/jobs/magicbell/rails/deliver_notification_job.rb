# frozen_string_literal: true

require 'magicbell'

module Magicbell
  module Rails
    class DeliverNotificationJob < ApplicationJob
      queue_as Rails.queue_name

      def perform(notification, result_creator: Result)
        return if Rails.api_secret.blank?

        magicbell = MagicBell::Client.new(
          api_key: Rails.api_key,
          api_secret: Rails.api_secret
        )

        headers = {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-MAGICBELL-API-KEY' => Rails.api_key,
          'X-MAGICBELL-API-SECRET' => Rails.api_secret
        }

        result = magicbell.post(
          'https://api.magicbell.io/notifications',
          body: notification.to_bell_hash.to_json,
          headers: headers
        )

        result_creator.create(notification: notification, result: result.to_h)
      end
    end
  end
end
