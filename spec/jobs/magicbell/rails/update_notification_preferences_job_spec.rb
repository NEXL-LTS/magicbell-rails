# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

module Magicbell
  module Rails
    RSpec.describe UpdateNotificationPreferencesJob do
      let(:notification_preference) { create(:notification_preference) }
      let(:category) { create(:preference_category, notification_preference: notification_preference) }
      let!(:channel) { create(:preference_channel, preference_category: category) }

      before do
        described_class.api_key = 'test_api_key'
        described_class.api_secret = 'test_api_secret'

        stub_request(:put, 'https://api.magicbell.com/notification_preferences')
          .with(
            headers: {
              'X-MAGICBELL-API-KEY' => described_class.api_key,
              'X-MAGICBELL-USER-EXTERNAL-ID' => notification_preference.user_external_id,
              'X-MAGICBELL-USER-HMAC' => notification_preference.user_hmac
            },
            body: notification_preference.to_bell_hash
          )
          .to_return(status: 200, body: '{}')
      end

      it 'sends the correct request to MagicBell API' do
        described_class.perform_now(notification_preference)

        expect(WebMock).to have_requested(:put, 'https://api.magicbell.com/notification_preferences')
          .with(
            headers: {
              'X-MAGICBELL-API-KEY' => described_class.api_key,
              'X-MAGICBELL-USER-EXTERNAL-ID' => notification_preference.user_external_id,
              'X-MAGICBELL-USER-HMAC' => notification_preference.user_hmac
            },
            body: notification_preference.to_bell_hash
          )
      end

      context 'when api_secret is blank' do
        before { described_class.api_secret = nil }

        it 'does not make an API request' do
          described_class.perform_now(notification_preference)
          expect(WebMock).not_to have_requested(:put, 'https://api.magicbell.com/notification_preferences')
        end
      end

      context 'when user_hmac is nil' do
        let(:notification_preference) { create(:notification_preference, user_hmac: nil) }

        it 'sends the request without the HMAC header' do
          described_class.perform_now(notification_preference)

          expect(WebMock).to have_requested(:put, 'https://api.magicbell.com/notification_preferences')
            .with { |req| !req.headers.key?('X-MAGICBELL-USER-HMAC') }
        end
      end
    end
  end
end
