# frozen_string_literal: true

# =============================================================================
# BASE MUTATION
# =============================================================================
#
# BaseMutation is the parent class for all GraphQL mutations.
# It provides shared functionality like authentication checks and error handling.
#
# MUTATION STRUCTURE:
# - Input: Arguments the client sends (defined with argument())
# - Output: Fields returned to the client (defined with field())
# - resolve(): The method that executes the mutation
#
# COMMON PATTERN:
# All mutations return the mutated object AND an errors array.
# This allows partial success scenarios and detailed error messages.
#
# =============================================================================

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    # Use null: false by default (mutations always return something)
    # This means mutations ALWAYS return data (even if just errors)
    null false

    # =========================================================================
    # SHARED HELPERS
    # =========================================================================

    private

    # Get the current authenticated user from context
    def current_user
      context[:current_user]
    end

    # Check if user is authenticated
    def authenticated?
      current_user.present?
    end

    # Require authentication - raise error if not logged in
    def require_authentication!
      return if authenticated?

      raise GraphQL::ExecutionError, 'You must be logged in to perform this action'
    end

    # Check if current user is admin
    def admin?
      current_user&.role_admin?
    end

    # Require admin role
    def require_admin!
      require_authentication!
      return if admin?

      raise GraphQL::ExecutionError, 'You must be an admin to perform this action'
    end

    # Helper to authorize with Pundit
    def authorize(record, action)
      policy = Pundit.policy!(current_user, record)
      return if policy.public_send("#{action}?")

      raise GraphQL::ExecutionError, "You are not authorized to #{action} this resource"
    end

    # Format ActiveRecord validation errors for GraphQL response
    def format_errors(record)
      record.errors.full_messages
    end

    # Build success response with the record
    def success_response(field_name, record)
      { field_name => record, errors: [] }
    end

    # Build error response with messages
    def error_response(messages)
      messages = [messages] if messages.is_a?(String)
      { errors: messages }
    end
  end
end
