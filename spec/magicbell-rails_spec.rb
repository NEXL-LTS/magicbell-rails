require 'rails_helper' # rubocop:disable Naming/FileName

module Magicbell
  module Rails
    RSpec.describe Magicbell::Rails do
      include ActiveJob::TestHelper

      before do
        described_class.api_key = ENV.fetch('MAGICBELL_API_KEY', 'SET_YOUR_API_KEY')
        described_class.api_secret = ENV.fetch('MAGICBELL_API_SECRET', 'SET_YOUR_API_SECRET')
      end

      let!(:external_id) { 'nexl-360-latest.nexl.cloud/455' }
      let!(:email_channel) do
        UserCategory::Channel.new(slug: 'email', label: 'Email', enabled: true)
      end
      let!(:stay_in_touch_category) do
        UserCategory::UserCategory.new(slug: 'StayInTouchReminder', label: 'Stay in Touch',
                                       channels: [email_channel])
      end

      let!(:follow_up_category) do
        UserCategory::UserCategory.new(slug: 'FollowUpReminder', label: 'Opportunity Follow Up Reminder',
                                       channels: [email_channel])
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

      describe '#fetch_categories' do
        it 'fetches categories from MagicBell' do
          VCR.use_cassette('fetch_categories') do
            categories = described_class.fetch_categories(external_id:)
            expect(categories).to be_an(Array)
            expect(categories).to include(stay_in_touch_category, follow_up_category)
          end
        end

        context 'when there are no categories' do
          it 'returns an empty array' do
            VCR.use_cassette('fetch_no_categories') do
              categories = described_class.fetch_categories(external_id: 'non-existent-external-id')
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
            expect { described_class.update_notification_preferences(external_id:, payload:) }
              .not_to raise_error
          end
        end
      end

      describe '#user_exists?' do
        let(:external_id) { 'nexl-360-latest.nexl.cloud/455' }

        it 'returns true if the user exists' do
          VCR.use_cassette('user_exists') do
            expect(described_class.user_exists?(external_id: external_id)).to be(true)
          end
        end

        it 'returns false if the user does not exist' do
          VCR.use_cassette('user_does_not_exist') do
            expect(described_class.user_exists?(external_id: 'non-existent-external-id')).to be(false)
          end
        end
      end

      describe '#create_user' do
        let(:external_id) { 'nexl-360-latest.nexl.cloud/99999' }
        let(:email) { 'testingcreate@nexl.cloud' }
        let(:first_name) { 'Test' }
        let(:last_name) { 'User' }
        let(:phone_numbers) { [] }

        it 'creates a user on MagicBell' do
          VCR.use_cassette('create_user') do
            result = described_class.create_user(
              external_id:, email:, first_name:, last_name:, phone_numbers:
            )

            expect(result['id']).to be_present
          end
        end

        context 'when the user already exists' do
          it 'returns true' do
            VCR.use_cassette('create_existing_user') do
              result = described_class.create_user(
                external_id:, email:, first_name:, last_name:, phone_numbers:
              )

              expect(result['id']).to be_present
            end
          end
        end

        context 'when the user creation fails' do
          it 'returns false' do
            VCR.use_cassette('create_user_failure') do
              expect(
                described_class.create_user(
                  external_id:, email: '@invalid@email@.com.com.com', first_name:, last_name:,
                  phone_numbers:
                )
              ).to be(false)
            end
          end
        end
      end
    end
  end
end
