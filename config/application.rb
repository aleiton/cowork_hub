# frozen_string_literal: true

require_relative 'boot'

# =============================================================================
# APPLICATION CONFIGURATION
# =============================================================================
#
# This file configures the Rails application. Settings here apply to all
# environments (development, test, production).
#
# Rails uses "convention over configuration" - most things work out of the box.
# We only configure things that differ from defaults.
#
# =============================================================================

require 'rails/all'

# Bundler.require loads all gems in the Gemfile based on the current environment.
# The :default group is always loaded, plus the current Rails.env group.
Bundler.require(*Rails.groups)

module CoworkHub
  class Application < Rails::Application
    # ==========================================================================
    # RAILS VERSION
    # ==========================================================================
    # Initialize configuration defaults for the Rails version.
    # This sets sensible defaults that match Rails 7.1 best practices.
    # When upgrading Rails, update this to enable new default behaviors.
    config.load_defaults 7.1

    # ==========================================================================
    # API MODE
    # ==========================================================================
    # We're building an API-only application (no server-rendered views).
    # This removes middleware we don't need (cookies, sessions, flash messages,
    # static file serving, etc.) making the app lighter and faster.
    #
    # If you needed a traditional Rails app with views, you'd remove this.
    config.api_only = true

    # ==========================================================================
    # AUTOLOAD PATHS
    # ==========================================================================
    # Zeitwerk is Rails' autoloader - it automatically loads Ruby files based
    # on their file path. For example:
    # - app/services/booking_service.rb -> BookingService
    # - app/graphql/types/user_type.rb -> Types::UserType
    #
    # We add custom directories here that Rails doesn't autoload by default.
    config.autoload_paths += %W[
      #{config.root}/app/services
      #{config.root}/app/graphql
    ]

    # ==========================================================================
    # TIMEZONE
    # ==========================================================================
    # Store times in UTC in the database (standard practice).
    # Display times in the application timezone.
    # This prevents timezone bugs when your servers are in different locations.
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # ==========================================================================
    # GENERATORS
    # ==========================================================================
    # Configure what Rails generators create (or skip) by default.
    # This keeps generated code clean and consistent with our choices.
    config.generators do |g|
      # Use RSpec instead of Minitest
      g.test_framework :rspec,
                       fixtures: false,           # We use factories, not fixtures
                       view_specs: false,         # API-only, no views
                       helper_specs: false,       # No helpers in API mode
                       routing_specs: false,      # Test routes through request specs
                       request_specs: true        # Enable request specs

      # Use factory_bot for test data
      g.fixture_replacement :factory_bot, dir: 'spec/factories'

      # Skip assets (API-only app)
      g.assets false
      g.helper false

      # Generate migration files with UUID primary keys (optional, but good practice)
      # UUIDs are better for distributed systems and don't leak information
      # about record counts. Uncomment if you prefer UUIDs.
      # g.orm :active_record, primary_key_type: :uuid
    end

    # ==========================================================================
    # ACTIVE JOB
    # ==========================================================================
    # Configure Sidekiq as the queue adapter for background jobs.
    # Alternative adapters: :async (in-memory, dev only), :inline (no queue)
    config.active_job.queue_adapter = :sidekiq

    # ==========================================================================
    # SESSION STORE (FOR DEVISE)
    # ==========================================================================
    # Even in API mode, Devise needs some session/cookie support.
    # We use a memory store since we primarily use JWT tokens.
    config.session_store :cookie_store, key: '_cowork_hub_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore,
                          config.session_options
  end
end
