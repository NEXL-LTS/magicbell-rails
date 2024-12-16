module Magicbell
  module Rails
    class Notification < ApplicationRecord
      has_many :recipients, dependent: :destroy
      has_many :results, dependent: :destroy

      validates :recipients, presence: true

      def self.bell(params)
        params = params.deep_symbolize_keys
        recipient_attributes = params.delete(:recipients) || []
        record = new(params)
        recipient_attributes.each do |recipient_attribute|
          phone_numbers = recipient_attribute.delete(:phone_numbers) || []
          recipient = record.recipients.build(recipient_attribute)
          phone_numbers.each { |phone_number| recipient.phones.build(number: phone_number) }
        end
        record.save!
        record
      end

      def deliver_later
        DeliverNotificationJob.perform_later(self)
      end

      def to_bell_hash
        {
          'notification' => attributes.except('id', 'created_at', 'updated_at')
                                   .merge('recipients' => recipients.map(&:to_bell_hash))
                                   .compact_blank
        }
      end

      def recipient_emails
        recipients.map(&:email)
      end

      def result
        results.map(&:result)
      end
    end
  end
end
