// =============================================================================
// BOOKING MUTATIONS
// =============================================================================
//
// GraphQL mutations for booking operations.
//
// MUTATION vs QUERY:
// - Queries are for reading data (GET in REST)
// - Mutations are for writing/changing data (POST/PUT/DELETE in REST)
//
// MUTATION STRUCTURE:
// 1. Define input variables
// 2. Call the mutation field
// 3. Return both the result AND errors array
//    (This pattern allows for partial success and detailed error messages)
//
// =============================================================================

import { gql } from "@apollo/client";

// -----------------------------------------------------------------------------
// CREATE BOOKING
// -----------------------------------------------------------------------------
// Creates a new booking for a workspace.
// Validates: no double-booking, valid times, equipment availability

export const CREATE_BOOKING = gql`
  mutation CreateBooking(
    $workspaceId: ID!
    $date: ISO8601Date!
    $startTime: String!
    $endTime: String!
    $equipmentIds: [ID!]
  ) {
    createBooking(
      input: {
        workspaceId: $workspaceId
        date: $date
        startTime: $startTime
        endTime: $endTime
        equipmentIds: $equipmentIds
      }
    ) {
      booking {
        id
        date
        startTime
        endTime
        status
        calculatedPrice
        workspace {
          id
          name
        }
      }
      errors
    }
  }
`;

// -----------------------------------------------------------------------------
// CANCEL BOOKING
// -----------------------------------------------------------------------------
// Cancels an existing booking.
// Only the booking owner or admin can cancel.

export const CANCEL_BOOKING = gql`
  mutation CancelBooking($id: ID!) {
    cancelBooking(input: { id: $id }) {
      booking {
        id
        status
      }
      errors
    }
  }
`;

// -----------------------------------------------------------------------------
// CONFIRM BOOKING (Admin only)
// -----------------------------------------------------------------------------
// Confirms a pending booking.

export const CONFIRM_BOOKING = gql`
  mutation ConfirmBooking($id: ID!) {
    confirmBooking(input: { id: $id }) {
      booking {
        id
        status
      }
      errors
    }
  }
`;
