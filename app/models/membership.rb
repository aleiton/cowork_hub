# frozen_string_literal: true

# =============================================================================
# MEMBERSHIP MODEL
# =============================================================================
#
# Memberships provide users with access to workspaces for a duration.
# They determine:
# - How long a user can access the space (day/week/month)
# - What tier of amenities they can use (basic/premium)
# - Pricing structure (different rates for different durations)
#
# MEMBERSHIP TYPES:
# - day_pass: Single day access
# - weekly: 7-day access
# - monthly: 30-day access
#
# AMENITY TIERS:
# - basic: Coffee, water, wifi, common areas
# - premium: All basic + snacks, printing, phone booths, priority booking
#
# BUSINESS RULES:
# - Users should have only one active membership at a time
# - Memberships auto-calculate end date based on type
# - Premium tier grants access to premium amenity workspaces
#
# =============================================================================
# == Schema Information
#
# Table name: memberships
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  membership_type :integer          default("day_pass"), not null
#  amenity_tier    :integer          default("basic"), not null
#  starts_at       :datetime         not null
#  ends_at         :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# =============================================================================

class Membership < ApplicationRecord
  # ===========================================================================
  # RELATIONSHIPS
  # ===========================================================================

  belongs_to :user

  # ===========================================================================
  # ENUMS
  # ===========================================================================

  enum :membership_type, {
    day_pass: 0,
    weekly: 1,
    monthly: 2
  }, prefix: true

  enum :amenity_tier, {
    basic: 0,
    premium: 1
  }, prefix: true

  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================

  validates :membership_type, presence: true
  validates :amenity_tier, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  # End date must be after start date
  validate :ends_at_after_starts_at

  # Only one active membership per user at a time
  validate :no_overlapping_memberships, on: :create

  # ===========================================================================
  # CALLBACKS
  # ===========================================================================

  # Calculate ends_at based on membership_type before validation
  before_validation :calculate_ends_at, if: -> { starts_at.present? && ends_at.blank? }

  # ===========================================================================
  # SCOPES
  # ===========================================================================

  # Active memberships (current time is within the validity period)
  scope :active, lambda {
    where('starts_at <= ? AND ends_at > ?', Time.current, Time.current)
  }

  # Expired memberships
  scope :expired, lambda {
    where('ends_at <= ?', Time.current)
  }

  # Future memberships (not yet started)
  scope :future, lambda {
    where('starts_at > ?', Time.current)
  }

  # Memberships expiring soon (within X days)
  scope :expiring_soon, lambda { |days = 7|
    active.where('ends_at <= ?', days.days.from_now)
  }

  # ===========================================================================
  # CLASS METHODS
  # ===========================================================================

  # Get the duration for a membership type
  def self.duration_for(type)
    case type.to_sym
    when :day_pass then 1.day
    when :weekly then 7.days
    when :monthly then 30.days
    else 1.day
    end
  end

  # Get pricing for a membership type and tier (example implementation)
  def self.price_for(type:, tier:)
    # This would typically come from a pricing table or configuration
    base_prices = {
      day_pass: 25,
      weekly: 150,
      monthly: 400
    }

    tier_multiplier = tier.to_sym == :premium ? 1.5 : 1.0

    (base_prices[type.to_sym] * tier_multiplier).round(2)
  end

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================

  # Check if membership is currently active
  def active?
    starts_at <= Time.current && ends_at > Time.current
  end

  # Check if membership has expired
  def expired?
    ends_at <= Time.current
  end

  # Check if membership hasn't started yet
  def future?
    starts_at > Time.current
  end

  # Get the duration of this membership in days
  def duration_days
    ((ends_at - starts_at) / 1.day).to_i
  end

  # Get the remaining days
  def remaining_days
    return 0 if expired?
    return duration_days if future?

    ((ends_at - Time.current) / 1.day).ceil
  end

  # Check if membership is expiring soon
  def expiring_soon?(within_days: 7)
    active? && ends_at <= within_days.days.from_now
  end

  # Get the calculated price for this membership
  def price
    self.class.price_for(type: membership_type, tier: amenity_tier)
  end

  # Check if this membership allows booking a specific workspace
  def can_book_workspace?(workspace)
    # Premium tier can book any workspace
    return true if amenity_tier_premium?

    # Basic tier can only book basic amenity workspaces
    workspace.amenity_tier_basic?
  end

  # Extend the membership by its standard duration
  def extend!
    new_ends_at = ends_at + self.class.duration_for(membership_type)
    update!(ends_at: new_ends_at)
  end

  private

  # ===========================================================================
  # PRIVATE VALIDATION METHODS
  # ===========================================================================

  # Ensure ends_at is after starts_at
  def ends_at_after_starts_at
    return unless starts_at && ends_at

    if ends_at <= starts_at
      errors.add(:ends_at, 'must be after starts_at')
    end
  end

  # Prevent overlapping memberships for the same user
  def no_overlapping_memberships
    return unless user && starts_at && ends_at

    # Find memberships that overlap with this one
    overlapping = user.memberships
                      .where('starts_at < ? AND ends_at > ?', ends_at, starts_at)

    if overlapping.exists?
      errors.add(:base, 'User already has an active membership during this period')
    end
  end

  # Calculate ends_at based on membership type
  def calculate_ends_at
    return unless starts_at

    self.ends_at = starts_at + self.class.duration_for(membership_type)
  end
end
