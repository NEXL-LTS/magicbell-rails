# frozen_string_literal: true

module Magicbell
  module Rails
    class Client < MagicBell::Client
      protected

      def default_headers
        # Get authentication headers from parent class and merge with our additional headers
        super.merge({
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby',
          'X-MAGICBELL-API-KEY' => @api_key,
          'X-MAGICBELL-API-SECRET' => @api_secret
        })
      end
    end
  end
end
