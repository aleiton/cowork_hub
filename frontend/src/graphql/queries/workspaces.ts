// =============================================================================
// WORKSPACE QUERIES
// =============================================================================
//
// GraphQL queries for fetching workspace data.
//
// QUERY STRUCTURE:
// - Define the query using gql template tag
// - Specify exactly which fields you need (no over-fetching!)
// - Use variables ($name) for dynamic values
// - Fragment can be used to reuse field selections (not shown here for simplicity)
//
// =============================================================================

import { gql } from "@apollo/client";

// -----------------------------------------------------------------------------
// GET ALL WORKSPACES
// -----------------------------------------------------------------------------
// Fetches workspaces with optional filters.
// Used on the main workspaces listing page.

export const GET_WORKSPACES = gql`
  query GetWorkspaces(
    $workspaceType: WorkspaceTypeEnum
    $amenityTier: AmenityTierEnum
    $minCapacity: Int
  ) {
    workspaces(
      workspaceType: $workspaceType
      amenityTier: $amenityTier
      minCapacity: $minCapacity
    ) {
      id
      name
      description
      workspaceType
      capacity
      hourlyRate
      amenityTier
    }
  }
`;

// -----------------------------------------------------------------------------
// GET SINGLE WORKSPACE
// -----------------------------------------------------------------------------
// Fetches a single workspace with its equipment.
// Used on the workspace detail page.

export const GET_WORKSPACE = gql`
  query GetWorkspace($id: ID!) {
    workspace(id: $id) {
      id
      name
      description
      workspaceType
      capacity
      hourlyRate
      amenityTier
      equipment {
        id
        name
        description
        quantityAvailable
      }
    }
  }
`;

// -----------------------------------------------------------------------------
// GET WORKSHOPS WITH EQUIPMENT
// -----------------------------------------------------------------------------
// Specifically fetches workshop-type spaces with their equipment.
// Used on the maker space / workshop page.

export const GET_WORKSHOPS = gql`
  query GetWorkshops {
    workspaces(workspaceType: WORKSHOP) {
      id
      name
      description
      capacity
      hourlyRate
      amenityTier
      equipment {
        id
        name
        quantityAvailable
      }
    }
  }
`;

// -----------------------------------------------------------------------------
// GET EQUIPMENT
// -----------------------------------------------------------------------------
// Fetches all equipment, optionally filtered by workspace.

export const GET_EQUIPMENT = gql`
  query GetEquipment($workspaceId: ID, $availableOnly: Boolean) {
    equipment(workspaceId: $workspaceId, availableOnly: $availableOnly) {
      id
      name
      description
      quantityAvailable
      workspace {
        id
        name
      }
    }
  }
`;
