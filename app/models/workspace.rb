# frozen_string_literal: true

# =============================================================================
# WORKSPACE MODEL
# =============================================================================
#
# Workspaces are the bookable spaces in our coworking facility.
# They range from simple hot desks to fully equipped maker workshops.
#
# WORKSPACE TYPES:
# - desk: Hot desks in open area (drop-in workstations)
# - private_office: Enclosed office for focused work or small teams
# - meeting_room: Conference rooms for meetings and calls
# - workshop: Maker spaces with specialized equipment
#
# AMENITY TIERS:
# - basic: Standard amenities (wifi, coffee, water)
# - premium: Enhanced amenities (snacks, printing, phone booths, priority)
#
# =============================================================================
# == Schema Information
#
# Table name: workspaces
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  description    :text
#  workspace_type :integer          default("desk"), not null
#  capacity       :integer          default(1), not null
#  hourly_rate    :decimal(10, 2)   not null
#  amenity_tier   :integer          default("basic"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# =============================================================================

class Workspace < ApplicationRecord
  # ===========================================================================
  # RELATIONSHIPS
  # ===========================================================================

  # A workspace can have many bookings
  has_many :bookings, dependent: :destroy

  # Workshop equipment only exists for workshop-type workspaces
  # dependent: :destroy removes equipment if workspace is deleted
  has_many :workshop_equipments, dependent: :destroy

  # Get users who have booked this workspace (through bookings)
  has_many :users, through: :bookings

  # ===========================================================================
  # ENUMS
  # ===========================================================================

  # Workspace types with their integer representations
  enum :workspace_type, {
    desk: 0,           # Hot desk in open area
    private_office: 1, # Private enclosed office
    meeting_room: 2,   # Conference/meeting room
    workshop: 3        # Maker space with equipment
  }, prefix: true

  # Amenity tier determines what extras are included
  enum :amenity_tier, {
    basic: 0,   # Standard: wifi, coffee, water
    premium: 1  # Premium: all basic + snacks, printing, phone booths
  }, prefix: true

  # ===========================================================================
  # RANSACK CONFIGURATION (for ActiveAdmin search/filters)
  # ===========================================================================
  def self.ransackable_attributes(auth_object = nil)
    %w[id name description workspace_type capacity hourly_rate amenity_tier created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[bookings workshop_equipments users]
  end

  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================

  validates :name, presence: true, length: { maximum: 100 }

  validates :description, length: { maximum: 1000 }

  validates :workspace_type, presence: true

  # Capacity must be at least 1
  validates :capacity, presence: true,
                       numericality: { only_integer: true, greater_than: 0, less_than: 100 }

  # Hourly rate must be positive
  # greater_than_or_equal_to: 0 allows free spaces if needed
  validates :hourly_rate, presence: true,
                          numericality: { greater_than_or_equal_to: 0, less_than: 10_000 }

  validates :amenity_tier, presence: true

  # Custom validation: workshops should have equipment
  # This is a soft validation (warning) - workshops CAN exist without equipment
  validate :workshops_should_have_equipment, on: :update

  # ===========================================================================
  # SCOPES
  # ===========================================================================

  # Filter by workspace type
  # Usage: Workspace.desks, Workspace.workshops
  # Note: These are automatically created by the enum declaration above
  # scope :desk, -> { where(workspace_type: :desk) }

  # Filter by amenity tier
  # Usage: Workspace.premium, Workspace.basic
  # Also auto-created by enum

  # Find workspaces available on a specific date and time range
  # This is complex enough to warrant a class method instead of a scope
  scope :available_on, lambda { |date, start_time, end_time|
    # Find workspaces that DON'T have conflicting bookings
    #
    # A booking conflicts if:
    # - Same date AND
    # - Time ranges overlap
    #
    # Time ranges overlap if: start1 < end2 AND start2 < end1

    conflicting_bookings = Booking
                           .where(date: date)
                           .where(status: %i[pending confirmed])
                           .where(
                             'start_time < ? AND end_time > ?',
                             end_time, start_time
                           )

    where.not(id: conflicting_bookings.select(:workspace_id))
  }

  # Order by hourly rate
  scope :by_price, ->(direction = :asc) { order(hourly_rate: direction) }

  # Workspaces with available capacity (for future features)
  scope :with_capacity_for, ->(people) { where('capacity >= ?', people) }

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================

  # Check if this is a workshop (has/needs equipment)
  def workshop?
    workspace_type_workshop?
  end

  # Get all available equipment for this workspace
  def available_equipment
    return [] unless workshop?

    workshop_equipments
  end

  # Check if workspace is available at a specific time
  def available_at?(date:, start_time:, end_time:)
    # Look for conflicting bookings
    conflicting = bookings
                  .where(date: date)
                  .where(status: %i[pending confirmed])
                  .where(
                    'start_time < ? AND end_time > ?',
                    end_time, start_time
                  )

    conflicting.none?
  end

  # Calculate price for a time range
  def calculate_price(start_time:, end_time:)
    # Calculate duration in hours
    # Time objects in Rails can be subtracted to get seconds
    duration_seconds = end_time - start_time
    duration_hours = duration_seconds / 3600.0

    # Round up to nearest 30 minutes (business rule)
    duration_hours = (duration_hours * 2).ceil / 2.0

    (hourly_rate * duration_hours).round(2)
  end

  # Get a summary of recent bookings
  def recent_bookings_count(days: 30)
    bookings.where('date >= ?', days.days.ago.to_date).count
  end

  private

  # Soft validation: warn if workshop has no equipment
  def workshops_should_have_equipment
    return unless workspace_type_workshop? && workshop_equipments.empty?

    # Using errors.add with :base applies to the whole record
    # This doesn't prevent saving, just adds a warning
    Rails.logger.warn("Workspace #{id} is a workshop but has no equipment")
  end
end
