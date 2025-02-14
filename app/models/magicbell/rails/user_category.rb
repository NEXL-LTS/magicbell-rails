module Magicbell
  module Rails
    module UserCategory
      UserCategory = Struct.new(:slug, :label, :channels, keyword_init: true)
      Channel = Struct.new(:slug, :label, :enabled, keyword_init: true)

      # Fetches all categories for a user
      def self.fetch(external_id:)
        response = Magicbell::Rails.client.user_with_external_id(external_id)
                                   .notification_preferences.retrieve.attributes

        Array(response['categories']).map do |category|
          UserCategory.new(
            slug: category['slug'], label: category['label'],
            channels: category['channels'].map do |channel|
              Channel.new(slug: channel['slug'], label: channel['label'], enabled: channel['enabled'])
            end
          )
        end
      end
    end
  end
end
