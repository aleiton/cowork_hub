# frozen_string_literal: true

# =============================================================================
# BOOKING STATUS ENUM
# =============================================================================
#
# Status of a workspace booking in its lifecycle.
#
# =============================================================================

module Types
  class BookingStatusEnum < BaseEnum
    description 'Status of a booking'

    value 'PENDING', 'Booking awaiting confirmation', value: 'pending'
    value 'CONFIRMED', 'Booking is confirmed and active', value: 'confirmed'
    value 'CANCELLED', 'Booking was cancelled', value: 'cancelled'
    value 'COMPLETED', 'Booking time has passed', value: 'completed'
  end
end
