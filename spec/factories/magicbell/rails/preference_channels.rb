# frozen_string_literal: true

FactoryBot.define do
  factory :preference_channel, class: 'Magicbell::Rails::PreferenceChannel' do
    sequence(:slug) { |n| "channel-#{n}" }
    enabled { true }
    preference_category
  end
end
