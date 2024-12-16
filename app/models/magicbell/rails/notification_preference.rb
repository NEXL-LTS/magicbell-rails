# frozen_string_literal: true

require 'magicbell'
require 'magicbell/rails/client'

module Magicbell
  module Rails
    class NotificationPreference < ApplicationRecord
      has_many :categories, class_name: 'PreferenceCategory', dependent: :destroy

      validates :user_external_id, presence: true, uniqueness: true

      def self.notification_preferences(params)
        params = params.deep_symbolize_keys
        record = find_or_initialize_by(user_external_id: params[:user_external_id])
        record.user_hmac = params[:user_hmac]
        record.update_categories(params[:categories])
        record.save!
        record
      end

      def update_later
        UpdateNotificationPreferencesJob.perform_later(self)
      end

      def update_now
        return if ::Magicbell::Rails.api_secret.blank?

        client = build_magicbell_client
        client.put('https://api.magicbell.com/notification_preferences', body: to_bell_hash.to_json)
      end

      def to_bell_hash
        {
          notification_preferences: {
            categories: categories.map(&:to_bell_hash)
          }
        }
      end

      def update_categories(categories_params)
        categories_params.each do |category_params|
          category = categories.find_or_initialize_by(slug: category_params[:slug])
          update_channels(category, category_params[:channels])
        end
      end

      private

      def update_channels(category, channels_params)
        channels_params.each do |channel_params|
          channel = category.channels.find_or_initialize_by(slug: channel_params[:slug])
          channel.enabled = channel_params[:enabled]
          channel.save!
        end
      end

      def build_magicbell_client
        ::Magicbell::Rails::Client.new(
          api_key: ::Magicbell::Rails.api_key,
          api_secret: ::Magicbell::Rails.api_secret,
          user_external_id: user_external_id,
          user_hmac: user_hmac
        )
      end
    end
  end
end
