module Magicbell
  module Rails
    class PreferenceChannel < ApplicationRecord
      belongs_to :preference_category

      validates :slug, presence: true, uniqueness: { scope: :preference_category_id }
      validates :enabled, inclusion: { in: [true, false] }

      def to_bell_hash
        {
          slug: slug,
          enabled: enabled
        }
      end
    end
  end
end
