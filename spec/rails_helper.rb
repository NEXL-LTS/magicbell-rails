# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'factory_bot_rails'

return if defined?(RAILS_HELPER_LOADED)
RAILS_HELPER_LOADED = true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

ENGINE_ROOT = File.expand_path('..', __dir__)
ENGINE_PATH = File.expand_path('../lib/magicbell/rails/engine', __dir__)
APP_PATH = File.expand_path('../spec/dummy/config/application', __dir__)

require_relative 'dummy/config/environment'
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

# Add additional requires below this line. Rails is not loaded until this point!
require 'rspec/rails'
require 'vcr'
require 'webmock/rspec'
require 'shoulda/matchers'

# Load all models first
Dir[File.join(ENGINE_ROOT, 'app', 'models', '**', '*.rb')].sort.each { |f| require f }

# Then load factories and support files
Dir[File.join(ENGINE_ROOT, 'spec', 'factories', '**', '*.rb')].sort.each { |f| require f }
Dir[File.join(ENGINE_ROOT, 'spec', 'support', '**', '*.rb')].sort.each { |f| require f }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
end

ActiveRecord::Migrator.migrations_paths = [File.expand_path('../spec/dummy/db/migrate', __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
