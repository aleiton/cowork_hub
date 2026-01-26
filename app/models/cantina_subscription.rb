# frozen_string_literal: true

# =============================================================================
# CANTINA SUBSCRIPTION MODEL
# =============================================================================
#
# CantinaSubscription provides meal credits for the coworking cafeteria.
# Users purchase a plan and can redeem meals until they're used up or
# the subscription expires.
#
# PLAN TYPES:
# - five_meals: 5 meals per month
# - ten_meals: 10 meals per month
# - twenty_meals: 20 meals per month
#
# BUSINESS LOGIC:
# - meals_remaining is decremented each time a meal is used
# - Cannot use more meals than remaining
# - Subscription renews monthly (renews_at tracks the next renewal)
# - On renewal, meals_remaining resets to plan limit
#
# DESIGN DECISIONS:
# - Denormalized meals_remaining for fast reads
# - Could also track individual meal usages in separate table for analytics
# - renews_at is when the subscription renews, not when it expires
#
# =============================================================================
# == Schema Information
#
# Table name: cantina_subscriptions
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  plan_type       :integer          default("five_meals"), not null
#  meals_remaining :integer          not null
#  renews_at       :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# =============================================================================

class CantinaSubscription < ApplicationRecord
  # ===========================================================================
  # RELATIONSHIPS
  # ===========================================================================

  belongs_to :user

  # ===========================================================================
  # ENUMS
  # ===========================================================================

  enum :plan_type, {
    five_meals: 0,
    ten_meals: 1,
    twenty_meals: 2
  }, prefix: true

  # ===========================================================================
  # CONSTANTS
  # ===========================================================================

  # Mapping of plan types to meal counts
  MEAL_LIMITS = {
    five_meals: 5,
    ten_meals: 10,
    twenty_meals: 20
  }.freeze

  # Mapping of plan types to prices (example)
  PLAN_PRICES = {
    five_meals: 50,
    ten_meals: 90,
    twenty_meals: 160
  }.freeze

  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================

  validates :plan_type, presence: true
  validates :renews_at, presence: true

  validates :meals_remaining,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Can't have more meals than the plan allows
  validate :meals_remaining_within_limit

  # ===========================================================================
  # CALLBACKS
  # ===========================================================================

  # Set initial meals_remaining based on plan type
  before_validation :set_initial_meals, on: :create

  # Set renews_at to 1 month from now if not provided
  before_validation :set_renews_at, on: :create

  # ===========================================================================
  # SCOPES
  # ===========================================================================

  # Active subscriptions (not yet expired and has meals)
  scope :active, lambda {
    where('renews_at > ? AND meals_remaining > 0', Time.current)
  }

  # Subscriptions with no meals remaining
  scope :depleted, lambda {
    where(meals_remaining: 0)
  }

  # Subscriptions due for renewal
  scope :due_for_renewal, lambda {
    where('renews_at <= ?', Time.current)
  }

  # Subscriptions renewing soon
  scope :renewing_soon, lambda { |days = 7|
    where('renews_at <= ?', days.days.from_now)
      .where('renews_at > ?', Time.current)
  }

  # ===========================================================================
  # CLASS METHODS
  # ===========================================================================

  # Get the meal limit for a plan type
  def self.meal_limit_for(type)
    MEAL_LIMITS[type.to_sym] || 5
  end

  # Get the price for a plan type
  def self.price_for(type)
    PLAN_PRICES[type.to_sym] || 50
  end

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================

  # Check if subscription is active
  def active?
    renews_at > Time.current && meals_remaining.positive?
  end

  # Check if subscription is depleted (no meals left)
  def depleted?
    meals_remaining.zero?
  end

  # Check if subscription is due for renewal
  def due_for_renewal?
    renews_at <= Time.current
  end

  # Get the maximum meals for this plan
  def meal_limit
    MEAL_LIMITS[plan_type.to_sym] || 5
  end

  # Get the price for this plan
  def price
    PLAN_PRICES[plan_type.to_sym] || 50
  end

  # Get how many meals have been used
  def meals_used
    meal_limit - meals_remaining
  end

  # Get the percentage of meals remaining
  def meals_remaining_percentage
    return 0 if meal_limit.zero?

    ((meals_remaining.to_f / meal_limit) * 100).round
  end

  # Use a meal (decrement counter)
  # Returns true if successful, false if no meals available
  #
  # IMPORTANT: This is a critical operation that should be atomic.
  # We use update_column to avoid callbacks and ensure atomicity.
  # In a high-concurrency environment, consider using pessimistic locking.
  def use_meal!
    return false unless can_use_meal?

    # Atomic decrement using SQL to prevent race conditions
    # update_column bypasses validations and callbacks for efficiency
    # The SQL ensures we don't go below 0 even with concurrent requests
    result = self.class.where(id: id)
                 .where('meals_remaining > 0')
                 .update_all('meals_remaining = meals_remaining - 1')

    if result.positive?
      # Reload to get the updated value
      reload
      true
    else
      false
    end
  end

  # Check if a meal can be used
  def can_use_meal?
    active? && meals_remaining.positive?
  end

  # Renew the subscription (reset meals, extend period)
  def renew!
    return false unless due_for_renewal?

    update!(
      meals_remaining: meal_limit,
      renews_at: 1.month.from_now
    )
  end

  # Days until renewal
  def days_until_renewal
    return 0 if due_for_renewal?

    ((renews_at - Time.current) / 1.day).ceil
  end

  # Upgrade the plan type
  def upgrade_to(new_plan_type)
    new_limit = MEAL_LIMITS[new_plan_type.to_sym]
    return false unless new_limit
    return false if new_limit <= meal_limit # Can only upgrade

    # Add the difference in meals
    additional_meals = new_limit - meal_limit

    update!(
      plan_type: new_plan_type,
      meals_remaining: meals_remaining + additional_meals
    )
  end

  private

  # ===========================================================================
  # PRIVATE METHODS
  # ===========================================================================

  # Set initial meals based on plan type
  def set_initial_meals
    return if meals_remaining.present?

    self.meals_remaining = meal_limit
  end

  # Set renews_at to 1 month from now
  def set_renews_at
    return if renews_at.present?

    self.renews_at = 1.month.from_now
  end

  # Validate meals_remaining doesn't exceed plan limit
  def meals_remaining_within_limit
    return unless meals_remaining && plan_type

    if meals_remaining > meal_limit
      errors.add(:meals_remaining, "cannot exceed #{meal_limit} for #{plan_type} plan")
    end
  end
end
