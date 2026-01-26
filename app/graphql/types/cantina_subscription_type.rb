# frozen_string_literal: true

# =============================================================================
# CANTINA SUBSCRIPTION TYPE
# =============================================================================
#
# GraphQL type representing a cafeteria meal subscription.
#
# =============================================================================

module Types
  class CantinaSubscriptionType < BaseObject
    description 'A cafeteria meal subscription'

    # =========================================================================
    # BASIC FIELDS
    # =========================================================================

    field :id, ID, null: false, description: 'Unique identifier'

    field :plan_type, CantinaPlanTypeEnum, null: false, description: 'Type of meal plan'

    def plan_type
      object.plan_type
    end

    field :meals_remaining, Integer, null: false,
                                     description: 'Number of meals remaining'

    field :renews_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                       description: 'When the subscription renews'

    # =========================================================================
    # COMPUTED FIELDS
    # =========================================================================

    field :is_active, Boolean, null: false,
                               description: 'Whether subscription is active'

    def is_active
      object.active?
    end

    field :is_depleted, Boolean, null: false,
                                 description: 'Whether all meals are used'

    def is_depleted
      object.depleted?
    end

    field :is_due_for_renewal, Boolean, null: false,
                                        description: 'Whether subscription needs renewal'

    def is_due_for_renewal
      object.due_for_renewal?
    end

    field :meal_limit, Integer, null: false,
                                description: 'Maximum meals for this plan'

    def meal_limit
      object.meal_limit
    end

    field :meals_used, Integer, null: false,
                                description: 'Number of meals used'

    def meals_used
      object.meals_used
    end

    field :meals_remaining_percentage, Integer, null: false,
                                                description: 'Percentage of meals remaining'

    def meals_remaining_percentage
      object.meals_remaining_percentage
    end

    field :days_until_renewal, Integer, null: false,
                                        description: 'Days until renewal'

    def days_until_renewal
      object.days_until_renewal
    end

    field :price, Float, null: false, description: 'Price of this plan'

    def price
      object.price
    end

    field :can_use_meal, Boolean, null: false,
                                  description: 'Whether a meal can be used'

    def can_use_meal
      object.can_use_meal?
    end

    # =========================================================================
    # RELATIONSHIPS
    # =========================================================================

    field :user, UserType, null: false, description: 'The subscriber'

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
