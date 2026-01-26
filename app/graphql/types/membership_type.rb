# frozen_string_literal: true

# =============================================================================
# MEMBERSHIP TYPE
# =============================================================================
#
# GraphQL type representing a user's membership.
#
# =============================================================================

module Types
  class MembershipType < BaseObject
    description 'A user membership providing access to workspaces'

    # =========================================================================
    # BASIC FIELDS
    # =========================================================================

    field :id, ID, null: false, description: 'Unique identifier'

    field :membership_type, MembershipTypeEnum, null: false,
                                                description: 'Type of membership'

    def membership_type
      object.membership_type
    end

    field :amenity_tier, AmenityTierEnum, null: false,
                                          description: 'Amenity tier level'

    field :starts_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                       description: 'When membership starts'

    field :ends_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                     description: 'When membership ends'

    # =========================================================================
    # COMPUTED FIELDS
    # =========================================================================

    field :is_active, Boolean, null: false,
                               description: 'Whether membership is currently active'

    def is_active
      object.active?
    end

    field :is_expired, Boolean, null: false,
                                description: 'Whether membership has expired'

    def is_expired
      object.expired?
    end

    field :is_future, Boolean, null: false,
                               description: 'Whether membership starts in the future'

    def is_future
      object.future?
    end

    field :duration_days, Integer, null: false,
                                   description: 'Total duration in days'

    def duration_days
      object.duration_days
    end

    field :remaining_days, Integer, null: false,
                                    description: 'Remaining days in membership'

    def remaining_days
      object.remaining_days
    end

    field :is_expiring_soon, Boolean, null: false,
                                      description: 'Whether membership expires within 7 days' do
      argument :within_days, Integer, required: false, default_value: 7
    end

    def is_expiring_soon(within_days: 7)
      object.expiring_soon?(within_days: within_days)
    end

    field :price, Float, null: false, description: 'Price of this membership'

    def price
      object.price
    end

    # =========================================================================
    # RELATIONSHIPS
    # =========================================================================

    field :user, UserType, null: false, description: 'The member'

    def user
      Loaders::RecordLoader.for(User).load(object.user_id)
    end

    # =========================================================================
    # TIMESTAMPS
    # =========================================================================

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
