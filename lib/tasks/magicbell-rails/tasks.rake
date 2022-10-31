namespace :magicbell_rails do
  task dump_graphql_schema: :environment do
    GraphQL::Client.dump_schema(Magicbell::Rails::Graphql::HTTP,
                                "#{__dir__}/../../../app/graphql_schema.json")
  end
end
