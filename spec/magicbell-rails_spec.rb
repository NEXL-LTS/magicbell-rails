require 'rails_helper' # rubocop:disable Naming/FileName
require 'magicbell'

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
      end

      describe 'fetch and updates' do
        let(:client) { instance_double(MagicBell::Client) }
        let(:user) { instance_double(MagicBell::User) }
        let(:notification_preferences) { instance_double(MagicBell::UserNotificationPreferences) }
        let(:external_id) { 'test-user' }
        let(:categories_response) do
          {
            'categories' => [
              { 'slug' => 'stay_in_touch' },
              { 'slug' => 'list_shared' }
            ]
          }
        end

        before do
          allow(MagicBell::Client).to receive(:new).and_return(client)
          allow(client).to receive(:user_with_external_id).with(external_id).and_return(user)
          allow(user).to receive(:notification_preferences).and_return(notification_preferences)
          allow(notification_preferences).to receive(:update)
          allow(client).to receive(:create_notification).and_return(true)
        end

        describe '#fetch_categories' do
          it 'returns category slugs when categories exist' do
            allow(notification_preferences).to receive(:retrieve).and_return(
              instance_double(MagicBell::UserNotificationPreferences,
                              attributes: categories_response)
            )

            expect(described_class.fetch_categories(external_id)).to match_array(%w[stay_in_touch
                                                                                    list_shared])
          end

          it 'returns an empty array when no categories exist' do
            allow(notification_preferences).to receive(:retrieve).and_return(
              instance_double(MagicBell::UserNotificationPreferences,
                              attributes: {})
            )
            expect(described_class.fetch_categories(external_id)).to eq([])
          end
        end

        describe '#update_notification_preferences' do
          let(:payload) do
            {
              'categories' => [
                { 'slug' => 'stay_in_touch', 'channels' => [{ 'slug' => 'email', 'enabled' => false }] }
              ]
            }
          end

          it 'sends an update request with the correct payload' do
            described_class.update_notification_preferences(external_id, payload)

            expect(notification_preferences).to have_received(:update).with(payload)
          end
        end
      end
    end
  end
end
