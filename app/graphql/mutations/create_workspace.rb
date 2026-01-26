# frozen_string_literal: true

# =============================================================================
# CREATE WORKSPACE MUTATION
# =============================================================================
#
# Creates a new workspace. Admin only.
#
# BUSINESS RULES:
# 1. Only admins can create workspaces
# 2. All required fields must be provided
# 3. For workshops, equipment can be added separately
#
# =============================================================================

module Mutations
  class CreateWorkspace < BaseMutation
    description 'Create a new workspace (admin only)'

    # =========================================================================
    # INPUT ARGUMENTS
    # =========================================================================

    argument :name, String, required: true,
                            description: 'Workspace name'

    argument :description, String, required: false,
                                   description: 'Workspace description'

    argument :workspace_type, Types::WorkspaceTypeEnum, required: true,
                                                        description: 'Type of workspace'

    argument :capacity, Integer, required: true,
                                 description: 'Maximum occupancy'

    argument :hourly_rate, Float, required: true,
                                  description: 'Price per hour'

    argument :amenity_tier, Types::AmenityTierEnum, required: true,
                                                    description: 'Amenity tier'

    # =========================================================================
    # OUTPUT FIELDS
    # =========================================================================

    field :workspace, Types::WorkspaceType, null: true,
                                            description: 'The created workspace'

    field :errors, [String], null: false,
                             description: 'Error messages if creation failed'

    # =========================================================================
    # RESOLVER
    # =========================================================================

    def resolve(name:, workspace_type:, capacity:, hourly_rate:, amenity_tier:, description: nil)
      # Step 1: Require admin role
      require_admin!

      # Step 2: Create the workspace
      workspace = Workspace.new(
        name: name,
        description: description,
        workspace_type: workspace_type,
        capacity: capacity,
        hourly_rate: hourly_rate,
        amenity_tier: amenity_tier
      )

      # Step 3: Authorize the action
      authorize(workspace, :create)

      # Step 4: Save and return response
      if workspace.save
        success_response(:workspace, workspace)
      else
        { workspace: nil, errors: format_errors(workspace) }
      end
    end
  end
end
