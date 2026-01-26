# frozen_string_literal: true

# =============================================================================
# BOOKING POLICY
# =============================================================================
#
# Authorization rules for Booking model.
#
# RULES:
# - Authenticated users can create bookings for themselves
# - Users can view/cancel their own bookings
# - Admins can view/modify all bookings
#
# =============================================================================

class BookingPolicy < ApplicationPolicy
  # Users can see their own bookings, admins can see all
  def index?
    authenticated?
  end

  # Users can see their own bookings, admins can see all
  def show?
    return false unless authenticated?

    owner? || admin?
  end

  # Authenticated users can create bookings
  # Additional check: they must be creating for themselves (handled in mutation)
  def create?
    authenticated?
  end

  # Users can update their own bookings (e.g., add equipment)
  # Note: Status changes might have additional restrictions
  def update?
    return false unless authenticated?

    owner? || admin?
  end

  # Users can cancel their own bookings, admins can cancel any
  # Note: Business rules about cancellation timing are in the model
  def destroy?
    return false unless authenticated?

    owner? || admin?
  end

  # Alias for cancellation
  def cancel?
    destroy?
  end

  # Only admins can confirm bookings
  def confirm?
    admin?
  end

  # =========================================================================
  # SCOPE
  # =========================================================================

  class Scope < Scope
    def resolve
      if admin?
        # Admins see all bookings
        scope.all
      elsif user.present?
        # Regular users see only their bookings
        scope.where(user_id: user.id)
      else
        # Unauthenticated users see nothing
        scope.none
      end
    end
  end
end
