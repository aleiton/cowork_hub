# frozen_string_literal: true

# =============================================================================
# BASE ARGUMENT
# =============================================================================
#
# Arguments are inputs to GraphQL fields. They allow the client to
# pass parameters to queries and mutations.
#
# EXAMPLE:
# field :workspace, WorkspaceType, null: true do
#   argument :id, ID, required: true
# end
#
# Query:
# query {
#   workspace(id: "123") {
#     name
#   }
# }
#
# =============================================================================

module Types
  class BaseArgument < GraphQL::Schema::Argument
  end
end
