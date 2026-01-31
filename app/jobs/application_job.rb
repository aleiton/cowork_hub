# frozen_string_literal: true

# =============================================================================
# APPLICATION JOB
# =============================================================================
#
# Base class for all background jobs in the application.
# All jobs inherit from this class, allowing shared configuration.
#
# USAGE:
#   class MyJob < ApplicationJob
#     queue_as :default
#
#     def perform(arg1, arg2)
#       # Job logic here
#     end
#   end
#
# TRIGGERING JOBS:
#   MyJob.perform_later(arg1, arg2)  # Enqueue for async processing
#   MyJob.perform_now(arg1, arg2)    # Execute immediately (blocking)
#
# =============================================================================

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that fail due to transient errors.
  # These are common issues that often resolve on retry:
  # - Network timeouts
  # - Database deadlocks
  # - External API rate limits
  #
  # The job will retry with exponential backoff:
  # Attempt 1: immediate, Attempt 2: ~3s, Attempt 3: ~18s, etc.
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 3

  # Discard jobs when the record they're processing no longer exists.
  # This prevents errors when, for example, a user is deleted
  # but a job for that user is still in the queue.
  discard_on ActiveJob::DeserializationError
end
