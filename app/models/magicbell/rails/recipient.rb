module Magicbell
  module Rails
    class Recipient < ApplicationRecord
      belongs_to :notification

      has_many :phones, dependent: :destroy

      def to_graphql_hash
        attributes.except('id', 'created_at', 'updated_at', 'notification_id')
                  .merge('phone_numbers' => phones.map(&:number))
                  .compact_blank
      end
    end
  end
end
