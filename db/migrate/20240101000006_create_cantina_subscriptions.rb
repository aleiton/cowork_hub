# frozen_string_literal: true

# =============================================================================
# CANTINA SUBSCRIPTIONS MIGRATION
# =============================================================================
#
# CantinaSubscription provides meal credits for the coworking cafeteria.
# Plans: 5, 10, or 20 meals per month
#
# BUSINESS LOGIC:
# - User purchases a meal plan (5, 10, or 20 meals)
# - Each meal consumed decrements meals_remaining
# - Plan renews monthly (or when manually renewed)
# - Unused meals may or may not roll over (business decision)
#
# DESIGN DECISIONS:
# - meals_remaining is denormalized for fast reads
# - Could alternatively count usage records, but this is simpler
# - renews_at tracks the billing cycle
#
# =============================================================================

class CreateCantinaSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :cantina_subscriptions do |t|
      # =========================================================================
      # RELATIONSHIP
      # =========================================================================
      t.references :user, null: false, foreign_key: true

      # =========================================================================
      # PLAN TYPE
      # =========================================================================
      # How many meals included in the plan.
      # Values: 0 = five_meals, 1 = ten_meals, 2 = twenty_meals
      #
      # Using enum instead of storing the number directly because:
      # 1. Plans might have different pricing not just based on count
      # 2. Easy to add custom plans later (e.g., "unlimited")
      # 3. Business logic can reference plan types symbolically
      t.integer :plan_type, null: false, default: 0

      # =========================================================================
      # MEALS TRACKING
      # =========================================================================

      # How many meals are left in the current period
      # Starts at plan limit, decrements with each use
      # Resets to plan limit on renewal
      #
      # IMPORTANT: This is denormalized data. The "source of truth" could be
      # a meal_usages table where we count records. However, counting is slow
      # for every request, so we cache the remaining count here.
      #
      # Trade-off: Faster reads, but must keep in sync (see model callbacks)
      t.integer :meals_remaining, null: false

      # =========================================================================
      # BILLING CYCLE
      # =========================================================================

      # When the subscription renews (and meals_remaining resets)
      # Typically: purchase_date + 1.month
      t.datetime :renews_at, null: false

      # =========================================================================
      # STATUS (Optional)
      # =========================================================================
      # Track if subscription is active, paused, or cancelled
      # t.integer :status, default: 0  # 0 = active, 1 = paused, 2 = cancelled

      # =========================================================================
      # PAYMENT INTEGRATION (Optional)
      # =========================================================================
      # t.string :stripe_subscription_id
      # t.datetime :last_payment_at

      # =========================================================================
      # TIMESTAMPS
      # =========================================================================
      t.timestamps null: false
    end

    # ===========================================================================
    # INDEXES
    # ===========================================================================

    # For finding subscriptions that need renewal
    add_index :cantina_subscriptions, :renews_at

    # For checking user's meal balance quickly
    add_index :cantina_subscriptions, %i[user_id renews_at]

    # For filtering by plan type
    add_index :cantina_subscriptions, :plan_type
  end
end
