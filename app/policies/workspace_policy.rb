# frozen_string_literal: true

# =============================================================================
# WORKSPACE POLICY
# =============================================================================
#
# Authorization rules for Workspace model.
#
# RULES:
# - Everyone can view workspaces (public listing)
# - Only admins can create/update/delete workspaces
#
# =============================================================================

class WorkspacePolicy < ApplicationPolicy
  # Anyone can view the list of workspaces
  # This is public information for browsing available spaces
  def index?
    true
  end

  # Anyone can view a specific workspace
  def show?
    true
  end

  # Only admins can create new workspaces
  def create?
    admin?
  end

  # Only admins can update workspaces
  def update?
    admin?
  end

  # Only admins can delete workspaces
  def destroy?
    admin?
  end

  # =========================================================================
  # SCOPE
  # =========================================================================
  # Define which workspaces a user can see in listings

  class Scope < Scope
    def resolve
      # Everyone can see all workspaces
      # If you wanted to hide some workspaces, filter here:
      # scope.where(active: true)
      scope.all
    end
  end
end
