# frozen_string_literal: true

# =============================================================================
# CANTINA PLAN TYPE ENUM
# =============================================================================
#
# Types of meal plans for the cafeteria subscription.
#
# =============================================================================

module Types
  class CantinaPlanTypeEnum < BaseEnum
    description 'Type of cafeteria meal plan'

    value 'FIVE_MEALS', '5 meals per month', value: 'five_meals'
    value 'TEN_MEALS', '10 meals per month', value: 'ten_meals'
    value 'TWENTY_MEALS', '20 meals per month', value: 'twenty_meals'
  end
end
