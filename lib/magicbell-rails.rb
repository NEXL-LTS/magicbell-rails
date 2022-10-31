require 'magicbell/rails/engine' # rubocop:disable Naming/FileName

module Magicbell
  module Rails
    class Error < StandardError; end

    cattr_accessor :queue_name, default: :default
    cattr_accessor :api_key, default: ENV['MAGICBELL_API_KEY']
    cattr_accessor :api_secret, default: ENV['MAGICBELL_API_SECRET']

    def self.bell(args)
      Notification.bell(args)
    end
  end
end
