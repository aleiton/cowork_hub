# frozen_string_literal: true

# =============================================================================
# WORKSHOP EQUIPMENT MIGRATION
# =============================================================================
#
# WorkshopEquipment represents specialized tools available in workshop spaces.
# Examples: 3D printers, sewing machines, laser cutters, woodworking tools.
#
# RELATIONSHIP:
# - Belongs to a Workspace (workshop type only)
# - Can be reserved as part of a Booking
#
# DESIGN DECISIONS:
# - Equipment is tied to a specific workspace (can't move between rooms)
# - quantity_available allows multiple units of same equipment type
# - This is normalized data (vs denormalized JSONB in workspace)
#
# =============================================================================

class CreateWorkshopEquipments < ActiveRecord::Migration[7.1]
  def change
    create_table :workshop_equipments do |t|
      # =========================================================================
      # RELATIONSHIP
      # =========================================================================
      # foreign_key: true adds a database-level constraint ensuring
      # the workspace_id references an existing workspace.
      # If someone tries to delete a workspace with equipment, it will fail.
      #
      # null: false means every equipment must belong to a workspace.
      t.references :workspace, null: false, foreign_key: true

      # =========================================================================
      # EQUIPMENT DETAILS
      # =========================================================================

      # Name of the equipment (e.g., "Prusa i3 MK3S 3D Printer")
      t.string :name, null: false

      # Detailed description, usage instructions, requirements
      t.text :description

      # How many units of this equipment are available
      # e.g., workshop might have 5 identical sewing machines
      t.integer :quantity_available, null: false, default: 1

      # =========================================================================
      # ADDITIONAL METADATA (Optional)
      # =========================================================================
      # You could track more info about equipment:
      # t.string :manufacturer
      # t.string :model_number
      # t.date :last_maintenance_date
      # t.text :maintenance_notes

      # =========================================================================
      # TIMESTAMPS
      # =========================================================================
      t.timestamps null: false
    end

    # ===========================================================================
    # INDEXES
    # ===========================================================================
    # The references line above automatically creates an index on workspace_id.
    # Add additional indexes as needed for common queries.

    # Index for searching equipment by name
    add_index :workshop_equipments, :name
  end
end
