# frozen_string_literal: true

# =============================================================================
# MUTATION TYPE
# =============================================================================
#
# The MutationType defines all write operations (mutations) in the GraphQL API.
# These are equivalent to POST/PUT/DELETE requests in REST.
#
# MUTATIONS ARE:
# - Write operations: They modify data
# - Not cacheable: Results should not be cached
# - Sequential: Mutations in a request run in order
#
# MUTATION EXAMPLE:
# mutation {
#   createBooking(input: {
#     workspaceId: "1",
#     date: "2024-03-15",
#     startTime: "09:00",
#     endTime: "17:00"
#   }) {
#     booking {
#       id
#       status
#     }
#     errors
#   }
# }
#
# =============================================================================

module Types
  class MutationType < BaseObject
    description 'The mutation root of the CoworkHub schema'

    # =========================================================================
    # BOOKING MUTATIONS
    # =========================================================================

    field :create_booking, mutation: Mutations::CreateBooking,
                           description: 'Create a new workspace booking'

    field :cancel_booking, mutation: Mutations::CancelBooking,
                           description: 'Cancel an existing booking'

    field :confirm_booking, mutation: Mutations::ConfirmBooking,
                            description: 'Confirm a pending booking (admin only)'

    # =========================================================================
    # MEMBERSHIP MUTATIONS
    # =========================================================================

    field :create_membership, mutation: Mutations::CreateMembership,
                              description: 'Create a new membership'

    # =========================================================================
    # CANTINA SUBSCRIPTION MUTATIONS
    # =========================================================================

    field :create_cantina_subscription, mutation: Mutations::CreateCantinaSubscription,
                                        description: 'Create a new cafeteria subscription'

    field :use_cantina_credit, mutation: Mutations::UseCantinaCredit,
                               description: 'Use a meal credit from subscription'

    # =========================================================================
    # WORKSPACE MUTATIONS (Admin only)
    # =========================================================================

    field :create_workspace, mutation: Mutations::CreateWorkspace,
                             description: 'Create a new workspace (admin only)'

    field :update_workspace, mutation: Mutations::UpdateWorkspace,
                             description: 'Update an existing workspace (admin only)'
  end
end
