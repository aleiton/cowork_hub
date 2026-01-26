# frozen_string_literal: true

# =============================================================================
# CREATE BOOKING MUTATION
# =============================================================================
#
# Creates a new workspace booking for the current user.
#
# BUSINESS RULES:
# 1. User must be authenticated
# 2. Workspace must exist and be available at the requested time
# 3. For workshops, equipment must be available
# 4. Time range must be valid (start < end)
# 5. Can only book for future dates
# 6. Prevents double-booking (handled by model validation)
#
# EDGE CASES HANDLED:
# - Overlapping bookings: Rejected by model validation
# - Invalid equipment IDs: Validated against workspace
# - Past dates: Rejected by model validation
# - Invalid time format: Parsed with error handling
#
# =============================================================================

module Mutations
  class CreateBooking < BaseMutation
    description 'Create a new workspace booking'

    # =========================================================================
    # INPUT ARGUMENTS
    # =========================================================================

    argument :workspace_id, ID, required: true,
                                description: 'ID of the workspace to book'

    argument :date, GraphQL::Types::ISO8601Date, required: true,
                                                 description: 'Date of the booking'

    argument :start_time, String, required: true,
                                  description: 'Start time in HH:MM format'

    argument :end_time, String, required: true,
                                description: 'End time in HH:MM format'

    argument :equipment_ids, [ID], required: false,
                                   description: 'IDs of equipment to reserve (workshops only)'

    # =========================================================================
    # OUTPUT FIELDS
    # =========================================================================

    field :booking, Types::BookingType, null: true,
                                        description: 'The created booking'

    field :errors, [String], null: false,
                             description: 'Error messages if booking failed'

    # =========================================================================
    # RESOLVER
    # =========================================================================

    def resolve(workspace_id:, date:, start_time:, end_time:, equipment_ids: nil)
      # Step 1: Require authentication
      require_authentication!

      # Step 2: Find the workspace
      workspace = Workspace.find_by(id: workspace_id)
      return error_response('Workspace not found') unless workspace

      # Step 3: Parse time strings
      begin
        parsed_start = Time.zone.parse("#{date} #{start_time}")
        parsed_end = Time.zone.parse("#{date} #{end_time}")
      rescue ArgumentError => e
        return error_response("Invalid time format: #{e.message}")
      end

      # Step 4: Validate equipment (only for workshops)
      equipment_used = validate_equipment(workspace, equipment_ids, date, parsed_start, parsed_end)
      return equipment_used if equipment_used.is_a?(Hash) && equipment_used[:errors]

      # Step 5: Create the booking
      booking = Booking.new(
        user: current_user,
        workspace: workspace,
        date: date,
        start_time: parsed_start,
        end_time: parsed_end,
        equipment_used: equipment_used,
        status: :pending
      )

      # Step 6: Authorize the action (using Pundit)
      authorize(booking, :create)

      # Step 7: Save and return response
      if booking.save
        # Optionally trigger a background job for confirmation email
        # BookingConfirmationJob.perform_later(booking.id)

        success_response(:booking, booking)
      else
        { booking: nil, errors: format_errors(booking) }
      end
    end

    private

    # Validate and return equipment IDs for workshops
    def validate_equipment(workspace, equipment_ids, date, start_time, end_time)
      # No equipment needed for non-workshops
      return [] unless workspace.workshop?

      # No equipment requested
      return [] if equipment_ids.blank?

      # Validate each equipment
      equipment_ids.each do |eq_id|
        equipment = WorkshopEquipment.find_by(id: eq_id)

        # Equipment must exist
        unless equipment
          return error_response("Equipment with ID #{eq_id} not found")
        end

        # Equipment must belong to this workspace
        unless equipment.workspace_id == workspace.id
          return error_response("#{equipment.name} is not available at this workspace")
        end

        # Equipment must be available at the requested time
        unless equipment.available_at?(date: date, start_time: start_time, end_time: end_time)
          return error_response("#{equipment.name} is not available at the requested time")
        end
      end

      # Return validated equipment IDs as integers
      equipment_ids.map(&:to_i)
    end
  end
end
