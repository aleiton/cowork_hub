# frozen_string_literal: true

# =============================================================================
# CONFIRM BOOKING MUTATION
# =============================================================================
#
# Confirms a pending booking. Admin only.
#
# BUSINESS RULES:
# 1. Only admins can confirm bookings
# 2. Only pending bookings can be confirmed
#
# =============================================================================

module Mutations
  class ConfirmBooking < BaseMutation
    description 'Confirm a pending booking (admin only)'

    # =========================================================================
    # INPUT ARGUMENTS
    # =========================================================================

    argument :id, ID, required: true,
                      description: 'ID of the booking to confirm'

    # =========================================================================
    # OUTPUT FIELDS
    # =========================================================================

    field :booking, Types::BookingType, null: true,
                                        description: 'The confirmed booking'

    field :errors, [String], null: false,
                             description: 'Error messages if confirmation failed'

    # =========================================================================
    # RESOLVER
    # =========================================================================

    def resolve(id:)
      # Step 1: Require admin role
      require_admin!

      # Step 2: Find the booking
      booking = Booking.find_by(id: id)
      return error_response('Booking not found') unless booking

      # Step 3: Check if booking can be confirmed
      unless booking.status_pending?
        return error_response('Only pending bookings can be confirmed')
      end

      # Step 4: Confirm the booking
      if booking.confirm!
        # Optionally trigger notification
        # BookingConfirmedNotificationJob.perform_later(booking.id)

        success_response(:booking, booking)
      else
        { booking: nil, errors: format_errors(booking) }
      end
    end
  end
end
