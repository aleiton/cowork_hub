# frozen_string_literal: true

# =============================================================================
# WORKSPACE TYPE
# =============================================================================
#
# GraphQL type representing a bookable workspace.
# Includes computed fields for availability and pricing.
#
# =============================================================================

module Types
  class WorkspaceType < BaseObject
    description 'A bookable workspace in the coworking facility'

    # =========================================================================
    # BASIC FIELDS
    # =========================================================================

    field :id, ID, null: false, description: 'Unique identifier'

    field :name, String, null: false, description: 'Workspace name'

    field :description, String, null: true, description: 'Detailed description'

    field :workspace_type, WorkspaceTypeEnum, null: false,
                                              description: 'Type of workspace'

    # Resolver needed because workspace_type is both the field name and model attribute
    def workspace_type
      object.workspace_type
    end

    field :capacity, Integer, null: false, description: 'Maximum occupancy'

    field :hourly_rate, Float, null: false, description: 'Price per hour'

    field :amenity_tier, AmenityTierEnum, null: false,
                                          description: 'Amenity tier included'

    # =========================================================================
    # COMPUTED FIELDS
    # =========================================================================

    field :is_workshop, Boolean, null: false,
                                 description: 'Whether this is a workshop with equipment'

    def is_workshop
      object.workshop?
    end

    # Check availability for a specific time slot
    field :is_available_at, Boolean, null: false,
                                     description: 'Check availability for a time slot' do
      argument :date, GraphQL::Types::ISO8601Date, required: true
      argument :start_time, String, required: true, description: 'Start time in HH:MM format'
      argument :end_time, String, required: true, description: 'End time in HH:MM format'
    end

    def is_available_at(date:, start_time:, end_time:)
      # Parse time strings to Time objects
      start_t = Time.zone.parse("#{date} #{start_time}")
      end_t = Time.zone.parse("#{date} #{end_time}")

      object.available_at?(date: date, start_time: start_t, end_time: end_t)
    end

    # Calculate price for a duration
    field :calculated_price, Float, null: false,
                                    description: 'Calculate price for a time range' do
      argument :start_time, String, required: true, description: 'Start time in HH:MM format'
      argument :end_time, String, required: true, description: 'End time in HH:MM format'
    end

    def calculated_price(start_time:, end_time:)
      # Parse time strings - using a reference date for calculation
      start_t = Time.zone.parse("2000-01-01 #{start_time}")
      end_t = Time.zone.parse("2000-01-01 #{end_time}")

      object.calculate_price(start_time: start_t, end_time: end_t)
    end

    # =========================================================================
    # RELATIONSHIPS
    # =========================================================================

    # Equipment available in this workspace (only for workshops)
    field :equipment, [WorkshopEquipmentType], null: false,
                                               description: 'Available equipment (workshops only)'

    def equipment
      return [] unless object.workshop?

      # Use AssociationLoader to prevent N+1 queries
      Loaders::AssociationLoader.for(Workspace, :workshop_equipments).load(object)
    end

    # Recent bookings for this workspace
    field :bookings, BookingType.connection_type, null: false,
                                                  description: 'Bookings for this workspace' do
      argument :from_date, GraphQL::Types::ISO8601Date, required: false,
                                                        description: 'Start date filter'
      argument :to_date, GraphQL::Types::ISO8601Date, required: false,
                                                      description: 'End date filter'
    end

    def bookings(from_date: nil, to_date: nil)
      scope = object.bookings.includes(:user)

      scope = scope.where('date >= ?', from_date) if from_date
      scope = scope.where('date <= ?', to_date) if to_date

      scope.order(date: :asc, start_time: :asc)
    end

    # =========================================================================
    # TIMESTAMPS
    # =========================================================================

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
