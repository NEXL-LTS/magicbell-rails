# frozen_string_literal: true

FactoryBot.define do
  factory :preference_category, class: 'Magicbell::Rails::PreferenceCategory' do
    sequence(:slug) { |n| "category-#{n}" }
    notification_preference
  end
end
