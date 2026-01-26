# frozen_string_literal: true

# =============================================================================
# BASE OBJECT TYPE
# =============================================================================
#
# BaseObject is the parent class for all GraphQL object types in our schema.
# It's analogous to ApplicationRecord for models.
#
# GRAPHQL TYPES EXPLAINED:
# Types define the structure of data in GraphQL. They're like TypeScript
# interfaces - they specify what fields exist and what types those fields have.
#
# EXAMPLE:
# type User {
#   id: ID!
#   email: String!
#   role: UserRole!
#   bookings: [Booking!]!
# }
#
# The Ruby class below generates this SDL (Schema Definition Language).
#
# =============================================================================

module Types
  class BaseObject < GraphQL::Schema::Object
    # =========================================================================
    # EDGE TYPES FOR CONNECTIONS
    # =========================================================================
    # When using Relay-style pagination (connections), GraphQL needs Edge
    # and Connection types. These are auto-generated but we configure them here.

    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)

    # =========================================================================
    # FIELD CLASS
    # =========================================================================
    # Custom field class allows adding shared behavior to all fields
    field_class Types::BaseField

    # =========================================================================
    # SHARED HELPERS
    # =========================================================================

    # Access the current user from context
    # Context is passed through all resolvers and contains request-specific data
    def current_user
      context[:current_user]
    end

    # Check if user is authenticated
    def authenticated?
      current_user.present?
    end

    # Check if current user is admin
    def admin?
      current_user&.role_admin?
    end

    # Helper for Pundit authorization
    def authorize(record, action)
      policy = Pundit.policy!(current_user, record)
      unless policy.public_send("#{action}?")
        raise Pundit::NotAuthorizedError, "not allowed to #{action} this resource"
      end

      true
    end
  end
end
