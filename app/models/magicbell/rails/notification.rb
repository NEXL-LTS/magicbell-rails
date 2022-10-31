module Magicbell
  module Rails
    class Notification < ApplicationRecord
      has_many :recipients, dependent: :destroy
      has_many :results, dependent: :destroy

      # validates :recipients, presence: true

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

      def to_graphql_hash
        attributes.except('id', 'created_at', 'updated_at')
                  .merge('recipients' => recipients.map(&:to_graphql_hash))
                  .compact_blank
                  .deep_transform_keys { |key| key.to_s.camelcase(:lower) }
      end
    end
  end
end