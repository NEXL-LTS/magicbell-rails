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

      let!(:external_id) { 'nexl-360-latest.nexl.cloud/455' }

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

      describe '#fetch_categories' do
        it 'fetches categories from MagicBell' do
          VCR.use_cassette('fetch_categories') do
            categories = described_class.fetch_categories(external_id)
            expect(categories).to be_an(Array)
            expect(categories).to include('StayInTouchReminder', 'FollowUpReminder')
          end
        end

        context 'when there are no categories' do
          it 'returns an empty array' do
            VCR.use_cassette('fetch_no_categories') do
              categories = described_class.fetch_categories('non-existent-external-id')
              expect(categories).to eq([])
            end
          end
        end
      end

      describe '#update_notification_preferences' do
        let(:payload) do
          {
            notification_preferences: {
              'categories' => [
                {
                  'slug' => 'StayInTouchReminder',
                  'channels' => [{ 'slug' => 'email', 'enabled' => false }]
                }
              ]
            }
          }
        end

        it 'updates notification preferences on MagicBell' do
          VCR.use_cassette('update_notification_preferences') do
            expect { described_class.update_notification_preferences(external_id, payload) }
              .not_to raise_error
          end
        end
      end
    end
  end
end
