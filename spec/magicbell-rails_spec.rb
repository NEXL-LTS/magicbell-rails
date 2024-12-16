# frozen_string_literal: true

require 'rails_helper' # rubocop:disable Naming/FileName

module Magicbell
  module Rails
    RSpec.describe Magicbell::Rails do
      include ActiveJob::TestHelper

      let(:api_key) { 'test-api-key' }
      let(:api_secret) { 'test-api-secret' }

      before do
        allow(described_class).to receive(:api_key).and_return(api_key)
        allow(described_class).to receive(:api_secret).and_return(api_secret)
      end

      describe 'end to end test' do
        it 'creates and delivers notification' do
          stub_request(:post, 'https://api.magicbell.io/notifications')
            .with(
              body: {
                'notification' => {
                  'title' => 'Welcome to MagicBell',
                  'recipients' => [{ 'email' => 'grant@nexl.io' }]
                }
              }.to_json,
              headers: {
                'Accept' => 'application/json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Ruby',
                'X-Magicbell-Api-Key' => api_key,
                'X-Magicbell-Api-Secret' => api_secret
              }
            )
            .to_return(status: 200, body: '{"id":"123"}', headers: { 'Content-Type' => 'application/json' })

          perform_enqueued_jobs do
            described_class.bell(
              title: 'Welcome to MagicBell',
              recipients: [{ email: 'grant@nexl.io' }]
            ).deliver_later
          end

          expect(Notification.count).to eq(1)
          expect(Result.count).to eq(1)
        end

        it 'updates notification preferences' do
          stub_request(:put, 'https://api.magicbell.com/notification_preferences')
            .with(
              body: {
                'notification_preferences' => {
                  'categories' => [
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
                }
              }.to_json,
              headers: {
                'Accept' => 'application/json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Ruby',
                'X-Magicbell-Api-Key' => api_key,
                'X-Magicbell-Api-Secret' => api_secret,
                'X-Magicbell-User-External-Id' => 'user-123'
              }
            )
            .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

          perform_enqueued_jobs do
            described_class.notification_preferences(
              user_external_id: 'user-123',
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
            ).update_later
          end

          expect(NotificationPreference.count).to eq(1)
          preference = NotificationPreference.last
          expect(preference.categories.count).to eq(1)
          expect(preference.categories.first.channels.count).to eq(1)
        end
      end
    end
  end
end
