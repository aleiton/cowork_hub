# frozen_string_literal: true

# =============================================================================
# CANTINA SUBSCRIPTION POLICY
# =============================================================================
#
# Authorization rules for CantinaSubscription model.
#
# RULES:
# - Authenticated users can create subscriptions for themselves
# - Users can view/use their own subscriptions
# - Admins can view/manage all subscriptions
#
# =============================================================================

class CantinaSubscriptionPolicy < ApplicationPolicy
  # Users can see their own subscriptions
  def index?
    authenticated?
  end

  # Users can see their own subscriptions, admins can see all
  def show?
    return false unless authenticated?

    owner? || admin?
  end

  # Authenticated users can create subscriptions for themselves
  def create?
    authenticated?
  end

  # Users can "use" their own subscription (use_meal!)
  def use_credit?
    return false unless authenticated?

    owner?
  end

  # Only admins can modify subscriptions
  def update?
    admin?
  end

  # Only admins can delete subscriptions
  def destroy?
    admin?
  end

  # =========================================================================
  # SCOPE
  # =========================================================================

  class Scope < Scope
    def resolve
      if admin?
        scope.all
      elsif user.present?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
