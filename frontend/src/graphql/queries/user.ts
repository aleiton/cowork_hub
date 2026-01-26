// =============================================================================
// USER QUERIES
// =============================================================================
//
// Queries related to the authenticated user.
// These require a valid JWT token in the Authorization header.
//
// =============================================================================

import { gql } from "@apollo/client";

// -----------------------------------------------------------------------------
// GET CURRENT USER
// -----------------------------------------------------------------------------
// Fetches the currently authenticated user's profile.
// Returns null if not authenticated.
// Used to check auth status and display user info.

export const GET_ME = gql`
  query GetMe {
    me {
      id
      email
      role
      createdAt
    }
  }
`;

// -----------------------------------------------------------------------------
// GET CURRENT USER WITH MEMBERSHIP
// -----------------------------------------------------------------------------
// Fetches user with their active membership details.
// Used on the dashboard/profile page.

export const GET_ME_WITH_MEMBERSHIP = gql`
  query GetMeWithMembership {
    me {
      id
      email
      role
    }
    myCurrentMembership {
      id
      membershipType
      amenityTier
      startsAt
      endsAt
      active
      daysRemaining
    }
    myCantinaSubscription {
      id
      planType
      mealsRemaining
      renewsAt
      active
    }
  }
`;

// -----------------------------------------------------------------------------
// GET USER BOOKINGS
// -----------------------------------------------------------------------------
// Fetches the current user's bookings with optional filters.

export const GET_MY_BOOKINGS = gql`
  query GetMyBookings($status: BookingStatusEnum, $upcomingOnly: Boolean) {
    myBookings(status: $status, upcomingOnly: $upcomingOnly) {
      id
      date
      startTime
      endTime
      status
      equipmentUsed
      totalCost
      durationHours
      workspace {
        id
        name
        workspaceType
      }
    }
  }
`;

// -----------------------------------------------------------------------------
// GET USER MEMBERSHIPS
// -----------------------------------------------------------------------------
// Fetches all memberships (current and past) for the user.

export const GET_MY_MEMBERSHIPS = gql`
  query GetMyMemberships($activeOnly: Boolean) {
    myMemberships(activeOnly: $activeOnly) {
      id
      membershipType
      amenityTier
      startsAt
      endsAt
      active
      daysRemaining
    }
  }
`;
