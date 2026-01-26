# frozen_string_literal: true

# =============================================================================
# WORKSHOP EQUIPMENT MODEL
# =============================================================================
#
# WorkshopEquipment represents specialized tools and machines available
# in workshop-type workspaces.
#
# EXAMPLES:
# - 3D Printers (Prusa, Creality)
# - Sewing machines
# - Laser cutters
# - CNC machines
# - Woodworking tools
# - Tattooing equipment
#
# BUSINESS RULES:
# - Equipment belongs to a specific workspace (can't move between workshops)
# - quantity_available tracks how many units exist
# - Users book equipment as part of a workspace booking
# - Equipment availability is tracked per booking
#
# =============================================================================
# == Schema Information
#
# Table name: workshop_equipments
#
#  id                 :bigint           not null, primary key
#  workspace_id       :bigint           not null
#  name               :string           not null
#  description        :text
#  quantity_available :integer          default(1), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# =============================================================================

class WorkshopEquipment < ApplicationRecord
  # ===========================================================================
  # RELATIONSHIPS
  # ===========================================================================

  # Equipment belongs to one workspace (the workshop it's located in)
  #
  # belongs_to creates the association and:
  # - Adds workspace and workspace= methods
  # - Adds workspace_id attribute
  # - By default, requires the workspace to exist (optional: false is default)
  belongs_to :workspace

  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================

  validates :name, presence: true, length: { maximum: 100 }

  validates :description, length: { maximum: 1000 }

  # Must have at least 1 unit available
  validates :quantity_available,
            presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than: 100 }

  # Ensure the parent workspace is a workshop type
  validate :workspace_must_be_workshop

  # ===========================================================================
  # SCOPES
  # ===========================================================================

  # Find equipment with available units
  scope :available, -> { where('quantity_available > 0') }

  # Search equipment by name
  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") }

  # Order alphabetically
  scope :alphabetical, -> { order(:name) }

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================

  # Check if equipment has units available
  def available?
    quantity_available.positive?
  end

  # Get the number of units currently reserved (booked) for a time slot
  # This queries the bookings table's equipment_used JSONB field
  def reserved_count_at(date:, start_time:, end_time:)
    # Find bookings that:
    # 1. Are for this equipment's workspace
    # 2. Overlap with the requested time
    # 3. Include this equipment in equipment_used
    # 4. Are active (pending or confirmed)

    conflicting_bookings = Booking
                           .where(workspace_id: workspace_id)
                           .where(date: date)
                           .where(status: %i[pending confirmed])
                           .where('start_time < ? AND end_time > ?', end_time, start_time)

    # Count how many times this equipment appears in those bookings
    # PostgreSQL JSONB query: check if array contains this ID
    conflicting_bookings
      .where('equipment_used @> ?', [id].to_json)
      .count
  end

  # Check if equipment is available at a specific time
  def available_at?(date:, start_time:, end_time:)
    reserved = reserved_count_at(date: date, start_time: start_time, end_time: end_time)
    reserved < quantity_available
  end

  # Get available quantity at a specific time
  def available_quantity_at(date:, start_time:, end_time:)
    reserved = reserved_count_at(date: date, start_time: start_time, end_time: end_time)
    [quantity_available - reserved, 0].max
  end

  private

  # Custom validation: equipment can only belong to workshop-type workspaces
  def workspace_must_be_workshop
    return if workspace.nil? # Let presence validation handle this

    unless workspace.workspace_type_workshop?
      errors.add(:workspace, 'must be a workshop type to have equipment')
    end
  end
end
