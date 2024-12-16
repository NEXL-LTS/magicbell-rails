# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe NotificationPreference do
      describe 'validations' do
        subject { create(:notification_preference) }

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

      describe '#update_later' do
        let(:preference) { create(:notification_preference) }

        it 'enqueues an update job' do
          expect {
            preference.update_later
          }.to have_enqueued_job(UpdateNotificationPreferencesJob)
        end
      end

      describe '#update_now' do
        let(:preference) { create(:notification_preference) }
        let(:api_key) { 'test-api-key' }
        let(:api_secret) { 'test-api-secret' }

        before do
          allow(Magicbell::Rails).to receive(:api_key).and_return(api_key)
          allow(Magicbell::Rails).to receive(:api_secret).and_return(api_secret)

          stub_request(:put, "https://api.magicbell.com/notification_preferences")
            .with(
              body: preference.to_bell_hash.to_json,
              headers: {
                'Accept' => 'application/json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Ruby',
                'X-MAGICBELL-API-KEY' => api_key,
                'X-MAGICBELL-API-SECRET' => api_secret,
                'X-MAGICBELL-USER-EXTERNAL-ID' => preference.user_external_id,
                'X-MAGICBELL-USER-HMAC' => preference.user_hmac
              }.compact
            )
            .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
        end

        it 'updates preferences immediately' do
          expect {
            preference.update_now
          }.not_to have_enqueued_job(UpdateNotificationPreferencesJob)

          expect(WebMock).to have_requested(:put, "https://api.magicbell.com/notification_preferences")
        end
      end
    end
  end
end
