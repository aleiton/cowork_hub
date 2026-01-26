# frozen_string_literal: true

# =============================================================================
# USE CANTINA CREDIT MUTATION
# =============================================================================
#
# Uses a meal credit from the user's cafeteria subscription.
#
# BUSINESS RULES:
# 1. User must be authenticated
# 2. User must have an active subscription
# 3. Subscription must have remaining meals
# 4. Cannot use more meals than available
#
# EDGE CASES:
# - Concurrent requests: Handled by atomic SQL update in model
# - Expired subscription: Checked by active? method
# - Zero meals: use_meal! returns false
#
# =============================================================================

module Mutations
  class UseCantinaCredit < BaseMutation
    description 'Use a meal credit from your cafeteria subscription'

    # =========================================================================
    # OUTPUT FIELDS
    # =========================================================================

    field :cantina_subscription, Types::CantinaSubscriptionType, null: true,
                                                                 description: 'The updated subscription'

    field :meals_remaining, Integer, null: true,
                                     description: 'Number of meals remaining after use'

    field :errors, [String], null: false,
                             description: 'Error messages if operation failed'

    # =========================================================================
    # RESOLVER
    # =========================================================================

    def resolve
      # Step 1: Require authentication
      require_authentication!

      # Step 2: Find active subscription
      subscription = current_user.active_cantina_subscription

      unless subscription
        return error_response('You do not have an active cafeteria subscription')
      end

      # Step 3: Check if meal can be used
      unless subscription.can_use_meal?
        if subscription.depleted?
          return error_response('You have no meals remaining in your subscription')
        elsif subscription.due_for_renewal?
          return error_response('Your subscription has expired and needs renewal')
        else
          return error_response('Unable to use meal credit')
        end
      end

      # Step 4: Use the meal (atomic operation)
      if subscription.use_meal!
        {
          cantina_subscription: subscription,
          meals_remaining: subscription.meals_remaining,
          errors: []
        }
      else
        # This shouldn't happen if can_use_meal? passed, but handle it
        error_response('Failed to use meal credit. Please try again.')
      end
    end
  end
end
