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

        it 'enqueues an update job' do
          preference = described_class.notification_preferences(
            user_external_id: user_external_id,
            user_hmac: user_hmac,
            categories: categories
          )

          expect do
            preference.update_later
          end.to have_enqueued_job(UpdateNotificationPreferencesJob)
        end
      end

      describe '#update_now' do
        let(:user_external_id) { 'user-123' }
        let(:user_hmac) { 'hmac-456' }
        let(:api_key) { 'test-api-key' }
        let(:api_secret) { 'test-api-secret' }
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

        before do
          allow(Magicbell::Rails).to receive_messages(
            api_key: api_key,
            api_secret: api_secret
          )

          stub_request(:put, 'https://api.magicbell.io/notification_preferences')
            .with(
              body: {
                notification_preferences: {
                  categories: [
                    {
                      slug: 'billing',
                      channels: [
                        {
                          slug: 'email',
                          enabled: false
                        }
                      ]
                    }
                  ]
                }
              }.to_json,
              headers: {
                'Accept' => 'application/json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Ruby',
                'X-Magicbell-Api-Key' => api_key,
                'X-Magicbell-Api-Secret' => api_secret,
                'X-Magicbell-User-External-Id' => user_external_id,
                'X-Magicbell-User-Hmac' => user_hmac
              }
            )
            .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
        end

        it 'updates preferences immediately' do
          preference = described_class.notification_preferences(
            user_external_id: user_external_id,
            user_hmac: user_hmac,
            categories: categories
          )

          expect do
            preference.update_now
          end.not_to have_enqueued_job(UpdateNotificationPreferencesJob)

          expect(WebMock).to have_requested(:put, 'https://api.magicbell.io/notification_preferences')
        end
      end
    end
  end
end
