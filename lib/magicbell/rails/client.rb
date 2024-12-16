# frozen_string_literal: true

module Magicbell
  module Rails
    class Client < MagicBell::Client
      protected

      def default_headers
        # Override default headers to prevent unwanted merging
        {}
      end
    end
  end
end
