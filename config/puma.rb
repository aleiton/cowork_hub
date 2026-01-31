# frozen_string_literal: true

# =============================================================================
# PUMA WEB SERVER CONFIGURATION
# =============================================================================
#
# Puma is a fast, concurrent web server for Ruby/Rails applications.
# It uses threads to handle multiple requests simultaneously.
#
# KEY CONCEPTS:
# - Workers: Separate OS processes (for using multiple CPU cores)
# - Threads: Lightweight execution units within a worker
#
# TUNING GUIDELINES:
# - threads min should match max for consistent behavior
# - threads count = 5 is good default for IO-bound apps
# - workers = number of CPU cores for CPU-bound work
# - In development, usually 1 worker with 5 threads
#
# =============================================================================

# Thread count configuration
# WEB_CONCURRENCY is for threads (in Puma's terminology)
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Worker timeout (seconds before killing an unresponsive worker)
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

# Port to listen on
port ENV.fetch('PORT', 3000)

# Environment
environment ENV.fetch('RAILS_ENV', 'development')

# Pid file location
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Workers configuration for production
# Workers are forked processes for parallel request handling
# WEB_CONCURRENCY controls the number of worker processes
workers ENV.fetch('WEB_CONCURRENCY', 0)

# Preload the application for faster worker spawning and memory efficiency
# This loads the app before forking workers, sharing memory via copy-on-write
preload_app! if ENV.fetch('WEB_CONCURRENCY', 0).to_i > 0

# Lifecycle hooks for forked workers
on_worker_boot do
  # Reconnect to database after fork
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Allow Puma to be restarted by the `bin/rails restart` command
plugin :tmp_restart
