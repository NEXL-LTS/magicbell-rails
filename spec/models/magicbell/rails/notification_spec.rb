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
            expect(@notification.to_graphql_hash).to eq(
              'title' => 'Welcome to MagicBell',
              'recipients' => [
                { 'email' => 'grant@example.io' }
              ]
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
              }
            ).reload
          end

          it do
            expect(@notification.to_graphql_hash).to eq(
              'title' => 'Welcome to MagicBell',
              'topic' => 'welcome',
              'content' => 'The notification inbox for your product. Get started in minutes.',
              'category' => 'new_message',
              'actionUrl' => 'https://magicbell.com/docs',
              'customAttributes' => { 'order' => { 'id' => '1202983',
                                                   'title' => 'A title you can use in your templates' } },
              'recipients' => [
                { 'customAttributes' => { 'age' => 30 }, 'email' => 'grant@example.io',
                  'externalId' => '123', 'firstName' => 'Grant', 'lastName' => 'Petersen-Speelman',
                  'phoneNumbers' => ['+61431000000'] }
              ]
            )
          end
        end
      end
    end
  end
end
