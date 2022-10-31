module Magicbell
  module Rails
    class DeliverNotificationJob < ApplicationJob
      queue_as Rails.queue_name

      Schema = GraphQL::Client.load_schema("#{__dir__}/../../../graphql_schema.json")
      Client = GraphQL::Client.new(schema: Schema, execute: Magicbell::Rails::Graphql::HTTP)

      Query = Client.parse File.read("#{__dir__}/create_notification.gql")

      def perform(notification, result_creator: Result)
        return if Rails.api_secret.blank?

        result = Client.query(Query, variables: { input: notification.to_graphql_hash })
        raise Error, result.errors.to_h.to_s if result.errors.present? # rubocop:disable Rails/DeprecatedActiveModelErrorsMethods

        result_creator.create(notification: notification, result: result.to_h)
      end
    end
  end
end
