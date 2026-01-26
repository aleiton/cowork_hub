# frozen_string_literal: true

# =============================================================================
# CANCEL BOOKING MUTATION
# =============================================================================
#
# Cancels an existing booking.
#
# BUSINESS RULES:
# 1. User must be authenticated
# 2. User can only cancel their own bookings (or admin can cancel any)
# 3. Cannot cancel already cancelled or completed bookings
# 4. Cannot cancel past bookings
#
# =============================================================================

module Mutations
  class CancelBooking < BaseMutation
    description 'Cancel an existing booking'

    # =========================================================================
    # INPUT ARGUMENTS
    # =========================================================================

    argument :id, ID, required: true,
                      description: 'ID of the booking to cancel'

    # =========================================================================
    # OUTPUT FIELDS
    # =========================================================================

    field :booking, Types::BookingType, null: true,
                                        description: 'The cancelled booking'

    field :errors, [String], null: false,
                             description: 'Error messages if cancellation failed'

    # =========================================================================
    # RESOLVER
    # =========================================================================

    def resolve(id:)
      # Step 1: Require authentication
      require_authentication!

      # Step 2: Find the booking
      booking = Booking.find_by(id: id)
      return error_response('Booking not found') unless booking

      # Step 3: Authorize the action
      # User can cancel their own bookings, or admin can cancel any
      unless booking.user_id == current_user.id || admin?
        return error_response('You can only cancel your own bookings')
      end

      # Step 4: Check if booking can be cancelled
      unless booking.cancellable?
        return error_response('This booking cannot be cancelled')
      end

      # Step 5: Cancel the booking
      if booking.cancel!
        # Optionally trigger notification
        # BookingCancellationJob.perform_later(booking.id)

        success_response(:booking, booking)
      else
        { booking: nil, errors: format_errors(booking) }
      end
    end
  end
end
