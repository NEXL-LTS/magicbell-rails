# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe Magicbell::Rails do
      include ActiveJob::TestHelper

      let(:api_key) { 'test-api-key' }
      let(:api_secret) { 'test-api-secret' }

      before do
        allow(described_class).to receive_messages(
          api_key: api_key,
          api_secret: api_secret
        )
      end

      describe 'end to end test' do
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

        def stub_magicbell_api(endpoint:, method:, body:, response_body: '{}', headers: {})
          stub_request(method, "https://api.magicbell.io/#{endpoint}")
            .with(body: body.to_json, headers: default_headers(headers))
            .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
        end

        let(:notification_data) do
          {
            'notification' => {
              'title' => 'Welcome to MagicBell',
              'recipients' => [{ 'email' => 'grant@nexl.io' }]
            }
          }
        end

        let(:preferences_data) do
          {
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
          }
        end

        context 'when delivering notifications' do
          before do
            stub_magicbell_api(
              endpoint: 'notifications',
              method: :post,
              body: notification_data,
              response_body: '{"id":"123"}'
            )
          end

          def deliver_notification
            perform_enqueued_jobs do
              described_class.bell(
                title: 'Welcome to MagicBell',
                recipients: [{ email: 'grant@nexl.io' }]
              ).deliver_later
            end
          end

          it 'creates notification record' do
            deliver_notification
            expect(Notification.count).to eq(1)
          end

          it 'creates result record' do
            deliver_notification
            expect(Result.count).to eq(1)
          end
        end

        context 'when updating preferences' do
          before do
            stub_magicbell_api(
              endpoint: 'notification_preferences',
              method: :put,
              body: preferences_data,
              headers: { 'X-Magicbell-User-External-Id' => 'user-123' }
            )
          end

          def update_preferences
            perform_enqueued_jobs do
              described_class.notification_preferences(
                user_external_id: 'user-123',
                categories: [{ slug: 'billing', channels: [{ slug: 'email', enabled: false }] }]
              ).update_later
            end
          end

          it 'creates preference records' do
            update_preferences
            expect(NotificationPreference.count).to eq(1)
            expect(PreferenceCategory.count).to eq(1)
            expect(PreferenceChannel.count).to eq(1)
          end
        end
      end
    end
  end
end
