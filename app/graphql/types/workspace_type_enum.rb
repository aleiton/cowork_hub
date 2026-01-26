# frozen_string_literal: true

# =============================================================================
# WORKSPACE TYPE ENUM
# =============================================================================
#
# Types of workspaces available in the coworking space.
#
# =============================================================================

module Types
  class WorkspaceTypeEnum < BaseEnum
    description 'Type of workspace'

    value 'DESK', 'Hot desk in open area', value: 'desk'
    value 'PRIVATE_OFFICE', 'Private enclosed office', value: 'private_office'
    value 'MEETING_ROOM', 'Conference/meeting room', value: 'meeting_room'
    value 'WORKSHOP', 'Maker space with specialized equipment', value: 'workshop'
  end
end
