# frozen_string_literal: true

module Magicbell
  module Rails
    class Client < MagicBell::Client
      protected

      def default_headers
        # Call super to get authentication headers and merge with our additional headers
        super.merge({
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        })
      end
    end
  end
end
