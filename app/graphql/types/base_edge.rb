# frozen_string_literal: true

# =============================================================================
# BASE EDGE
# =============================================================================
#
# Edges are part of Relay-style pagination (Connections).
#
# RELAY CONNECTIONS EXPLAINED:
# Connections provide a standardized way to paginate lists in GraphQL.
# The structure is: Connection -> Edges -> Nodes
#
# query {
#   workspaces(first: 10, after: "cursor123") {
#     edges {
#       cursor
#       node {
#         id
#         name
#       }
#     }
#     pageInfo {
#       hasNextPage
#       endCursor
#     }
#   }
# }
#
# WHY EDGES?
# Edges can contain edge-specific metadata (like the cursor).
# This separates pagination concerns from the actual data.
#
# =============================================================================

module Types
  class BaseEdge < GraphQL::Types::Relay::BaseEdge
  end
end
