# frozen_string_literal: true

# =============================================================================
# QUERY TYPE
# =============================================================================
#
# The QueryType defines all read operations (queries) in the GraphQL API.
# These are equivalent to GET requests in REST.
#
# QUERIES ARE:
# - Read-only: They never modify data
# - Cacheable: Results can be cached
# - Parallelizable: Multiple queries can run simultaneously
#
# QUERY EXAMPLES:
# query {
#   workspaces(type: WORKSHOP) {
#     id
#     name
#     equipment { name }
#   }
# }
#
# query {
#   me {
#     email
#     currentMembership { membershipType }
#   }
# }
#
# =============================================================================

module Types
  class QueryType < BaseObject
    description 'The query root of the CoworkHub schema'

    # =========================================================================
    # WORKSPACE QUERIES
    # =========================================================================

    # List all workspaces with optional filters
    field :workspaces, [WorkspaceType], null: false,
                                        description: 'List all workspaces with optional filters' do
      argument :workspace_type, WorkspaceTypeEnum, required: false,
                                                   description: 'Filter by workspace type'
      argument :amenity_tier, AmenityTierEnum, required: false,
                                               description: 'Filter by amenity tier'
      argument :available_on, GraphQL::Types::ISO8601Date, required: false,
                                                           description: 'Filter by availability on date'
      argument :start_time, String, required: false,
                                    description: 'Start time for availability check (HH:MM)'
      argument :end_time, String, required: false,
                                  description: 'End time for availability check (HH:MM)'
      argument :min_capacity, Integer, required: false,
                                       description: 'Minimum capacity required'
    end

    def workspaces(workspace_type: nil, amenity_tier: nil, available_on: nil,
                   start_time: nil, end_time: nil, min_capacity: nil)
      # Start with all workspaces
      scope = Workspace.all

      # Apply filters
      scope = scope.where(workspace_type: workspace_type) if workspace_type
      scope = scope.where(amenity_tier: amenity_tier) if amenity_tier
      scope = scope.with_capacity_for(min_capacity) if min_capacity

      # Availability filter requires date and times
      if available_on && start_time && end_time
        start_t = Time.zone.parse("#{available_on} #{start_time}")
        end_t = Time.zone.parse("#{available_on} #{end_time}")
        scope = scope.available_on(available_on, start_t, end_t)
      end

      scope.order(:name)
    end

    # Get a single workspace by ID
    field :workspace, WorkspaceType, null: true,
                                     description: 'Find a workspace by ID' do
      argument :id, ID, required: true
    end

    def workspace(id:)
      Workspace.find_by(id: id)
    end

    # =========================================================================
    # USER QUERIES
    # =========================================================================

    # Get the current authenticated user
    field :me, UserType, null: true, description: 'The currently authenticated user'

    def me
      # current_user is set in the GraphQL context by the controller
      current_user
    end

    # =========================================================================
    # BOOKING QUERIES
    # =========================================================================

    # Get current user's bookings
    field :my_bookings, [BookingType], null: false,
                                       description: "Current user's bookings" do
      argument :status, BookingStatusEnum, required: false
      argument :upcoming_only, Boolean, required: false, default_value: false
      argument :workspace_id, ID, required: false
    end

    def my_bookings(status: nil, upcoming_only: false, workspace_id: nil)
      # Require authentication
      raise GraphQL::ExecutionError, 'You must be logged in' unless current_user

      scope = current_user.bookings.includes(:workspace)

      scope = scope.where(status: status) if status
      scope = scope.upcoming if upcoming_only
      scope = scope.where(workspace_id: workspace_id) if workspace_id

      scope.order(date: :desc, start_time: :desc)
    end

    # Get a single booking by ID
    field :booking, BookingType, null: true,
                                 description: 'Find a booking by ID' do
      argument :id, ID, required: true
    end

    def booking(id:)
      booking = Booking.find_by(id: id)
      return nil unless booking

      # Only allow users to see their own bookings (or admins)
      if current_user && (booking.user_id == current_user.id || current_user.role_admin?)
        booking
      end
    end

    # =========================================================================
    # MEMBERSHIP QUERIES
    # =========================================================================

    # Get current user's memberships
    field :my_memberships, [MembershipType], null: false,
                                             description: "Current user's memberships" do
      argument :active_only, Boolean, required: false, default_value: false
    end

    def my_memberships(active_only: false)
      raise GraphQL::ExecutionError, 'You must be logged in' unless current_user

      scope = current_user.memberships

      scope = scope.active if active_only

      scope.order(starts_at: :desc)
    end

    # Get current user's active membership
    field :my_current_membership, MembershipType, null: true,
                                                  description: "Current user's active membership"

    def my_current_membership
      raise GraphQL::ExecutionError, 'You must be logged in' unless current_user

      current_user.current_membership
    end

    # =========================================================================
    # CANTINA SUBSCRIPTION QUERIES
    # =========================================================================

    # Get current user's cantina subscription
    field :my_cantina_subscription, CantinaSubscriptionType, null: true,
                                                             description: "Current user's cafeteria subscription"

    def my_cantina_subscription
      raise GraphQL::ExecutionError, 'You must be logged in' unless current_user

      current_user.active_cantina_subscription
    end

    # =========================================================================
    # EQUIPMENT QUERIES
    # =========================================================================

    # List all equipment (optionally filtered by workspace)
    field :equipment, [WorkshopEquipmentType], null: false,
                                               description: 'List workshop equipment' do
      argument :workspace_id, ID, required: false
      argument :available_only, Boolean, required: false, default_value: false
    end

    def equipment(workspace_id: nil, available_only: false)
      scope = WorkshopEquipment.includes(:workspace)

      scope = scope.where(workspace_id: workspace_id) if workspace_id
      scope = scope.available if available_only

      scope.alphabetical
    end
  end
end
