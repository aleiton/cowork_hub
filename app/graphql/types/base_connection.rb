# frozen_string_literal: true

# =============================================================================
# BASE CONNECTION
# =============================================================================
#
# Connections wrap lists of items with pagination info.
#
# CONNECTION STRUCTURE:
# {
#   "edges": [
#     { "cursor": "abc", "node": { ... } },
#     { "cursor": "def", "node": { ... } }
#   ],
#   "pageInfo": {
#     "hasNextPage": true,
#     "hasPreviousPage": false,
#     "startCursor": "abc",
#     "endCursor": "def"
#   }
# }
#
# PAGINATION ARGUMENTS (auto-added):
# - first: Int - Get first N items
# - after: String - Cursor to start after
# - last: Int - Get last N items
# - before: String - Cursor to start before
#
# =============================================================================

module Types
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    # Add a total count field to all connections
    # This is useful for showing "Showing 1-10 of 100 results"
    field :total_count, Integer, null: false,
                                 description: 'Total number of items in the connection'

    def total_count
      # object is the ActiveRecord::Relation being paginated
      object.items.size
    rescue StandardError
      # Fallback for cases where items isn't available
      0
    end
  end
end
