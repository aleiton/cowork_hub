// =============================================================================
// TYPESCRIPT TYPES
// =============================================================================
//
// These types mirror our GraphQL schema. In a production app, you'd generate
// these automatically from the schema using tools like:
// - graphql-codegen (most popular)
// - Apollo's built-in codegen
//
// For this project, we define them manually to understand the structure.
//
// =============================================================================

// -----------------------------------------------------------------------------
// ENUMS
// -----------------------------------------------------------------------------
// These match the GraphQL enums defined in the Rails backend

export type WorkspaceType = "DESK" | "PRIVATE_OFFICE" | "MEETING_ROOM" | "WORKSHOP";

export type AmenityTier = "BASIC" | "STANDARD" | "PREMIUM";

export type BookingStatus = "PENDING" | "CONFIRMED" | "CANCELLED" | "COMPLETED";

export type MembershipType = "DAY_PASS" | "WEEKLY" | "MONTHLY" | "ANNUAL";

export type UserRole = "GUEST" | "MEMBER" | "ADMIN";

export type CantinaPlanType = "LIGHT" | "STANDARD" | "UNLIMITED";

// -----------------------------------------------------------------------------
// MODELS
// -----------------------------------------------------------------------------

export interface User {
  id: string;
  email: string;
  role: UserRole;
  createdAt: string;
  // Relations
  currentMembership?: Membership;
  memberships?: Membership[];
  bookings?: Booking[];
  cantinaSubscription?: CantinaSubscription;
}

export interface Workspace {
  id: string;
  name: string;
  description?: string;
  workspaceType: WorkspaceType;
  capacity: number;
  hourlyRate: number;
  amenityTier: AmenityTier;
  createdAt: string;
  // Relations
  equipment?: WorkshopEquipment[];
  bookings?: Booking[];
}

export interface WorkshopEquipment {
  id: string;
  name: string;
  description?: string;
  quantityAvailable: number;
  // Relations
  workspace?: Workspace;
}

export interface Booking {
  id: string;
  date: string;
  startTime: string;
  endTime: string;
  status: BookingStatus;
  equipmentUsed: string[];
  createdAt: string;
  // Relations
  user?: User;
  workspace?: Workspace;
  // Computed
  totalCost?: number;
  durationHours?: number;
}

export interface Membership {
  id: string;
  membershipType: MembershipType;
  amenityTier: AmenityTier;
  startsAt: string;
  endsAt: string;
  createdAt: string;
  // Relations
  user?: User;
  // Computed
  active?: boolean;
  daysRemaining?: number;
}

export interface CantinaSubscription {
  id: string;
  planType: CantinaPlanType;
  mealsRemaining: number;
  renewsAt: string;
  createdAt: string;
  // Relations
  user?: User;
  // Computed
  active?: boolean;
}

// -----------------------------------------------------------------------------
// QUERY RESPONSE TYPES
// -----------------------------------------------------------------------------

export interface WorkspacesQueryResult {
  workspaces: Workspace[];
}

export interface WorkspaceQueryResult {
  workspace: Workspace | null;
}

export interface MeQueryResult {
  me: User | null;
}

export interface MyBookingsQueryResult {
  myBookings: Booking[];
}

// -----------------------------------------------------------------------------
// MUTATION INPUT TYPES
// -----------------------------------------------------------------------------

export interface CreateBookingInput {
  workspaceId: string;
  date: string;
  startTime: string;
  endTime: string;
  equipmentIds?: string[];
}

export interface CreateMembershipInput {
  membershipType: MembershipType;
  amenityTier: AmenityTier;
}

// -----------------------------------------------------------------------------
// MUTATION RESPONSE TYPES
// -----------------------------------------------------------------------------

export interface MutationResponse<T> {
  errors: string[];
  [key: string]: T | string[] | null;
}

export interface CreateBookingResponse {
  createBooking: {
    booking: Booking | null;
    errors: string[];
  };
}

export interface CancelBookingResponse {
  cancelBooking: {
    booking: Booking | null;
    errors: string[];
  };
}
