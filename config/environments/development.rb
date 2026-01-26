# frozen_string_literal: true

# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# =============================================================================
#
# Settings here override config/application.rb and apply only to development.
# The goal is to optimize for developer productivity:
# - Fast reload on code changes
# - Verbose error messages
# - Debugging tools enabled
#
# =============================================================================

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # ===========================================================================
  # CACHING & RELOADING
  # ===========================================================================

  # Reload code on every request when files change.
  # This is slower but means you see changes immediately without restarting.
  # In production, this would be false for performance.
  config.cache_classes = false

  # Eager loading loads all application code at startup.
  # In development, we disable it for faster boot times.
  # Individual files are loaded on-demand when first accessed.
  config.eager_load = false

  # ===========================================================================
  # ERROR REPORTING
  # ===========================================================================

  # Show full error reports with detailed backtraces.
  # In production, you'd show a generic error page instead.
  config.consider_all_requests_local = true

  # ===========================================================================
  # CACHING
  # ===========================================================================

  # Enable/disable caching in development.
  # Toggle with: rails dev:cache
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # ===========================================================================
  # ACTIVE STORAGE (File Uploads)
  # ===========================================================================

  # Store uploaded files locally in development.
  config.active_storage.service = :local

  # ===========================================================================
  # ACTION MAILER (Emails)
  # ===========================================================================

  # Don't actually send emails in development.
  # Errors will still be raised so you can catch problems.
  config.action_mailer.raise_delivery_errors = true

  # Cache mail views like regular views.
  config.action_mailer.perform_caching = false

  # Set default URL options for email links.
  # This is needed for Devise to generate correct URLs in emails.
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # ===========================================================================
  # ACTIVE SUPPORT
  # ===========================================================================

  # Print deprecation notices to the Rails logger.
  # Deprecation warnings help you prepare for future Rails versions.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # ===========================================================================
  # ACTIVE RECORD (Database)
  # ===========================================================================

  # Raise an error on page load if there are pending migrations.
  # This is a helpful reminder to run migrations after pulling new code.
  config.active_record.migration_error = :page_load

  # Highlight code that caused database queries in logs.
  # Makes it easy to see which line of code triggered a query.
  config.active_record.verbose_query_logs = true

  # ===========================================================================
  # BULLET (N+1 Detection)
  # ===========================================================================
  # Bullet monitors your queries and alerts you to:
  # 1. N+1 queries (add includes)
  # 2. Unused eager loading (remove includes)
  # 3. Counter cache opportunities
  #
  # This is CRITICAL for maintaining performance!
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true              # JavaScript popup in browser
    Bullet.bullet_logger = true      # Log to log/bullet.log
    Bullet.console = true            # Browser console warnings
    Bullet.rails_logger = true       # Add to Rails log
    Bullet.add_footer = true         # Add warnings to page footer

    # Uncomment to raise errors (strict mode)
    # Bullet.raise = true
  end

  # ===========================================================================
  # SERVER TIMING
  # ===========================================================================

  # Enable server timing header for debugging with Chrome DevTools.
  # Shows database time, view rendering time, etc. in Network tab.
  config.server_timing = true
end
