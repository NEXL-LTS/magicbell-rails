# frozen_string_literal: true

require 'magicbell'

module Magicbell
  module Rails
    class NotificationPreference < ApplicationRecord
      has_many :categories, class_name: 'PreferenceCategory', dependent: :destroy

      validates :user_external_id, presence: true, uniqueness: true

      def self.notification_preferences(params)
        params = params.deep_symbolize_keys

        record = find_or_initialize_by(user_external_id: params[:user_external_id])
        record.user_hmac = params[:user_hmac]

        params[:categories].each do |category_params|
          category = record.categories.find_or_initialize_by(slug: category_params[:slug])

          category_params[:channels].each do |channel_params|
            channel = category.channels.find_or_initialize_by(slug: channel_params[:slug])
            channel.enabled = channel_params[:enabled]
            channel.save!
          end
        end

        record.save!
        record
      end

      def update_later
        UpdateNotificationPreferencesJob.perform_later(self)
      end

      def update_now
        return if ::Magicbell::Rails.api_secret.blank?

        magicbell = MagicBell::Client.new(
          api_key: ::Magicbell::Rails.api_key,
          api_secret: ::Magicbell::Rails.api_secret
        )

        headers = {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-Magicbell-Api-Key' => ::Magicbell::Rails.api_key,
          'X-Magicbell-Api-Secret' => ::Magicbell::Rails.api_secret,
          'X-Magicbell-User-External-Id' => user_external_id
        }

        headers['X-Magicbell-User-Hmac'] = user_hmac if user_hmac

        magicbell.put(
          'https://api.magicbell.com/notification_preferences',
          body: to_bell_hash.to_json,
          headers: headers
        )
      end

      def to_bell_hash
        {
          notification_preferences: {
            categories: categories.map(&:to_bell_hash)
          }
        }
      end
    end
  end
end
