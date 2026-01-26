# frozen_string_literal: true

# =============================================================================
# WORKSHOP EQUIPMENT TYPE
# =============================================================================
#
# GraphQL type representing specialized equipment in a workshop.
#
# =============================================================================

module Types
  class WorkshopEquipmentType < BaseObject
    description 'Specialized equipment available in a workshop'

    # =========================================================================
    # BASIC FIELDS
    # =========================================================================

    field :id, ID, null: false, description: 'Unique identifier'

    field :name, String, null: false, description: 'Equipment name'

    field :description, String, null: true, description: 'Equipment description and usage info'

    field :quantity_available, Integer, null: false,
                                        description: 'Number of units available'

    # =========================================================================
    # COMPUTED FIELDS
    # =========================================================================

    field :is_available, Boolean, null: false,
                                  description: 'Whether equipment has available units'

    def is_available
      object.available?
    end

    # Check availability at a specific time
    field :available_quantity_at, Integer, null: false,
                                           description: 'Available units at a specific time' do
      argument :date, GraphQL::Types::ISO8601Date, required: true
      argument :start_time, String, required: true, description: 'Start time in HH:MM format'
      argument :end_time, String, required: true, description: 'End time in HH:MM format'
    end

    def available_quantity_at(date:, start_time:, end_time:)
      start_t = Time.zone.parse("#{date} #{start_time}")
      end_t = Time.zone.parse("#{date} #{end_time}")

      object.available_quantity_at(date: date, start_time: start_t, end_time: end_t)
    end

    # =========================================================================
    # RELATIONSHIPS
    # =========================================================================

    field :workspace, WorkspaceType, null: false,
                                     description: 'The workshop this equipment belongs to'

    def workspace
      Loaders::RecordLoader.for(Workspace).load(object.workspace_id)
    end

    # =========================================================================
    # TIMESTAMPS
    # =========================================================================

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
