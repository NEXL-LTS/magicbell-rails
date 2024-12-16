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

      it 'delivers notification successfully' do
        notification = instance_double(
          Magicbell::Rails::Notification,
          to_bell_hash: base_notification_data
        )

        stub_magicbell_request(base_notification_data)
        job.perform(notification, result_creator: result_creator)

        expect(result_creator).to have_received(:create)
          .with(notification: notification, result: { 'id' => '123' })
      end

      it 'handles custom attributes correctly' do
        notification_data = base_notification_data.deep_merge(
          notification: { 'custom_attributes' => { 'example' => '1' } }
        )
        notification = instance_double(
          Magicbell::Rails::Notification,
          to_bell_hash: notification_data
        )

        stub_magicbell_request(notification_data)
        job.perform(notification, result_creator: result_creator)

        expect(result_creator).to have_received(:create)
          .with(notification: notification, result: { 'id' => '123' })
      end

      it 'raises error for invalid attributes' do
        notification_data = base_notification_data.deep_merge(
          notification: { 'custom_attributes' => 'NotAHash' }
        )
        notification = instance_double(
          Magicbell::Rails::Notification,
          to_bell_hash: notification_data
        )

        stub_magicbell_request(
          notification_data,
          status: 422,
          response_body: '{"errors":["custom_attributes must be a hash"]}'
        )

        expect { job.perform(notification, result_creator: result_creator) }
          .to raise_error(MagicBell::Client::HTTPError)
      end

      it 'skips delivery when api_secret is blank' do
        allow(Magicbell::Rails).to receive(:api_secret).and_return('')
        notification = instance_double(Magicbell::Rails::Notification)

        job.perform(notification, result_creator: result_creator)

        expect(result_creator).not_to have_received(:create)
      end

      it 'handles invalid API secret error' do
        notification = instance_double(
          Magicbell::Rails::Notification,
          to_bell_hash: base_notification_data
        )

        stub_magicbell_request(
          base_notification_data,
          status: 401,
          response_body: '{"errors":["Invalid API secret"]}'
        )

        expect { job.perform(notification, result_creator: result_creator) }
          .to raise_error(MagicBell::Client::HTTPError)
        expect(result_creator).not_to have_received(:create)
      end
    end
  end
end
