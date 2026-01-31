# frozen_string_literal: true

# =============================================================================
# PRODUCTION ENVIRONMENT CONFIGURATION
# =============================================================================
#
# Settings optimized for production:
# - Maximum performance (caching, compiled assets)
# - Security (HTTPS, secure cookies)
# - Reliability (error handling, logging)
#
# =============================================================================

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # ===========================================================================
  # CODE LOADING
  # ===========================================================================

  # Cache classes - code is loaded once at startup and never reloaded.
  # This is crucial for performance.
  config.cache_classes = true

  # Eager load all application code at startup.
  # This finds errors early and enables copy-on-write in forked processes.
  config.eager_load = true

  # ===========================================================================
  # ERROR HANDLING
  # ===========================================================================

  # Don't show full error reports to users (security risk).
  # Instead, show a generic error page.
  config.consider_all_requests_local = false

  # ===========================================================================
  # CACHING
  # ===========================================================================

  # Use memory store for Rails caching (sufficient for single-instance API)
  # Sidekiq uses Redis directly for job queue (separate from this cache)
  # 32 MB = 32 * 1024 * 1024 bytes
  config.cache_store = :memory_store, { size: 33_554_432 }

  # ===========================================================================
  # STATIC FILES
  # ===========================================================================

  # Disable static file serving - let nginx/CDN handle this.
  # If using Heroku or similar, set to true.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # ===========================================================================
  # ACTIVE STORAGE
  # ===========================================================================

  # Use cloud storage (S3, GCS, Azure) in production.
  # Configure in config/storage.yml.
  config.active_storage.service = :local # Change to :amazon, :google, etc.

  # ===========================================================================
  # FORCE SSL
  # ===========================================================================

  # Force all access to be over HTTPS. This is critical for security.
  # HTTPS encrypts all traffic including authentication tokens.
  # Exclude health check path since Fly.io handles SSL at the proxy level
  # and internal health checks use HTTP.
  config.ssl_options = {
    redirect: {
      exclude: ->(request) { request.path.start_with?('/health') }
    }
  }
  config.force_ssl = true

  # ===========================================================================
  # LOGGING
  # ===========================================================================

  # Use structured JSON logging for better parsing by log aggregators
  # (Datadog, Splunk, ELK, etc.)
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info').to_sym

  # Log to STDOUT (works with Docker, Heroku, etc.)
  config.log_tags = [:request_id]

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # ===========================================================================
  # ACTION MAILER
  # ===========================================================================

  # Use a real email service in production (SendGrid, Mailgun, SES, etc.)
  config.action_mailer.perform_caching = false

  # Example SendGrid configuration:
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: 'smtp.sendgrid.net',
  #   port: 587,
  #   user_name: 'apikey',
  #   password: ENV['SENDGRID_API_KEY'],
  #   authentication: :plain,
  #   enable_starttls_auto: true
  # }

  # Set the host for URL generation in emails
  config.action_mailer.default_url_options = {
    host: ENV.fetch('APPLICATION_HOST', 'example.com'),
    protocol: 'https'
  }

  # ===========================================================================
  # INTERNATIONALIZATION
  # ===========================================================================

  # Raise exception if translation is missing (better than showing key).
  config.i18n.fallbacks = true

  # ===========================================================================
  # ACTIVE SUPPORT
  # ===========================================================================

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []

  # ===========================================================================
  # ACTIVE RECORD
  # ===========================================================================

  # Dump schema in SQL format (preserves PostgreSQL-specific features).
  config.active_record.dump_schema_after_migration = false

  # ===========================================================================
  # DNS REBINDING PROTECTION
  # ===========================================================================

  # Allow requests from known hostnames.
  # Fly.io uses .fly.dev domain for apps.
  config.hosts << '.fly.dev'
  config.hosts << 'cowork-hub-api.fly.dev'

  # Allow health checks from internal Fly.io IPs
  config.host_authorization = { exclude: ->(request) { request.path == '/health' } }

  # If you have a custom domain, add it here:
  # config.hosts << "api.coworkhub.com"
end
