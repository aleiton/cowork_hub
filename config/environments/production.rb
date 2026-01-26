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

  # Enable caching with Redis (recommended) or memory.
  # Redis is better for multi-server deployments.
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  }

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

  # Allow requests from known hostnames (add your domain).
  # This protects against DNS rebinding attacks.
  # config.hosts << "coworkhub.com"
  # config.hosts << "api.coworkhub.com"

  # Clear hosts to disable protection (less secure, but simpler for initial setup)
  # config.hosts.clear
end
