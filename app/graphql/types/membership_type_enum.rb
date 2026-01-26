# frozen_string_literal: true

# =============================================================================
# MEMBERSHIP TYPE ENUM
# =============================================================================
#
# Duration-based membership categories.
#
# =============================================================================

module Types
  class MembershipTypeEnum < BaseEnum
    description 'Type of membership duration'

    value 'DAY_PASS', 'Single day access', value: 'day_pass'
    value 'WEEKLY', '7-day access', value: 'weekly'
    value 'MONTHLY', '30-day access', value: 'monthly'
  end
end
