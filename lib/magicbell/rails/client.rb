# frozen_string_literal: true

module Magicbell
  module Rails
    class Client < MagicBell::Client
      attr_reader :user_external_id, :user_hmac

      def initialize(api_key: nil, api_secret: nil, user_external_id: nil, user_hmac: nil)
        super(api_key: api_key, api_secret: api_secret)
        @user_external_id = user_external_id
        @user_hmac = user_hmac
      end

      protected

      def default_headers
        headers = super

        # Add user-specific headers
        headers['X-Magicbell-User-External-Id'] = user_external_id if user_external_id
        headers['X-Magicbell-User-Hmac'] = user_hmac if user_hmac.present?

        headers
      end
    end
  end
end
