// =============================================================================
// UPCOMING BOOKINGS
// =============================================================================
// Shows upcoming bookings list on the dashboard.

import Link from "next/link";
import { BookingStatus } from "@/types";
import { StatusBadge } from "@/components/ui";
import { formatDate, formatTime } from "@/lib/format";

// Icons by workspace type
const workspaceIcons: Record<string, string> = {
  WORKSHOP: "🔧",
  MEETING_ROOM: "👥",
  PRIVATE_OFFICE: "🚪",
  DESK: "💻",
};

interface BookingItem {
  id: string;
  date: string;
  startTime: string;
  endTime: string;
  status: BookingStatus;
  workspace?: {
    name: string;
    workspaceType: string;
  };
}

interface UpcomingBookingsProps {
  bookings: BookingItem[];
  loading?: boolean;
}

export function UpcomingBookings({ bookings, loading }: UpcomingBookingsProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-lg font-semibold text-gray-900">Upcoming Bookings</h2>
        <Link
          href="/bookings"
          className="text-indigo-600 hover:text-indigo-700 text-sm font-medium"
        >
          View all →
        </Link>
      </div>

      {loading ? (
        <div className="animate-pulse space-y-4">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-20 bg-gray-100 rounded-lg" />
          ))}
        </div>
      ) : bookings.length > 0 ? (
        <div className="space-y-4">
          {bookings.map((booking) => (
            <BookingListItem key={booking.id} booking={booking} />
          ))}
        </div>
      ) : (
        <div className="text-center py-8">
          <p className="text-gray-500 mb-4">No upcoming bookings</p>
          <Link
            href="/workspaces"
            className="inline-block px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors"
          >
            Book a workspace
          </Link>
        </div>
      )}
    </div>
  );
}

// Individual booking item
function BookingListItem({ booking }: { booking: BookingItem }) {
  const icon = booking.workspace ? workspaceIcons[booking.workspace.workspaceType] || "🏢" : "🏢";

  return (
    <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
      <div className="flex items-center">
        <div className="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center mr-4">
          <span className="text-xl">{icon}</span>
        </div>
        <div>
          <h3 className="font-medium text-gray-900">{booking.workspace?.name || "Workspace"}</h3>
          <p className="text-sm text-gray-500">
            {formatDate(booking.date)} • {formatTime(booking.startTime)} - {formatTime(booking.endTime)}
          </p>
        </div>
      </div>
      <StatusBadge status={booking.status} />
    </div>
  );
}
