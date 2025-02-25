module Magicbell
  module Rails
    module User
      def self.exists?(external_id:)
        Magicbell::Rails.client.user_with_external_id(external_id).notification_preferences.retrieve
        true
      rescue MagicBell::Client::HTTPError
        false
      end

      def self.create(external_id:, email:, first_name:, last_name:, phone_numbers: [])
        payload = {
          user: { external_id:, email:, first_name:, last_name:, custom_attributes: {}, phone_numbers: }
        }

        begin
          response = Magicbell::Rails.client.post('https://api.magicbell.com/users', body: payload.to_json)

          JSON.parse(response.body)['user']
        rescue MagicBell::Client::HTTPError
          false
        end
      end
    end
  end
end
