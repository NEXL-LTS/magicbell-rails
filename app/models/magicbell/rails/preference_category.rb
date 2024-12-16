module Magicbell
  module Rails
    class PreferenceCategory < ApplicationRecord
      belongs_to :notification_preference
      has_many :channels, class_name: 'PreferenceChannel', dependent: :destroy

      validates :slug, presence: true, uniqueness: { scope: :notification_preference_id }

      def to_bell_hash
        {
          slug: slug,
          channels: channels.map(&:to_bell_hash)
        }
      end
    end
  end
end
