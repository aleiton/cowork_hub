# frozen_string_literal: true

# =============================================================================
# RECORD LOADER
# =============================================================================
#
# This loader batches database lookups by ID to prevent N+1 queries.
#
# THE N+1 PROBLEM EXPLAINED:
# Without batching:
#   Query 10 bookings → 10 separate queries for workspaces
#   SELECT * FROM bookings
#   SELECT * FROM workspaces WHERE id = 1
#   SELECT * FROM workspaces WHERE id = 2
#   ... (10 queries for workspaces)
#
# With batching (this loader):
#   Query 10 bookings → 1 query for all workspaces
#   SELECT * FROM bookings
#   SELECT * FROM workspaces WHERE id IN (1, 2, 3, ...)
#
# HOW IT WORKS:
# 1. GraphQL resolves a booking's workspace field
# 2. Instead of querying immediately, we call RecordLoader.for(Workspace).load(id)
# 3. The loader collects all IDs during the request
# 4. When all field resolution is done, perform() is called
# 5. perform() makes ONE query for all collected IDs
# 6. Results are distributed to the waiting resolvers
#
# USAGE:
#   Loaders::RecordLoader.for(Workspace).load(object.workspace_id)
#
# =============================================================================

module Loaders
  class RecordLoader < GraphQL::Batch::Loader
    def initialize(model)
      super()
      @model = model
    end

    # This method is called once all IDs have been collected
    def perform(ids)
      # Make one query for all IDs
      @model.where(id: ids).each { |record| fulfill(record.id, record) }

      # Mark any missing IDs as nil
      ids.each { |id| fulfill(id, nil) unless fulfilled?(id) }
    end

    # Class method for convenient loader creation
    # The key (model class) ensures separate loaders for each model
    def self.for(model)
      # GraphQL::Batch::Loader uses this to cache loaders by their arguments
      new(model)
    end
  end
end
