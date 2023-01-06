require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe DeliverNotificationJob do
      let(:result_creator) { class_double(Result, create: true) }

      before do
        Rails.api_key = ENV.fetch('MAGICBELL_API_KEY', 'SET_YOUR_API_KEY')
        Rails.api_secret = ENV.fetch('MAGICBELL_API_SECRET', 'SET_YOUR_API_SECRET')
      end

      it 'works' do
        notification = instance_double(Magicbell::Rails::Notification,
                                       to_bell_hash: { 'title' => 'value',
                                                       'recipients' => [{ 'email' => 'grant@nexl.io' }] })

        VCR.use_cassette('successful') do
          subject.perform(notification, result_creator: result_creator)
        end

        expect(result_creator).to have_received(:create).with(notification: notification,
                                                              result: kind_of(Hash))
      end

      it 'works with custom_attributes' do
        notification = instance_double(Magicbell::Rails::Notification,
                                       to_bell_hash: { 'title' => 'value',
                                                       'custom_attributes' => { 'example' => '1' },
                                                       'recipients' => [{ 'email' => 'grant@nexl.io' }] })

        VCR.use_cassette('successful_with_custom_attributes') do
          subject.perform(notification, result_creator: result_creator)
        end

        expect(result_creator).to have_received(:create).with(notification: notification,
                                                              result: kind_of(Hash))
      end

      it 'raises error if invalid attributes' do
        notification = instance_double(Magicbell::Rails::Notification,
                                       to_bell_hash: { 'title' => 'value',
                                                       'custom_attributes' => 'NotAHash',
                                                       'recipients' => [{ 'email' => 'grant@nexl.io' }] })

        VCR.use_cassette('successful_with_invalid_custom_attributes') do
          expect do
            subject.perform(notification, result_creator: result_creator)
          end.to raise_error(MagicBell::Client::HTTPError)
        end
      end

      it 'skips when no api_secret' do
        Rails.api_secret = ''

        notification = instance_double(Magicbell::Rails::Notification)

        subject.perform(notification, result_creator: result_creator)

        expect(result_creator).not_to have_received(:create)
      end

      it 'raises error when secret invalid' do
        Rails.api_secret = 'asdasdasd'

        notification = instance_double(Magicbell::Rails::Notification,
                                       to_bell_hash: { 'title' => 'value',
                                                       'recipients' => [{ 'email' => 'grant@nexl.io' }] })

        VCR.use_cassette('unsuccessful') do
          expect do
            subject.perform(notification, result_creator: result_creator)
          end.to raise_error(MagicBell::Client::HTTPError)
        end

        expect(result_creator).not_to have_received(:create)
      end
    end
  end
end
