# frozen_string_literal: true

# =============================================================================
# RAILS HELPER
# =============================================================================
#
# This file loads Rails and configures RSpec for Rails-specific testing.
# It includes database cleaning, factory_bot, and other Rails integrations.
#
# =============================================================================

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'

# Prevent running tests against production!
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

# Load support files
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests run
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # =========================================================================
  # FIXTURES PATH
  # =========================================================================
  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  # =========================================================================
  # DATABASE TRANSACTIONS
  # =========================================================================
  # Use transactional fixtures - each test runs in a transaction that's
  # rolled back at the end. This keeps the database clean and tests fast.
  config.use_transactional_fixtures = true

  # =========================================================================
  # INFERENCE
  # =========================================================================
  # Automatically infer spec type from file location
  # spec/models/ -> type: :model
  # spec/controllers/ -> type: :controller
  config.infer_spec_type_from_file_location!

  # =========================================================================
  # FILTERING
  # =========================================================================
  # Filter Rails framework backtrace for cleaner output
  config.filter_rails_from_backtrace!

  # =========================================================================
  # FACTORY BOT
  # =========================================================================
  # Include FactoryBot methods: create(), build(), attributes_for()
  config.include FactoryBot::Syntax::Methods

  # =========================================================================
  # DEVISE TEST HELPERS
  # =========================================================================
  # Include Devise test helpers for authentication in controller/request specs
  config.include Devise::Test::IntegrationHelpers, type: :request
end

# =============================================================================
# SHOULDA MATCHERS
# =============================================================================
# Configure Shoulda Matchers to work with RSpec and Rails
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
