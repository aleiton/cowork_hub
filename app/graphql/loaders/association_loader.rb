# frozen_string_literal: true

# =============================================================================
# ASSOCIATION LOADER
# =============================================================================
#
# This loader batches has_many association lookups to prevent N+1 queries.
#
# EXAMPLE PROBLEM (without batching):
# Query 10 workspaces with their equipment:
#   SELECT * FROM workspaces
#   SELECT * FROM workshop_equipments WHERE workspace_id = 1
#   SELECT * FROM workshop_equipments WHERE workspace_id = 2
#   ... (10 more queries)
#
# WITH THIS LOADER:
#   SELECT * FROM workspaces
#   SELECT * FROM workshop_equipments WHERE workspace_id IN (1, 2, 3, ...)
#
# USAGE:
#   Loaders::AssociationLoader.for(Workspace, :workshop_equipments).load(workspace)
#
# This returns a Promise that resolves to the associated records.
#
# =============================================================================

module Loaders
  class AssociationLoader < GraphQL::Batch::Loader
    def initialize(model, association_name)
      super()
      @model = model
      @association_name = association_name
      validate_association!
    end

    def perform(records)
      # Use ActiveRecord's preload to efficiently load associations
      # This is similar to calling includes() in a query
      preload(records)

      # Return the association for each record
      records.each { |record| fulfill(record, read_association(record)) }
    end

    private

    def validate_association!
      return if @model.reflect_on_association(@association_name)

      raise ArgumentError,
            "No association #{@association_name} on #{@model}"
    end

    def preload(records)
      # ActiveRecord::Associations::Preloader efficiently loads associations
      # for a collection of records in as few queries as possible
      ::ActiveRecord::Associations::Preloader.new(
        records: records,
        associations: @association_name
      ).call
    end

    def read_association(record)
      record.public_send(@association_name)
    end

    # Cache key includes both model and association name
    def self.for(model, association_name)
      new(model, association_name)
    end
  end
end
