# frozen_string_literal: true

# =============================================================================
# BOOKING TYPE
# =============================================================================
#
# GraphQL type representing a workspace reservation.
#
# =============================================================================

module Types
  class BookingType < BaseObject
    description 'A workspace booking/reservation'

    # =========================================================================
    # BASIC FIELDS
    # =========================================================================

    field :id, ID, null: false, description: 'Unique identifier'

    field :date, GraphQL::Types::ISO8601Date, null: false,
                                              description: 'Date of the booking'

    field :start_time, String, null: false, description: 'Start time (HH:MM)'

    def start_time
      object.start_time.strftime('%H:%M')
    end

    field :end_time, String, null: false, description: 'End time (HH:MM)'

    def end_time
      object.end_time.strftime('%H:%M')
    end

    field :status, BookingStatusEnum, null: false, description: 'Booking status'

    field :equipment_used, [ID], null: false,
                                 description: 'IDs of equipment reserved'

    # =========================================================================
    # COMPUTED FIELDS
    # =========================================================================

    field :duration_hours, Float, null: false,
                                  description: 'Duration in hours'

    def duration_hours
      object.duration_hours
    end

    field :duration_minutes, Integer, null: false,
                                      description: 'Duration in minutes'

    def duration_minutes
      object.duration_minutes
    end

    field :calculated_price, Float, null: false,
                                    description: 'Calculated price for this booking'

    def calculated_price
      object.calculated_price
    end

    field :is_cancellable, Boolean, null: false,
                                    description: 'Whether booking can be cancelled'

    def is_cancellable
      object.cancellable?
    end

    field :starts_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                       description: 'Full start datetime'

    def starts_at
      object.starts_at
    end

    field :ends_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                     description: 'Full end datetime'

    def ends_at
      object.ends_at
    end

    # =========================================================================
    # RELATIONSHIPS
    # =========================================================================

    field :workspace, WorkspaceType, null: false,
                                     description: 'The booked workspace'

    def workspace
      # Use loader to prevent N+1 when fetching multiple bookings
      Loaders::RecordLoader.for(Workspace).load(object.workspace_id)
    end

    field :user, UserType, null: false, description: 'The user who made the booking'

    def user
      Loaders::RecordLoader.for(User).load(object.user_id)
    end

    # Get the equipment objects for equipment_used IDs
    field :reserved_equipment, [WorkshopEquipmentType], null: false,
                                                        description: 'Reserved equipment objects'

    def reserved_equipment
      return [] if object.equipment_used.blank?

      # Batch load all equipment IDs
      Loaders::RecordLoader.for(WorkshopEquipment).load_many(object.equipment_used)
    end

    # =========================================================================
    # TIMESTAMPS
    # =========================================================================

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
