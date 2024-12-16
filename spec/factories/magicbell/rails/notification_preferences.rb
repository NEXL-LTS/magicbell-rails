# frozen_string_literal: true

FactoryBot.define do
  factory :notification_preference, class: 'Magicbell::Rails::NotificationPreference' do
    sequence(:user_external_id) { |n| "user-#{n}" }
    user_hmac { 'hmac123' }
  end
end
