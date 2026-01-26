# frozen_string_literal: true

# =============================================================================
# BASE INPUT OBJECT
# =============================================================================
#
# Input objects are complex arguments for mutations.
# Instead of passing many individual arguments, you can group them.
#
# EXAMPLE:
# input CreateBookingInput {
#   workspaceId: ID!
#   date: ISO8601Date!
#   startTime: String!
#   endTime: String!
#   equipmentIds: [ID!]
# }
#
# mutation {
#   createBooking(input: {
#     workspaceId: "1",
#     date: "2024-03-15",
#     startTime: "09:00",
#     endTime: "17:00"
#   }) {
#     booking { id }
#   }
# }
#
# =============================================================================

module Types
  class BaseInputObject < GraphQL::Schema::InputObject
    argument_class Types::BaseArgument
  end
end
