# frozen_string_literal: true

# =============================================================================
# MEMBERSHIP POLICY
# =============================================================================
#
# Authorization rules for Membership model.
#
# RULES:
# - Authenticated users can create memberships for themselves
# - Users can view their own memberships
# - Admins can view/manage all memberships
#
# =============================================================================

class MembershipPolicy < ApplicationPolicy
  # Users can see their own membership history
  def index?
    authenticated?
  end

  # Users can see their own memberships, admins can see all
  def show?
    return false unless authenticated?

    owner? || admin?
  end

  # Authenticated users can create memberships for themselves
  def create?
    authenticated?
  end

  # Only admins can modify existing memberships
  # Users cannot extend their own memberships directly (need to purchase)
  def update?
    admin?
  end

  # Only admins can delete memberships
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
