# frozen_string_literal: true

module Magicbell
  module Rails
    class Client < MagicBell::Client
      protected

      def default_headers
        # Call parent's default_headers to get authentication headers
        headers = super

        # Add only our standard headers, let parent class handle authentication
        headers.merge!({
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        })

        headers
      end
    end
  end
end
