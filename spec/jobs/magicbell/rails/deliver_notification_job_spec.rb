# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe DeliverNotificationJob do
      let(:result_creator) { class_double(Result, create: true) }
      let(:api_key) { 'test-api-key' }
      let(:api_secret) { 'test-api-secret' }

      before do
        allow(Magicbell::Rails).to receive(:api_key).and_return(api_key)
        allow(Magicbell::Rails).to receive(:api_secret).and_return(api_secret)
      end

      it 'works' do
        notification_data = {
          notification: {
            'title' => 'value',
            'recipients' => [{ 'email' => 'grant@nexl.io' }]
          }
        }

        notification = instance_double(Magicbell::Rails::Notification,
                                       to_bell_hash: notification_data)

        stub_request(:post, 'https://api.magicbell.io/notifications')
          .with(
            body: notification_data.to_json,
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => 'Ruby',
              'X-MAGICBELL-API-KEY' => api_key,
              'X-MAGICBELL-API-SECRET' => api_secret
            }
          )
          .to_return(status: 200, body: '{"id":"123"}', headers: { 'Content-Type' => 'application/json' })

        subject.perform(notification, result_creator: result_creator)

        expect(result_creator).to have_received(:create).with(notification: notification,
                                                              result: { 'id' => '123' })
      end

      it 'works with custom_attributes' do
        notification_data = {
          notification: {
            'title' => 'value',
            'custom_attributes' => { 'example' => '1' },
            'recipients' => [{ 'email' => 'grant@nexl.io' }]
          }
        }

        notification = instance_double(Magicbell::Rails::Notification,
                                       to_bell_hash: notification_data)

        stub_request(:post, 'https://api.magicbell.io/notifications')
          .with(
            body: notification_data.to_json,
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => 'Ruby',
              'X-MAGICBELL-API-KEY' => api_key,
              'X-MAGICBELL-API-SECRET' => api_secret
            }
          )
          .to_return(status: 200, body: '{"id":"123"}', headers: { 'Content-Type' => 'application/json' })

        subject.perform(notification, result_creator: result_creator)

        expect(result_creator).to have_received(:create).with(notification: notification,
                                                              result: { 'id' => '123' })
      end

      it 'raises error if invalid attributes' do
        notification_data = {
          notification: {
            'title' => 'value',
            'custom_attributes' => 'NotAHash',
            'recipients' => [{ 'email' => 'grant@nexl.io' }]
          }
        }

        notification = instance_double(Magicbell::Rails::Notification,
                                       to_bell_hash: notification_data)

        stub_request(:post, 'https://api.magicbell.io/notifications')
          .with(
            body: notification_data.to_json,
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => 'Ruby',
              'X-MAGICBELL-API-KEY' => api_key,
              'X-MAGICBELL-API-SECRET' => api_secret
            }
          )
          .to_return(status: 422, body: '{"errors":["custom_attributes must be a hash"]}',
                    headers: { 'Content-Type' => 'application/json' })

        expect do
          subject.perform(notification, result_creator: result_creator)
        end.to raise_error(MagicBell::Client::HTTPError)
      end

      it 'skips when no api_secret' do
        allow(Magicbell::Rails).to receive(:api_secret).and_return('')
        notification = instance_double(Magicbell::Rails::Notification)

        subject.perform(notification, result_creator: result_creator)

        expect(result_creator).not_to have_received(:create)
      end

      it 'raises error when secret invalid' do
        notification_data = {
          notification: {
            'title' => 'value',
            'recipients' => [{ 'email' => 'grant@nexl.io' }]
          }
        }

        notification = instance_double(Magicbell::Rails::Notification,
                                       to_bell_hash: notification_data)

        stub_request(:post, 'https://api.magicbell.io/notifications')
          .with(
            body: notification_data.to_json,
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => 'Ruby',
              'X-MAGICBELL-API-KEY' => api_key,
              'X-MAGICBELL-API-SECRET' => api_secret
            }
          )
          .to_return(status: 401, body: '{"errors":["Invalid API secret"]}',
                    headers: { 'Content-Type' => 'application/json' })

        expect do
          subject.perform(notification, result_creator: result_creator)
        end.to raise_error(MagicBell::Client::HTTPError)

        expect(result_creator).not_to have_received(:create)
      end
    end
  end
end
