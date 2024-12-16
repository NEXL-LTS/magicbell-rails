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
        UpdateNotificationPreferencesJob.perform_now(self)
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
