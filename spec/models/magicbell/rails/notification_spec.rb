require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe Notification do
      describe '.bell' do
        context 'with minimum attributes' do
          before do
            @notification = described_class.bell(
              title: 'Welcome to MagicBell',
              recipients: [
                {
                  email: 'grant@example.io'
                }
              ]
            ).reload
          end

          it do
            expect(@notification.to_bell_hash).to eq(
              'notification' => {
                'title' => 'Welcome to MagicBell',
                'recipients' => [
                  { 'email' => 'grant@example.io' }
                ]
              }
            )
          end
        end

        context 'with all attributes' do
          before do
            @notification = described_class.bell(
              title: 'Welcome to MagicBell',
              topic: 'welcome',
              recipients: [
                {
                  first_name: 'Grant',
                  last_name: 'Petersen-Speelman',
                  email: 'grant@example.io',
                  phone_numbers: ['+61431000000'],
                  external_id: '123',
                  custom_attributes: {
                    age: 30
                  }
                }
              ],
              content: 'The notification inbox for your product. Get started in minutes.',
              category: 'new_message',
              action_url: 'https://magicbell.com/docs',
              custom_attributes: {
                order: {
                  id: '1202983',
                  title: 'A title you can use in your templates'
                }
              },
              overrides: {
                channels: {
                  mobile_push: {
                    action_url: 'https://magicbell.com/docs'
                  }
                }
              }
            ).reload
          end

          it do
            expect(@notification.to_bell_hash).to eq(
              'notification' => {
                'title' => 'Welcome to MagicBell',
                'topic' => 'welcome',
                'content' => 'The notification inbox for your product. Get started in minutes.',
                'category' => 'new_message',
                'action_url' => 'https://magicbell.com/docs',
                'custom_attributes' => { 'order' => { 'id' => '1202983',
                                                      'title' => 'A title you can use in your templates' } },
                'overrides' => { 'channels' => { 'mobile_push' => { 'action_url' => 'https://magicbell.com/docs' } } },
                'recipients' => [
                  { 'custom_attributes' => { 'age' => 30 }, 'email' => 'grant@example.io',
                    'external_id' => '123', 'first_name' => 'Grant', 'last_name' => 'Petersen-Speelman',
                    'phone_numbers' => ['+61431000000'] }
                ]
              }
            )
          end
        end
      end
    end
  end
end
