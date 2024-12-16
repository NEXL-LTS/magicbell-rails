# frozen_string_literal: true

module Magicbell
  module Rails
    class Client < MagicBell::Client
      def put(url, options = {})
        # Ensure headers exist in options
        options[:headers] ||= {}

        # Get the default headers from parent class
        all_headers = default_headers

        # Merge with provided headers, letting provided headers take precedence
        # This ensures user-specific headers (external ID and HMAC) are preserved
        options[:headers] = all_headers.merge(options[:headers])

        # Call parent class's put method with merged headers
        super(url, options)
      end

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
