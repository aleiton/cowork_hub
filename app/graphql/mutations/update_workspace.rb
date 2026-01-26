# frozen_string_literal: true

# =============================================================================
# UPDATE WORKSPACE MUTATION
# =============================================================================
#
# Updates an existing workspace. Admin only.
#
# BUSINESS RULES:
# 1. Only admins can update workspaces
# 2. Only provided fields are updated (partial update)
# 3. Changing workspace type may affect equipment
#
# =============================================================================

module Mutations
  class UpdateWorkspace < BaseMutation
    description 'Update an existing workspace (admin only)'

    # =========================================================================
    # INPUT ARGUMENTS
    # =========================================================================

    argument :id, ID, required: true,
                      description: 'ID of the workspace to update'

    argument :name, String, required: false,
                            description: 'New workspace name'

    argument :description, String, required: false,
                                   description: 'New workspace description'

    argument :workspace_type, Types::WorkspaceTypeEnum, required: false,
                                                        description: 'New type of workspace'

    argument :capacity, Integer, required: false,
                                 description: 'New maximum occupancy'

    argument :hourly_rate, Float, required: false,
                                  description: 'New price per hour'

    argument :amenity_tier, Types::AmenityTierEnum, required: false,
                                                    description: 'New amenity tier'

    # =========================================================================
    # OUTPUT FIELDS
    # =========================================================================

    field :workspace, Types::WorkspaceType, null: true,
                                            description: 'The updated workspace'

    field :errors, [String], null: false,
                             description: 'Error messages if update failed'

    # =========================================================================
    # RESOLVER
    # =========================================================================

    def resolve(id:, **attributes)
      # Step 1: Require admin role
      require_admin!

      # Step 2: Find the workspace
      workspace = Workspace.find_by(id: id)
      return error_response('Workspace not found') unless workspace

      # Step 3: Authorize the action
      authorize(workspace, :update)

      # Step 4: Filter out nil values (only update provided fields)
      updates = attributes.compact

      return success_response(:workspace, workspace) if updates.empty?

      # Step 5: Update and return response
      if workspace.update(updates)
        success_response(:workspace, workspace)
      else
        { workspace: nil, errors: format_errors(workspace) }
      end
    end
  end
end
