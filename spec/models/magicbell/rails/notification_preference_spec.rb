# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe NotificationPreference do
      describe 'validations' do
        it { is_expected.to validate_presence_of(:user_external_id) }
        it { is_expected.to validate_uniqueness_of(:user_external_id) }
      end

      describe 'associations' do
        it { is_expected.to have_many(:categories).class_name('PreferenceCategory').dependent(:destroy) }
      end

      describe '.notification_preferences' do
        let(:user_external_id) { 'user-123' }
        let(:user_hmac) { 'hmac-456' }
        let(:categories) do
          [
            {
              'slug' => 'billing',
              'channels' => [
                {
                  'slug' => 'email',
                  'enabled' => false
                }
              ]
            }
          ]
        end

        it 'creates notification preferences with associations' do
          preference = described_class.notification_preferences(
            user_external_id: user_external_id,
            user_hmac: user_hmac,
            categories: categories
          )

          expect(preference.user_external_id).to eq(user_external_id)
          expect(preference.user_hmac).to eq(user_hmac)
          expect(preference.categories.count).to eq(1)

          category = preference.categories.first
          expect(category.slug).to eq('billing')
          expect(category.channels.count).to eq(1)

          channel = category.channels.first
          expect(channel.slug).to eq('email')
          expect(channel.enabled).to be false
        end

        it 'updates existing preferences' do
          preference = described_class.notification_preferences(
            user_external_id: user_external_id,
            categories: [{ 'slug' => 'billing', 'channels' => [] }]
          )

          updated = described_class.notification_preferences(
            user_external_id: user_external_id,
            categories: categories
          )

          expect(updated.id).to eq(preference.id)
          expect(updated.categories.first.channels.first.enabled).to be false
        end
      end

      describe '#to_bell_hash' do
        let(:preference) { create(:notification_preference) }
        let(:category) { create(:preference_category, notification_preference: preference) }
        let!(:channel) { create(:preference_channel, preference_category: category) }

        it 'returns the correct hash structure' do
          expect(preference.to_bell_hash).to eq(
            notification_preferences: {
              categories: [
                {
                  slug: category.slug,
                  channels: [
                    {
                      slug: channel.slug,
                      enabled: channel.enabled
                    }
                  ]
                }
              ]
            }
          )
        end
      end
    end
  end
end
