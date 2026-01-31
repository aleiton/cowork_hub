# frozen_string_literal: true

# =============================================================================
# SIDEKIQ CONFIGURATION
# =============================================================================
#
# WHAT IS SIDEKIQ?
# Sidekiq is a background job processor. It takes tasks that would be too slow
# for a web request and runs them asynchronously in a separate process.
#
# USE CASES:
# - Sending emails (don't make users wait for SMTP)
# - Processing images/files
# - Calling external APIs
# - Generating reports
# - Cleanup tasks
# - Scheduled jobs (like booking completion)
#
# HOW IT WORKS:
# 1. Your Rails app enqueues a job (adds it to Redis)
# 2. Sidekiq worker processes pick up jobs from Redis
# 3. Jobs run in the background, outside the web request
#
# WHY REDIS?
# Redis is an in-memory data store that's incredibly fast.
# Sidekiq uses it as a queue because:
# - Atomic operations (no race conditions)
# - Persistence options (jobs survive restarts)
# - Pub/sub for real-time notifications
#
# RUNNING SIDEKIQ:
#   bundle exec sidekiq -C config/sidekiq.yml
#
# MONITORING:
#   Web UI at http://localhost:3000/sidekiq (development only)
#
# =============================================================================

require 'sidekiq-scheduler'

# Configure Redis connection for Sidekiq
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    # Network timeout for Redis operations
    network_timeout: 5,
    # Pool size should match concurrency
    pool_timeout: 5
  }

  # Configure the server logger
  config.logger.level = Logger.const_get(ENV.fetch('LOG_LEVEL', 'INFO').upcase)

  # Load the schedule from sidekiq.yml
  # sidekiq-scheduler reads the :schedule key automatically
  config.on(:startup) do
    schedule_file = Rails.root.join('config', 'sidekiq.yml')

    if File.exist?(schedule_file)
      schedule = YAML.load_file(schedule_file)[:schedule]
      SidekiqScheduler::Scheduler.instance.rufus_scheduler_options = { max_work_threads: 5 }
      Sidekiq.schedule = schedule if schedule
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    network_timeout: 5,
    pool_timeout: 5
  }
end
