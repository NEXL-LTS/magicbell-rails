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

        context 'when creating new preferences' do
          subject(:create_preferences) do
            described_class.notification_preferences(
              user_external_id: user_external_id,
              user_hmac: user_hmac,
              categories: categories
            )
          end

          it 'sets user external ID' do
            expect(create_preferences.user_external_id).to eq(user_external_id)
          end

          it 'sets user HMAC' do
            expect(create_preferences.user_hmac).to eq(user_hmac)
          end

          it 'creates category with correct attributes' do
            expect(create_preferences.categories.first.slug).to eq('billing')
          end

          it 'creates channel with correct attributes' do
            channel = create_preferences.categories.first.channels.first
            expect(channel.slug).to eq('email')
            expect(channel.enabled).to be false
          end
        end

        context 'when updating existing preferences' do
          let!(:existing_preference) do
            described_class.notification_preferences(
              user_external_id: user_external_id,
              categories: [{ 'slug' => 'billing', 'channels' => [] }]
            )
          end

          it 'updates existing record' do
            updated = described_class.notification_preferences(
              user_external_id: user_external_id,
              categories: categories
            )
            expect(updated.id).to eq(existing_preference.id)
          end

          it 'updates channel settings' do
            updated = described_class.notification_preferences(
              user_external_id: user_external_id,
              categories: categories
            )
            expect(updated.categories.first.channels.first.enabled).to be false
          end
        end
      end

      describe '#to_bell_hash' do
        let(:preference) { create(:notification_preference) }
        let(:category) { create(:preference_category, notification_preference: preference) }
        let(:channel) { create(:preference_channel, preference_category: category) }
        let(:expected_hash) do
          {
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
          }
        end

        before { channel } # ensure channel is created

        it { expect(preference.to_bell_hash).to eq(expected_hash) }
      end

      describe '#update_later' do
        let(:preference) { create(:notification_preference) }

        it 'enqueues an update job' do
          expect { preference.update_later }
            .to have_enqueued_job(UpdateNotificationPreferencesJob)
        end
      end

      describe '#update_now' do
        let(:preference) { create(:notification_preference) }
        let(:category) { create(:preference_category, notification_preference: preference) }
        let(:channel) { create(:preference_channel, preference_category: category) }
        let(:api_key) { 'test-api-key' }
        let(:api_secret) { 'test-api-secret' }

        before do
          allow(Magicbell::Rails).to receive_messages(
            api_key: api_key,
            api_secret: api_secret
          )
          channel # ensure channel is created

          stub_request(:put, 'https://api.magicbell.io/notification_preferences')
            .with(
              body: preference.to_bell_hash.to_json,
              headers: {
                'Accept' => 'application/json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Ruby',
                'X-Magicbell-Api-Key' => api_key,
                'X-Magicbell-Api-Secret' => api_secret,
                'X-Magicbell-User-External-Id' => preference.user_external_id,
                'X-Magicbell-User-Hmac' => preference.user_hmac
              }
            )
            .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
        end

        it 'makes API request' do
          preference.update_now
          expect(WebMock).to have_requested(:put, 'https://api.magicbell.io/notification_preferences')
        end

        it 'skips job' do
          expect { preference.update_now }
            .not_to have_enqueued_job(UpdateNotificationPreferencesJob)
        end
      end
    end
  end
end
