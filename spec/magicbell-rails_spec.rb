require 'rails_helper' # rubocop:disable Naming/FileName

module Magicbell
  module Rails
    RSpec.describe Magicbell::Rails do
      include ActiveJob::TestHelper

      before do
        described_class.api_key = ENV.fetch('MAGICBELL_API_KEY', 'SET_YOUR_API_KEY')
        described_class.api_secret = ENV.fetch('MAGICBELL_API_SECRET', 'SET_YOUR_API_SECRET')
      end

      describe 'end to end test' do
        it do
          VCR.use_cassette('e2e') do
            perform_enqueued_jobs do
              described_class.bell(
                title: 'Welcome to MagicBell',
                recipients: [
                  {
                    email: 'grant@nexl.io'
                  }
                ]
              ).deliver_later
            end
          end

          expect(Notification.count).to eq(1)
          expect(Result.count).to eq(1)
        end

        it 'updates notification preferences' do
          stub_request(:put, 'https://api.magicbell.com/notification_preferences')
            .with(
              headers: {
                'X-MAGICBELL-API-KEY' => described_class.api_key,
                'X-MAGICBELL-USER-EXTERNAL-ID' => 'user-123'
              },
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
              }
            )
            .to_return(status: 200, body: '{}')

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
