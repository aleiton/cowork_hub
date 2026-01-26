# frozen_string_literal: true

# =============================================================================
# WORKSPACES MIGRATION
# =============================================================================
#
# Workspaces represent bookable spaces in our coworking facility.
# Types include:
# - Traditional: hot desks, private offices, meeting rooms
# - Maker spaces: workshops with specialized equipment
#
# DESIGN DECISIONS:
# - Using integer enums for workspace_type and amenity_tier (efficient)
# - hourly_rate is decimal for precise currency calculations
# - capacity determines max simultaneous bookings
#
# =============================================================================

class CreateWorkspaces < ActiveRecord::Migration[7.1]
  def change
    create_table :workspaces do |t|
      # =========================================================================
      # BASIC INFORMATION
      # =========================================================================

      # Name of the workspace (e.g., "Maker Lab A", "Conference Room 3")
      t.string :name, null: false

      # Detailed description of the space and its features
      t.text :description

      # =========================================================================
      # WORKSPACE TYPE (Enum)
      # =========================================================================
      # Using integer with enum in model for efficiency.
      # Values: 0 = desk, 1 = private_office, 2 = meeting_room, 3 = workshop
      #
      # WHY ENUMS?
      # - Faster queries than string comparison
      # - Type safety (can't insert invalid values easily)
      # - Database stores small integers, code uses readable symbols
      # - Adding new types is easy (just add to model)
      t.integer :workspace_type, null: false, default: 0

      # =========================================================================
      # CAPACITY & PRICING
      # =========================================================================

      # Maximum number of people who can use this space
      t.integer :capacity, null: false, default: 1

      # Price per hour in the base currency (USD assumed)
      # Using decimal for precise currency calculations.
      #
      # WHY DECIMAL NOT FLOAT?
      # Float has precision issues: 0.1 + 0.2 != 0.3 in floating point.
      # For money, always use decimal or integer (cents).
      # precision: 10 = total digits, scale: 2 = digits after decimal
      t.decimal :hourly_rate, precision: 10, scale: 2, null: false

      # =========================================================================
      # AMENITY TIER
      # =========================================================================
      # Determines which amenities are accessible with this workspace.
      # Basic: Coffee, water, wifi
      # Premium: All of basic + snacks, printing, phone booths
      #
      # Using integer enum: 0 = basic, 1 = premium
      t.integer :amenity_tier, default: 0, null: false

      # =========================================================================
      # SOFT DELETE (Optional)
      # =========================================================================
      # Instead of permanently deleting workspaces (which would break
      # historical booking records), we can "soft delete" them.
      # Uncomment if you want this pattern:
      # t.datetime :deleted_at
      # add_index :workspaces, :deleted_at

      # =========================================================================
      # TIMESTAMPS
      # =========================================================================
      t.timestamps null: false
    end

    # ===========================================================================
    # INDEXES
    # ===========================================================================
    # Index workspace_type for filtering queries (e.g., "show all workshops")
    add_index :workspaces, :workspace_type
    add_index :workspaces, :amenity_tier
    # Composite index for common filter combinations
    add_index :workspaces, %i[workspace_type amenity_tier]
  end
end
