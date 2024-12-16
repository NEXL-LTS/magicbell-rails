# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe Notification do
      describe '.bell' do
        context 'with minimum attributes' do
          let(:notification) do
            described_class.bell(
              title: 'Welcome to MagicBell',
              recipients: [{ email: 'grant@example.io' }]
            ).reload
          end

          let(:expected_hash) do
            {
              'notification' => {
                'title' => 'Welcome to MagicBell',
                'recipients' => [{ 'email' => 'grant@example.io' }]
              }
            }
          end

          it { expect(notification.to_bell_hash).to eq(expected_hash) }
        end

        context 'with all attributes' do
          let(:notification) do
            described_class.bell(
              title: 'Welcome to MagicBell',
              topic: 'welcome',
              recipients: [
                {
                  first_name: 'Grant',
                  last_name: 'Petersen-Speelman',
                  email: 'grant@example.io',
                  phone_numbers: ['+61431000000'],
                  external_id: '123',
                  custom_attributes: { age: 30 }
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

          let(:notification_hash) { notification.to_bell_hash['notification'] }

          it 'includes basic attributes' do
            expect(notification_hash).to include(
              'title' => 'Welcome to MagicBell',
              'topic' => 'welcome'
            )
          end

          it 'includes content and category' do
            expect(notification_hash).to include(
              'content' => 'The notification inbox for your product. Get started in minutes.',
              'category' => 'new_message',
              'action_url' => 'https://magicbell.com/docs'
            )
          end

          it 'includes custom attributes' do
            expect(notification_hash['custom_attributes']).to eq(
              'order' => {
                'id' => '1202983',
                'title' => 'A title you can use in your templates'
              }
            )
          end

          it 'includes channel overrides' do
            expect(notification_hash['overrides']).to eq(
              'channels' => {
                'mobile_push' => {
                  'action_url' => 'https://magicbell.com/docs'
                }
              }
            )
          end

          it 'includes recipient details' do
            expect(notification_hash['recipients'].first).to eq(
              'custom_attributes' => { 'age' => 30 },
              'email' => 'grant@example.io',
              'external_id' => '123',
              'first_name' => 'Grant',
              'last_name' => 'Petersen-Speelman',
              'phone_numbers' => ['+61431000000']
            )
          end
        end
      end
    end
  end
end
