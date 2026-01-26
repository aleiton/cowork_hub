# frozen_string_literal: true

# =============================================================================
# APPLICATION POLICY (Base Policy)
# =============================================================================
#
# Pundit uses Policy classes to encapsulate authorization logic.
# This is the base class for all policies in the application.
#
# AUTHENTICATION vs AUTHORIZATION:
# - Authentication (Devise): "Who are you?" - Verifying identity
# - Authorization (Pundit): "What can you do?" - Checking permissions
#
# HOW PUNDIT WORKS:
# 1. Controller calls: authorize(@post, :update?)
# 2. Pundit finds PostPolicy class
# 3. Creates: PostPolicy.new(current_user, @post)
# 4. Calls: policy.update?
# 5. Returns true/false or raises NotAuthorizedError
#
# NAMING CONVENTION:
# - Model: Post
# - Policy: PostPolicy
# - Method: update? (matches action + ?)
#
# =============================================================================

class ApplicationPolicy
  # user is the current user (from controller's current_user)
  # record is the model instance being authorized
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # =========================================================================
  # DEFAULT POLICIES
  # =========================================================================
  # These are the default implementations. Override in specific policies.
  # By default, everything is denied (secure by default).

  # Can the user view the index of this resource?
  def index?
    false
  end

  # Can the user view this specific record?
  def show?
    false
  end

  # Can the user create a new record?
  def create?
    false
  end

  # Can the user edit this record?
  def new?
    create?
  end

  # Can the user update this record?
  def update?
    false
  end

  # Can the user access the edit form?
  def edit?
    update?
  end

  # Can the user delete this record?
  def destroy?
    false
  end

  # =========================================================================
  # HELPER METHODS
  # =========================================================================

  private

  # Check if user is authenticated
  def authenticated?
    user.present?
  end

  # Check if user is admin
  def admin?
    user&.role_admin?
  end

  # Check if user is member (includes admin)
  def member?
    user&.role_member? || admin?
  end

  # Check if user owns the record (for records with user_id)
  def owner?
    return false unless user && record.respond_to?(:user_id)

    record.user_id == user.id
  end

  # =========================================================================
  # SCOPE CLASS
  # =========================================================================
  # Scopes filter collections of records based on what the user can see.
  # Usage: policy_scope(Post) returns only posts the user can see.

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Override this in specific policy scopes
    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope

    def admin?
      user&.role_admin?
    end
  end
end
