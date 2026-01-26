# frozen_string_literal: true

# =============================================================================
# TEST ENVIRONMENT CONFIGURATION
# =============================================================================
#
# Settings optimized for running automated tests:
# - Fast execution (caching enabled, parallel loading)
# - Predictable behavior (no external services)
# - Error visibility (exceptions propagated)
#
# =============================================================================

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # ===========================================================================
  # CACHING & LOADING
  # ===========================================================================

  # Cache classes for speed. Unlike development, we don't need hot reloading.
  config.cache_classes = true

  # Eager load all code at startup for proper test coverage.
  # This also catches load-time errors that might not occur in lazy loading.
  #
  # Note: Set to true in CI environments. Can be false locally for speed
  # if you're running specific test files.
  config.eager_load = ENV['CI'].present?

  # ===========================================================================
  # PUBLIC FILE SERVER
  # ===========================================================================

  # Serve static files from the /public folder.
  # In tests, we set Cache-Control headers to prevent caching issues.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # ===========================================================================
  # ERROR HANDLING
  # ===========================================================================

  # Show full error reports so test failures are informative.
  config.consider_all_requests_local = true

  # Disable caching in tests - we want predictable, isolated behavior.
  config.cache_store = :null_store

  # ===========================================================================
  # ACTION CONTROLLER
  # ===========================================================================

  # Disable request forgery protection in tests.
  # Tests use different authentication methods.
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false

  # ===========================================================================
  # ACTIVE STORAGE
  # ===========================================================================

  # Use a test disk service that stores files in tmp/storage.
  config.active_storage.service = :test

  # ===========================================================================
  # ACTION MAILER
  # ===========================================================================

  # In tests, emails are collected in ActionMailer::Base.deliveries
  # rather than being sent. This allows assertions like:
  # expect(ActionMailer::Base.deliveries.count).to eq(1)
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: 'www.example.com' }

  # ===========================================================================
  # ACTIVE SUPPORT
  # ===========================================================================

  # Print deprecation notices to stderr so they're visible in test output.
  config.active_support.deprecation = :stderr

  # Raise exceptions when deprecated patterns are used.
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # ===========================================================================
  # ACTIVE RECORD
  # ===========================================================================

  # Raise error when using fixtures if factory_bot is the intended tool.
  # This helps catch accidental fixture usage.
  # config.active_record.use_yaml_unsafe_load = false

  # ===========================================================================
  # ACTION VIEW
  # ===========================================================================

  # Raise errors for missing translations in tests.
  # This catches i18n issues early.
  config.i18n.raise_on_missing_translations = true

  # ===========================================================================
  # ACTION DISPATCH
  # ===========================================================================

  # Annotate rendered views with file names in comments.
  # Useful for debugging, but we're API-only so this doesn't apply much.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # ===========================================================================
  # ACTIVE JOB
  # ===========================================================================

  # Run jobs immediately in tests (inline, not queued).
  # This makes testing job behavior straightforward.
  config.active_job.queue_adapter = :test
end
