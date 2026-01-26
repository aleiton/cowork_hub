# frozen_string_literal: true

# =============================================================================
# MEMBERSHIPS MIGRATION
# =============================================================================
#
# Memberships give users access to workspaces for a period of time.
# Types: day pass, weekly, monthly
# Tiers: basic (standard amenities), premium (all amenities)
#
# BUSINESS LOGIC:
# - User can have multiple memberships over time
# - Only one active membership at a time (enforced in model)
# - Membership determines which workspaces user can book
# - Premium tier unlocks premium amenity workspaces
#
# =============================================================================

class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      # =========================================================================
      # RELATIONSHIP
      # =========================================================================
      t.references :user, null: false, foreign_key: true

      # =========================================================================
      # MEMBERSHIP TYPE
      # =========================================================================
      # Duration-based membership categories.
      # Values: 0 = day_pass, 1 = weekly, 2 = monthly
      #
      # Each type has different:
      # - Duration (1 day, 7 days, 30 days)
      # - Pricing (daily rate varies by type)
      # - Features (monthly might include extras)
      t.integer :membership_type, null: false, default: 0

      # =========================================================================
      # AMENITY TIER
      # =========================================================================
      # Determines which amenities the member can access.
      # Values: 0 = basic, 1 = premium
      #
      # Basic: Coffee, water, wifi, common areas
      # Premium: All basic + snacks, printing, phone booths, priority booking
      t.integer :amenity_tier, null: false, default: 0

      # =========================================================================
      # VALIDITY PERIOD
      # =========================================================================

      # When the membership becomes active
      t.datetime :starts_at, null: false

      # When the membership expires
      # For day_pass: starts_at + 1.day
      # For weekly: starts_at + 7.days
      # For monthly: starts_at + 1.month
      t.datetime :ends_at, null: false

      # =========================================================================
      # AUTO-RENEWAL (Optional)
      # =========================================================================
      # Whether membership should automatically renew
      # t.boolean :auto_renew, default: false
      # t.string :stripe_subscription_id  # For payment integration

      # =========================================================================
      # TIMESTAMPS
      # =========================================================================
      t.timestamps null: false
    end

    # ===========================================================================
    # INDEXES
    # ===========================================================================

    # For finding active memberships
    add_index :memberships, :starts_at
    add_index :memberships, :ends_at

    # Composite index for active membership queries:
    # "Find user's current active membership"
    add_index :memberships, %i[user_id ends_at]

    # For filtering by type or tier
    add_index :memberships, :membership_type
    add_index :memberships, :amenity_tier
  end
end
