# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe UpdateNotificationPreferencesJob do
      let(:notification_preference) { create(:notification_preference) }
      let(:category) { create(:preference_category, notification_preference: notification_preference) }
      let(:channel) { create(:preference_channel, preference_category: category) }
      let(:api_key) { 'test-api-key' }
      let(:api_secret) { 'test-api-secret' }

      before do
        allow(Magicbell::Rails).to receive_messages(
          api_key: api_key,
          api_secret: api_secret
        )
        channel # ensure channel is created
      end

      def default_headers(additional_headers = {})
        {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-Magicbell-Api-Key' => api_key,
          'X-Magicbell-Api-Secret' => api_secret
        }.merge(additional_headers)
      end

      def stub_preferences_request(body:, headers: {})
        stub_request(:put, 'https://api.magicbell.io/notification_preferences')
          .with(body: body.to_json, headers: default_headers(headers))
          .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      context 'when updating preferences' do
        before do
          stub_preferences_request(
            body: notification_preference.to_bell_hash,
            headers: {
              'X-Magicbell-User-External-Id' => notification_preference.user_external_id,
              'X-Magicbell-User-Hmac' => notification_preference.user_hmac
            }
          )
        end

        it 'sends update request' do
          described_class.perform_now(notification_preference)
          expect(WebMock).to have_requested(:put, 'https://api.magicbell.io/notification_preferences')
        end
      end

      context 'when api_secret is blank' do
        before { allow(Magicbell::Rails).to receive(:api_secret).and_return(nil) }

        it 'skips API request' do
          client = instance_double(MagicBell::Client)
          allow(MagicBell::Client).to receive(:new).and_return(client)
          allow(client).to receive(:put)

          described_class.perform_now(notification_preference)

          expect(client).not_to have_received(:put)
        end
      end

      context 'when user_hmac is nil' do
        let(:notification_preference) { create(:notification_preference, user_hmac: nil) }

        it 'sends request without HMAC header' do
          stub_preferences_request(
            body: notification_preference.to_bell_hash,
            headers: {
              'X-Magicbell-User-External-Id' => notification_preference.user_external_id
            }
          )

          described_class.perform_now(notification_preference)

          expect(WebMock).to have_requested(:put, 'https://api.magicbell.io/notification_preferences')
        end
      end
    end
  end
end
