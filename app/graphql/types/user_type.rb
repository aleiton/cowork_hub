# frozen_string_literal: true

# =============================================================================
# USER TYPE
# =============================================================================
#
# GraphQL type representing a User.
# Fields are carefully chosen to expose only what clients need.
#
# SECURITY CONSIDERATIONS:
# - Never expose encrypted_password or other sensitive fields
# - Some fields may need authorization checks
#
# =============================================================================

module Types
  class UserType < BaseObject
    description 'A user of the CoworkHub platform'

    # =========================================================================
    # BASIC FIELDS
    # =========================================================================

    # ID is globally unique and can be used for caching
    field :id, ID, null: false, description: 'Unique identifier'

    field :email, String, null: false, description: 'Email address'

    field :role, UserRoleEnum, null: false, description: 'User role'

    # =========================================================================
    # COMPUTED FIELDS
    # =========================================================================

    field :has_active_membership, Boolean, null: false,
                                           description: 'Whether user has an active membership'

    def has_active_membership
      object.active_membership?
    end

    field :has_premium_access, Boolean, null: false,
                                        description: 'Whether user can access premium amenities'

    def has_premium_access
      object.premium_access?
    end

    field :has_meal_credits, Boolean, null: false,
                                      description: 'Whether user has remaining meal credits'

    def has_meal_credits
      object.has_meal_credits?
    end

    # =========================================================================
    # RELATIONSHIPS
    # =========================================================================
    # These use graphql-batch loaders to prevent N+1 queries

    field :current_membership, MembershipType, null: true,
                                               description: 'Current active membership'

    def current_membership
      object.current_membership
    end

    field :active_cantina_subscription, CantinaSubscriptionType, null: true,
                                                                 description: 'Active cafeteria subscription'

    def active_cantina_subscription
      object.active_cantina_subscription
    end

    # Paginated bookings
    field :bookings, BookingType.connection_type, null: false,
                                                  description: 'User bookings' do
      argument :status, BookingStatusEnum, required: false,
                                           description: 'Filter by status'
      argument :upcoming_only, Boolean, required: false, default_value: false,
                                        description: 'Only show upcoming bookings'
    end

    def bookings(status: nil, upcoming_only: false)
      scope = object.bookings.includes(:workspace)

      scope = scope.where(status: status) if status
      scope = scope.upcoming if upcoming_only

      scope.order(date: :desc, start_time: :desc)
    end

    # Paginated memberships
    field :memberships, MembershipType.connection_type, null: false,
                                                        description: 'User membership history'

    def memberships
      object.memberships.order(starts_at: :desc)
    end

    # =========================================================================
    # TIMESTAMPS
    # =========================================================================

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'When the user was created'
  end
end
