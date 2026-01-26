# frozen_string_literal: true

# =============================================================================
# BASE ENUM
# =============================================================================
#
# Enums in GraphQL represent a fixed set of values.
# They're useful for fields that can only have specific values.
#
# EXAMPLE:
# enum WorkspaceType {
#   DESK
#   PRIVATE_OFFICE
#   MEETING_ROOM
#   WORKSHOP
# }
#
# This ensures the client can only send valid values and gets
# autocompletion in GraphQL clients.
#
# =============================================================================

module Types
  class BaseEnum < GraphQL::Schema::Enum
  end
end
