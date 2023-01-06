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
        result = magicbell.create_notification(notification.to_bell_hash)

        result_creator.create(notification: notification, result: result.to_h)
      end
    end
  end
end
