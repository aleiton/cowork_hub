# frozen_string_literal: true

# =============================================================================
# BOOKING COMPLETION JOB
# =============================================================================
#
# Marks bookings as 'completed' once their scheduled time has passed.
#
# WHY A BACKGROUND JOB?
# We could mark bookings as completed:
# 1. Via a callback (after_save) - but this only runs when the record is touched
# 2. On-demand when fetching - but this adds latency to every request
# 3. Via a scheduled job - cleanest approach, runs independently
#
# This job runs hourly (configured in config/sidekiq.yml) and updates
# all bookings that should be marked as completed.
#
# SCHEDULE: Every hour (see config/sidekiq.yml)
# QUEUE: default
#
# =============================================================================

class BookingCompletionJob < ApplicationJob
  queue_as :default

  def perform
    completed_count = mark_past_bookings_as_completed
    log_completion(completed_count)
  end

  private

  # Find and update all bookings that have ended but aren't marked completed
  def mark_past_bookings_as_completed
    past_bookings.update_all(status: :completed)
  end

  # Bookings are "past" when:
  # - The date is before today, OR
  # - The date is today AND the end_time has passed
  #
  # We only update 'confirmed' bookings (not pending, cancelled, or already completed)
  def past_bookings
    Booking
      .where(status: :confirmed)
      .where(past_booking_conditions)
  end

  # SQL conditions for identifying past bookings
  def past_booking_conditions
    today = Date.current
    now = Time.current.strftime('%H:%M:%S')

    # Date is before today OR (date is today AND end_time has passed)
    Booking.arel_table[:date].lt(today)
           .or(
             Booking.arel_table[:date].eq(today)
                    .and(Booking.arel_table[:end_time].lteq(now))
           )
  end

  def log_completion(count)
    if count.positive?
      Rails.logger.info("[BookingCompletionJob] Marked #{count} booking(s) as completed")
    else
      Rails.logger.debug('[BookingCompletionJob] No bookings to complete')
    end
  end
end
