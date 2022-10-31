module Magicbell
  module Rails
    module Graphql
      HTTP = GraphQL::Client::HTTP.new('https://api.magicbell.com/graphql') do
        def headers(_context)
          { 'X-MAGICBELL-API-KEY': Rails.api_key,
            'X-MAGICBELL-API-SECRET': Rails.api_secret }
        end
      end
    end
  end
end
