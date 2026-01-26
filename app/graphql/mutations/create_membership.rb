# frozen_string_literal: true

# =============================================================================
# CREATE MEMBERSHIP MUTATION
# =============================================================================
#
# Creates a new membership for the current user.
#
# BUSINESS RULES:
# 1. User must be authenticated
# 2. User cannot have overlapping active memberships
# 3. Membership starts immediately or at specified date
# 4. End date is calculated based on membership type
#
# =============================================================================

module Mutations
  class CreateMembership < BaseMutation
    description 'Create a new membership for the current user'

    # =========================================================================
    # INPUT ARGUMENTS
    # =========================================================================

    argument :membership_type, Types::MembershipTypeEnum, required: true,
                                                          description: 'Type of membership (day_pass, weekly, monthly)'

    argument :amenity_tier, Types::AmenityTierEnum, required: true,
                                                    description: 'Amenity tier (basic, premium)'

    argument :starts_at, GraphQL::Types::ISO8601DateTime, required: false,
                                                          description: 'When the membership starts (defaults to now)'

    # =========================================================================
    # OUTPUT FIELDS
    # =========================================================================

    field :membership, Types::MembershipType, null: true,
                                              description: 'The created membership'

    field :errors, [String], null: false,
                             description: 'Error messages if creation failed'

    # =========================================================================
    # RESOLVER
    # =========================================================================

    def resolve(membership_type:, amenity_tier:, starts_at: nil)
      # Step 1: Require authentication
      require_authentication!

      # Step 2: Default to now if no start date provided
      starts_at ||= Time.current

      # Step 3: Don't allow past start dates
      if starts_at < Time.current - 1.minute
        return error_response('Membership cannot start in the past')
      end

      # Step 4: Create the membership
      # ends_at is calculated automatically by the model callback
      membership = Membership.new(
        user: current_user,
        membership_type: membership_type,
        amenity_tier: amenity_tier,
        starts_at: starts_at
      )

      # Step 5: Authorize the action
      authorize(membership, :create)

      # Step 6: Save and return response
      if membership.save
        # Optionally trigger welcome email
        # MembershipWelcomeJob.perform_later(membership.id)

        success_response(:membership, membership)
      else
        { membership: nil, errors: format_errors(membership) }
      end
    end
  end
end
