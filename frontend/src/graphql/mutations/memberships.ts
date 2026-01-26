// =============================================================================
// MEMBERSHIP & CANTINA MUTATIONS
// =============================================================================

import { gql } from "@apollo/client";

// -----------------------------------------------------------------------------
// CREATE MEMBERSHIP
// -----------------------------------------------------------------------------
// Creates a new membership for the current user.
// Validates: no overlapping memberships

export const CREATE_MEMBERSHIP = gql`
  mutation CreateMembership(
    $membershipType: MembershipTypeEnum!
    $amenityTier: AmenityTierEnum!
  ) {
    createMembership(
      membershipType: $membershipType
      amenityTier: $amenityTier
    ) {
      membership {
        id
        membershipType
        amenityTier
        startsAt
        endsAt
        daysRemaining
      }
      errors
    }
  }
`;

// -----------------------------------------------------------------------------
// CREATE CANTINA SUBSCRIPTION
// -----------------------------------------------------------------------------
// Creates a cafeteria meal subscription.

export const CREATE_CANTINA_SUBSCRIPTION = gql`
  mutation CreateCantinaSubscription($planType: CantinaPlanTypeEnum!) {
    createCantinaSubscription(planType: $planType) {
      cantinaSubscription {
        id
        planType
        mealsRemaining
        renewsAt
      }
      errors
    }
  }
`;

// -----------------------------------------------------------------------------
// USE CANTINA CREDIT
// -----------------------------------------------------------------------------
// Consumes one meal credit from the subscription.
// Uses atomic decrement to prevent race conditions.

export const USE_CANTINA_CREDIT = gql`
  mutation UseCantinaCredit {
    useCantinaCredit {
      cantinaSubscription {
        id
        mealsRemaining
      }
      errors
    }
  }
`;
