# frozen_string_literal: true

# =============================================================================
# CREATE CANTINA SUBSCRIPTION MUTATION
# =============================================================================
#
# Creates a new cafeteria meal subscription for the current user.
#
# BUSINESS RULES:
# 1. User must be authenticated
# 2. Subscription starts with full meal allowance
# 3. Renews monthly
#
# =============================================================================

module Mutations
  class CreateCantinaSubscription < BaseMutation
    description 'Create a new cafeteria meal subscription'

    # =========================================================================
    # INPUT ARGUMENTS
    # =========================================================================

    argument :plan_type, Types::CantinaPlanTypeEnum, required: true,
                                                     description: 'Type of meal plan (five_meals, ten_meals, twenty_meals)'

    # =========================================================================
    # OUTPUT FIELDS
    # =========================================================================

    field :cantina_subscription, Types::CantinaSubscriptionType, null: true,
                                                                 description: 'The created subscription'

    field :errors, [String], null: false,
                             description: 'Error messages if creation failed'

    # =========================================================================
    # RESOLVER
    # =========================================================================

    def resolve(plan_type:)
      # Step 1: Require authentication
      require_authentication!

      # Step 2: Check if user already has an active subscription
      if current_user.active_cantina_subscription
        return error_response('You already have an active cafeteria subscription')
      end

      # Step 3: Create the subscription
      # meals_remaining and renews_at are set by model callbacks
      subscription = CantinaSubscription.new(
        user: current_user,
        plan_type: plan_type
      )

      # Step 4: Authorize the action
      authorize(subscription, :create)

      # Step 5: Save and return response
      if subscription.save
        success_response(:cantina_subscription, subscription)
      else
        { cantina_subscription: nil, errors: format_errors(subscription) }
      end
    end
  end
end
