# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe DeliverNotificationJob do
      let(:result_creator) { class_double(Result, create: true) }
      let(:api_key) { 'test-api-key' }
      let(:api_secret) { 'test-api-secret' }
      let(:job) { described_class.new }
      let(:base_notification_data) do
        {
          notification: {
            'title' => 'value',
            'recipients' => [{ 'email' => 'grant@nexl.io' }]
          }
        }
      end

      before do
        allow(Magicbell::Rails).to receive_messages(
          api_key: api_key,
          api_secret: api_secret
        )
      end

      def default_headers
        {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-MAGICBELL-API-KEY' => api_key,
          'X-MAGICBELL-API-SECRET' => api_secret
        }
      end

      def stub_magicbell_request(notification_data, status: 200, response_body: '{"id":"123"}')
        stub_request(:post, 'https://api.magicbell.io/notifications')
          .with(
            body: notification_data.to_json,
            headers: default_headers
          )
          .to_return(
            status: status,
            body: response_body,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      context 'when delivering notifications' do
        let(:notification) do
          instance_double(
            Magicbell::Rails::Notification,
            to_bell_hash: base_notification_data
          )
        end

        it 'delivers notification successfully' do
          stub_magicbell_request(base_notification_data)
          job.perform(notification, result_creator: result_creator)
          expect(result_creator).to have_received(:create)
            .with(notification: notification, result: { 'id' => '123' })
        end

        it 'handles custom attributes' do
          notification_data = base_notification_data.deep_merge(
            notification: { 'custom_attributes' => { 'example' => '1' } }
          )
          allow(notification).to receive(:to_bell_hash).and_return(notification_data)

          stub_magicbell_request(notification_data)
          job.perform(notification, result_creator: result_creator)
          expect(result_creator).to have_received(:create)
            .with(notification: notification, result: { 'id' => '123' })
        end

        context 'when attributes are invalid' do
          let(:invalid_notification_data) do
            base_notification_data.deep_merge(
              notification: { 'custom_attributes' => 'NotAHash' }
            )
          end

          before do
            allow(notification).to receive(:to_bell_hash).and_return(invalid_notification_data)
            stub_magicbell_request(
              invalid_notification_data,
              status: 422,
              response_body: '{"errors":["custom_attributes must be a hash"]}'
            )
          end

          it 'raises an error' do
            expect { job.perform(notification, result_creator: result_creator) }
              .to raise_error(MagicBell::Client::HTTPError)
          end
        end
      end

      context 'when API configuration is invalid' do
        let(:notification) do
          instance_double(
            Magicbell::Rails::Notification,
            to_bell_hash: base_notification_data
          )
        end

        it 'skips delivery when api_secret is blank' do
          allow(Magicbell::Rails).to receive(:api_secret).and_return('')
          job.perform(notification, result_creator: result_creator)
          expect(result_creator).not_to have_received(:create)
        end

        it 'raises error for invalid API secret' do
          stub_magicbell_request(
            base_notification_data,
            status: 401,
            response_body: '{"errors":["Invalid API secret"]}'
          )
          expect { job.perform(notification, result_creator: result_creator) }
            .to raise_error(MagicBell::Client::HTTPError)
        end
      end
    end
  end
end
