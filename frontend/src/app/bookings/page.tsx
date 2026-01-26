// =============================================================================
// MY BOOKINGS PAGE
// =============================================================================
// Shows all bookings for the authenticated user with filtering options.

"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useMutation } from "@apollo/client/react";
import { GET_MY_BOOKINGS } from "@/graphql/queries/user";
import { CANCEL_BOOKING } from "@/graphql/mutations/bookings";
import { isAuthenticated } from "@/lib/apollo-client";
import { BookingStatus } from "@/types";
import { Select, Button, SkeletonCard, ErrorAlert, EmptyState } from "@/components/ui";
import { BookingCard, BookingData } from "@/components/bookings";

const statusOptions = [
  { value: "", label: "All" },
  { value: "PENDING", label: "Pending" },
  { value: "CONFIRMED", label: "Confirmed" },
  { value: "CANCELLED", label: "Cancelled" },
  { value: "COMPLETED", label: "Completed" },
];

export default function BookingsPage() {
  const router = useRouter();
  const [statusFilter, setStatusFilter] = useState<BookingStatus | "">("");
  const [showUpcomingOnly, setShowUpcomingOnly] = useState(false);

  // Auth check
  useEffect(() => {
    if (!isAuthenticated()) {
      router.push("/login");
    }
  }, [router]);

  // Fetch bookings
  const { data, loading, error, refetch } = useQuery(GET_MY_BOOKINGS, {
    variables: {
      status: statusFilter || undefined,
      upcomingOnly: showUpcomingOnly,
    },
    skip: typeof window === "undefined" || !isAuthenticated(),
  });

  // Cancel mutation
  const [cancelBooking, { loading: cancelling }] = useMutation(CANCEL_BOOKING, {
    onCompleted: () => refetch(),
  });

  const bookings: BookingData[] = data?.myBookings || [];
  const hasFilters = statusFilter || showUpcomingOnly;

  const handleCancel = async (bookingId: string) => {
    if (confirm("Are you sure you want to cancel this booking?")) {
      await cancelBooking({ variables: { id: bookingId } });
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="h-8 bg-gray-200 rounded w-1/4 mb-8 animate-pulse" />
        <div className="space-y-4">
          {[1, 2, 3].map((i) => <SkeletonCard key={i} />)}
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">My Bookings</h1>
          <p className="text-gray-600 mt-1">Manage your workspace reservations</p>
        </div>
        <Button href="/workspaces">+ New Booking</Button>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm p-4 mb-6 flex flex-wrap gap-4 items-end">
        <Select
          label="Status"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value as BookingStatus | "")}
          options={statusOptions}
          className="w-40"
        />
        <label className="flex items-center gap-2 cursor-pointer pb-2">
          <input
            type="checkbox"
            checked={showUpcomingOnly}
            onChange={(e) => setShowUpcomingOnly(e.target.checked)}
            className="rounded border-gray-300 text-indigo-600"
          />
          <span className="text-sm text-gray-700">Upcoming only</span>
        </label>
      </div>

      {/* Error */}
      {error && <ErrorAlert title="Error loading bookings">{error.message}</ErrorAlert>}

      {/* Bookings List */}
      {bookings.length === 0 ? (
        <EmptyState
          icon="📅"
          title="No bookings found"
          description={hasFilters ? "Try adjusting your filters" : "You haven't made any bookings yet"}
          action={!hasFilters ? { label: "Browse Workspaces", href: "/workspaces" } : undefined}
        />
      ) : (
        <div className="space-y-4">
          {bookings.map((booking) => (
            <BookingCard
              key={booking.id}
              booking={booking}
              onCancel={handleCancel}
              cancelling={cancelling}
            />
          ))}
        </div>
      )}
    </div>
  );
}
