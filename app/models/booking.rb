# frozen_string_literal: true

# =============================================================================
# BOOKING MODEL
# =============================================================================
#
# Bookings are the core transaction entity - they represent a user's
# reservation of a workspace for a specific time slot.
#
# KEY RESPONSIBILITIES:
# - Prevent double-booking (same workspace, overlapping times)
# - Track equipment usage for workshop bookings
# - Manage booking lifecycle (pending -> confirmed -> completed/cancelled)
# - Validate time ranges and business rules
#
# DESIGN DECISIONS:
# - Separate date from times for cleaner queries
# - Use JSONB for equipment_used (simpler than join table for our needs)
# - Status enum for clear lifecycle management
#
# =============================================================================
# == Schema Information
#
# Table name: bookings
#
#  id             :bigint           not null, primary key
#  workspace_id   :bigint           not null
#  user_id        :bigint           not null
#  date           :date             not null
#  start_time     :time             not null
#  end_time       :time             not null
#  status         :integer          default("pending"), not null
#  equipment_used :jsonb            default([])
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# =============================================================================

class Booking < ApplicationRecord
  # ===========================================================================
  # RELATIONSHIPS
  # ===========================================================================

  belongs_to :workspace
  belongs_to :user

  # ===========================================================================
  # ENUMS
  # ===========================================================================

  # Booking lifecycle statuses
  enum :status, {
    pending: 0,    # Awaiting confirmation or payment
    confirmed: 1,  # Active booking
    cancelled: 2,  # Cancelled by user or admin
    completed: 3   # Booking time has passed
  }, prefix: true

  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true

  # Custom validations for business logic
  validate :end_time_after_start_time
  validate :no_double_booking, on: :create
  validate :equipment_belongs_to_workspace
  validate :equipment_is_available, on: :create
  validate :date_not_in_past, on: :create

  # ===========================================================================
  # CALLBACKS
  # ===========================================================================

  # Set default status if not provided
  after_initialize :set_default_status, if: :new_record?

  # NOTE: Booking completion is handled by BookingCompletionJob (runs hourly)
  # See config/sidekiq.yml for schedule configuration

  # ===========================================================================
  # SCOPES
  # ===========================================================================

  # Active bookings (not cancelled or completed)
  scope :active, -> { where(status: %i[pending confirmed]) }

  # Confirmed bookings only
  scope :confirmed_only, -> { where(status: :confirmed) }

  # Bookings for a specific date
  scope :on_date, ->(date) { where(date: date) }

  # Bookings for today
  scope :today, -> { on_date(Date.current) }

  # Upcoming bookings (today or future, not cancelled)
  scope :upcoming, lambda {
    where('date >= ?', Date.current)
      .where.not(status: :cancelled)
      .order(:date, :start_time)
  }

  # Past bookings
  scope :past, -> { where('date < ?', Date.current) }

  # Bookings for a user
  scope :for_user, ->(user) { where(user: user) }

  # Bookings for a workspace
  scope :for_workspace, ->(workspace) { where(workspace: workspace) }

  # Find bookings that overlap with a time range
  # This is the core logic for preventing double-booking
  scope :overlapping, lambda { |date, start_time, end_time|
    where(date: date)
      .where('start_time < ? AND end_time > ?', end_time, start_time)
  }

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================

  # Duration in hours
  def duration_hours
    return 0 unless start_time && end_time

    (end_time - start_time) / 3600.0
  end

  # Duration in minutes
  def duration_minutes
    (duration_hours * 60).to_i
  end

  # Calculate the price based on workspace hourly rate
  def calculated_price
    return 0 unless workspace

    workspace.calculate_price(start_time: start_time, end_time: end_time)
  end

  # Check if booking can be cancelled
  def cancellable?
    !status_cancelled? && !status_completed? && date >= Date.current
  end

  # Cancel the booking
  def cancel!
    return false unless cancellable?

    update!(status: :cancelled)
  end

  # Confirm the booking
  def confirm!
    return false unless status_pending?

    update!(status: :confirmed)
  end

  # Get equipment objects from equipment_used IDs
  def reserved_equipment
    return [] if equipment_used.blank?

    WorkshopEquipment.where(id: equipment_used)
  end

  # Check if this booking uses specific equipment
  def uses_equipment?(equipment_id)
    equipment_used.include?(equipment_id)
  end

  # Add equipment to the booking
  def add_equipment(equipment_id)
    self.equipment_used = (equipment_used + [equipment_id]).uniq
  end

  # Remove equipment from the booking
  def remove_equipment(equipment_id)
    self.equipment_used = equipment_used - [equipment_id]
  end

  # Full datetime for start
  def starts_at
    return nil unless date && start_time

    DateTime.new(date.year, date.month, date.day,
                 start_time.hour, start_time.min, start_time.sec)
  end

  # Full datetime for end
  def ends_at
    return nil unless date && end_time

    DateTime.new(date.year, date.month, date.day,
                 end_time.hour, end_time.min, end_time.sec)
  end

  private

  # ===========================================================================
  # PRIVATE VALIDATION METHODS
  # ===========================================================================

  # Set default status for new bookings
  def set_default_status
    self.status ||= :pending
  end

  # Ensure end_time is after start_time
  def end_time_after_start_time
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, 'must be after start time')
    end
  end

  # Prevent bookings in the past
  def date_not_in_past
    return unless date

    if date < Date.current
      errors.add(:date, "can't be in the past")
    end
  end

  # Prevent double-booking: no overlapping active bookings for same workspace
  def no_double_booking
    return unless workspace && date && start_time && end_time

    # Find conflicting bookings
    conflicting = Booking
                  .where(workspace_id: workspace_id)
                  .active
                  .overlapping(date, start_time, end_time)

    # Exclude self if updating
    conflicting = conflicting.where.not(id: id) if persisted?

    if conflicting.exists?
      errors.add(:base, 'This workspace is already booked for the selected time')
    end
  end

  # Ensure all equipment IDs belong to the workspace
  def equipment_belongs_to_workspace
    return if equipment_used.blank?
    return unless workspace

    # Get IDs of equipment that belongs to this workspace
    valid_equipment_ids = workspace.workshop_equipments.pluck(:id)

    # Check if all requested equipment belongs to this workspace
    invalid_ids = equipment_used.map(&:to_i) - valid_equipment_ids

    if invalid_ids.any?
      errors.add(:equipment_used, 'contains equipment not available at this workspace')
    end
  end

  # Ensure all requested equipment is available at the booking time
  def equipment_is_available
    return if equipment_used.blank?
    return unless workspace && date && start_time && end_time

    unavailable_equipment.each do |equipment|
      errors.add(:equipment_used, "#{equipment.name} is not available at the selected time")
    end
  end

  # Find equipment that is not available at the booking time
  def unavailable_equipment
    WorkshopEquipment.where(id: equipment_used).reject do |equipment|
      equipment.available_at?(date: date, start_time: start_time, end_time: end_time)
    end
  end
end
