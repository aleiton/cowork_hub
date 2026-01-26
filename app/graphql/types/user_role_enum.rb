# frozen_string_literal: true

# =============================================================================
# USER ROLE ENUM
# =============================================================================
#
# Maps Rails enum values to GraphQL enum values.
# GraphQL enums are uppercase by convention.
#
# =============================================================================

module Types
  class UserRoleEnum < BaseEnum
    description 'User role determining access level'

    value 'GUEST', 'Guest user with limited access', value: 'guest'
    value 'MEMBER', 'Full member with booking privileges', value: 'member'
    value 'ADMIN', 'Administrator with full access', value: 'admin'
  end
end
