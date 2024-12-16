# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe UpdateNotificationPreferencesJob do
      let(:notification_preference) { create(:notification_preference) }
      let(:category) { create(:preference_category, notification_preference: notification_preference) }
      let!(:channel) { create(:preference_channel, preference_category: category) }
      let(:api_key) { 'test-api-key' }
      let(:api_secret) { 'test-api-secret' }

      before do
        allow(Magicbell::Rails).to receive(:api_key).and_return(api_key)
        allow(Magicbell::Rails).to receive(:api_secret).and_return(api_secret)
      end

      it 'sends the correct request to MagicBell API' do
        stub_request(:put, 'https://api.magicbell.io/notification_preferences')
          .with(
            body: notification_preference.to_bell_hash.to_json,
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => 'Ruby',
              'X-Magicbell-Api-Key' => api_key,
              'X-Magicbell-Api-Secret' => api_secret,
              'X-Magicbell-User-External-Id' => notification_preference.user_external_id,
              'X-Magicbell-User-Hmac' => notification_preference.user_hmac
            }
          )
          .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

        described_class.perform_now(notification_preference)
      end

      context 'when api_secret is blank' do
        before { allow(Magicbell::Rails).to receive(:api_secret).and_return(nil) }

        it 'does not make an API request' do
          expect_any_instance_of(MagicBell::Client).not_to receive(:put)
          described_class.perform_now(notification_preference)
        end
      end

      context 'when user_hmac is nil' do
        let(:notification_preference) { create(:notification_preference, user_hmac: nil) }

        it 'sends the request without the HMAC header' do
          stub_request(:put, 'https://api.magicbell.io/notification_preferences')
            .with(
              body: notification_preference.to_bell_hash.to_json,
              headers: {
                'Accept' => 'application/json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Ruby',
                'X-Magicbell-Api-Key' => api_key,
                'X-Magicbell-Api-Secret' => api_secret,
                'X-Magicbell-User-External-Id' => notification_preference.user_external_id
              }
            )
            .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

          described_class.perform_now(notification_preference)
        end
      end
    end
  end
end
