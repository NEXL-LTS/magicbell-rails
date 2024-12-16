# frozen_string_literal: true

module Magicbell
  module Rails
    class Client < MagicBell::Client
      def put(url, options = {})
        # Ensure headers are properly merged
        options[:headers] = default_headers.merge(options[:headers] || {})
        super(url, options)
      end

      protected

      def default_headers
        {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby'
        }
      end
    end
  end
end
