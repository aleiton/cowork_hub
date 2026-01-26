// =============================================================================
// MY BOOKINGS PAGE
// =============================================================================
//
// Shows all bookings for the authenticated user with filtering options.
//
// =============================================================================

"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useQuery, useMutation } from "@apollo/client/react";
import { GET_MY_BOOKINGS } from "@/graphql/queries/user";
import { CANCEL_BOOKING } from "@/graphql/mutations/bookings";
import { isAuthenticated } from "@/lib/apollo-client";
import { BookingStatus } from "@/types";

// Format date
const formatDate = (dateStr: string): string => {
  return new Date(dateStr).toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
    year: "numeric",
  });
};

// Format time
const formatTime = (timeStr: string): string => {
  const [hours, minutes] = timeStr.split(":");
  const hour = parseInt(hours, 10);
  const ampm = hour >= 12 ? "PM" : "AM";
  const hour12 = hour % 12 || 12;
  return `${hour12}:${minutes} ${ampm}`;
};

// Status badge styles
const getStatusStyle = (status: BookingStatus) => {
  const styles: Record<BookingStatus, string> = {
    PENDING: "bg-yellow-100 text-yellow-700",
    CONFIRMED: "bg-green-100 text-green-700",
    CANCELLED: "bg-red-100 text-red-700",
    COMPLETED: "bg-gray-100 text-gray-700",
  };
  return styles[status] || "bg-gray-100 text-gray-700";
};

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
    onCompleted: () => {
      refetch();
    },
  });

  const bookings = data?.myBookings || [];

  const handleCancel = async (bookingId: string) => {
    if (confirm("Are you sure you want to cancel this booking?")) {
      await cancelBooking({ variables: { id: bookingId } });
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-8" />
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-24 bg-gray-200 rounded-lg" />
          ))}
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
        <Link
          href="/workspaces"
          className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors"
        >
          + New Booking
        </Link>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm p-4 mb-6 flex flex-wrap gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Status
          </label>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as BookingStatus | "")}
            className="block w-40 px-3 py-2 border border-gray-300 rounded-md"
          >
            <option value="">All</option>
            <option value="PENDING">Pending</option>
            <option value="CONFIRMED">Confirmed</option>
            <option value="CANCELLED">Cancelled</option>
            <option value="COMPLETED">Completed</option>
          </select>
        </div>
        <div className="flex items-end">
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={showUpcomingOnly}
              onChange={(e) => setShowUpcomingOnly(e.target.checked)}
              className="rounded border-gray-300 text-indigo-600"
            />
            <span className="text-sm text-gray-700">Upcoming only</span>
          </label>
        </div>
      </div>

      {/* Error */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
          <p className="text-red-700">{error.message}</p>
        </div>
      )}

      {/* Bookings List */}
      {bookings.length === 0 ? (
        <div className="bg-white rounded-xl shadow-sm p-12 text-center">
          <div className="text-4xl mb-4">📅</div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">No bookings found</h2>
          <p className="text-gray-500 mb-6">
            {statusFilter || showUpcomingOnly
              ? "Try adjusting your filters"
              : "You haven't made any bookings yet"}
          </p>
          <Link
            href="/workspaces"
            className="inline-block px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700"
          >
            Browse Workspaces
          </Link>
        </div>
      ) : (
        <div className="space-y-4">
          {bookings.map((booking: {
            id: string;
            date: string;
            startTime: string;
            endTime: string;
            status: BookingStatus;
            totalCost: number;
            durationHours: number;
            workspace: { id: string; name: string; workspaceType: string };
          }) => (
            <div
              key={booking.id}
              className="bg-white rounded-lg shadow-sm border border-gray-200 p-6"
            >
              <div className="flex flex-wrap items-start justify-between gap-4">
                <div className="flex items-start gap-4">
                  <div className="w-14 h-14 bg-indigo-100 rounded-lg flex items-center justify-center flex-shrink-0">
                    <span className="text-2xl">
                      {booking.workspace.workspaceType === "WORKSHOP" ? "🔧" : "🏢"}
                    </span>
                  </div>
                  <div>
                    <Link
                      href={`/workspaces/${booking.workspace.id}`}
                      className="font-semibold text-gray-900 hover:text-indigo-600"
                    >
                      {booking.workspace.name}
                    </Link>
                    <p className="text-gray-600 mt-1">{formatDate(booking.date)}</p>
                    <p className="text-sm text-gray-500">
                      {formatTime(booking.startTime)} - {formatTime(booking.endTime)}
                      <span className="mx-2">•</span>
                      {booking.durationHours} hour{booking.durationHours !== 1 ? "s" : ""}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="text-right">
                    <span className={`inline-block px-3 py-1 rounded-full text-xs font-medium ${getStatusStyle(booking.status)}`}>
                      {booking.status}
                    </span>
                    {booking.totalCost && (
                      <p className="text-lg font-semibold text-gray-900 mt-2">
                        ${booking.totalCost.toFixed(2)}
                      </p>
                    )}
                  </div>
                  {(booking.status === "PENDING" || booking.status === "CONFIRMED") && (
                    <button
                      onClick={() => handleCancel(booking.id)}
                      disabled={cancelling}
                      className="px-4 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
                    >
                      Cancel
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
