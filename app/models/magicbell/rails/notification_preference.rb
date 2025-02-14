module Magicbell
  module Rails
    module NotificationPreference
      def self.update(external_id:, payload:)
        Magicbell::Rails.client.user_with_external_id(external_id).notification_preferences.update(payload)
      end
    end
  end
end
