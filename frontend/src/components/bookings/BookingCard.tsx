// =============================================================================
// BOOKING CARD COMPONENT
// =============================================================================
// Displays a single booking with workspace info, date/time, status, and actions.

import Link from "next/link";
import { BookingStatus } from "@/types";
import { StatusBadge } from "@/components/ui";
import { formatDateLong, formatTime, formatCurrency } from "@/lib/format";

// Icons by workspace type
const workspaceIcons: Record<string, string> = {
  WORKSHOP: "🔧",
  MEETING_ROOM: "👥",
  PRIVATE_OFFICE: "🚪",
  DESK: "💻",
};

export interface BookingData {
  id: string;
  date: string;
  startTime: string;
  endTime: string;
  status: BookingStatus;
  calculatedPrice: number;
  durationHours: number;
  workspace: {
    id: string;
    name: string;
    workspaceType: string;
  };
}

interface BookingCardProps {
  booking: BookingData;
  onCancel?: (id: string) => void;
  cancelling?: boolean;
}

export function BookingCard({ booking, onCancel, cancelling }: BookingCardProps) {
  const icon = workspaceIcons[booking.workspace.workspaceType] || "🏢";
  const canCancel = booking.status === "PENDING" || booking.status === "CONFIRMED";

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        {/* Left: Icon + Details */}
        <div className="flex items-start gap-4">
          <div className="w-14 h-14 bg-indigo-100 rounded-lg flex items-center justify-center flex-shrink-0">
            <span className="text-2xl">{icon}</span>
          </div>
          <div>
            <Link
              href={`/workspaces/${booking.workspace.id}`}
              className="font-semibold text-gray-900 hover:text-indigo-600"
            >
              {booking.workspace.name}
            </Link>
            <p className="text-gray-600 mt-1">{formatDateLong(booking.date)}</p>
            <p className="text-sm text-gray-500">
              {formatTime(booking.startTime)} - {formatTime(booking.endTime)}
              <span className="mx-2">•</span>
              {booking.durationHours} hour{booking.durationHours !== 1 ? "s" : ""}
            </p>
          </div>
        </div>

        {/* Right: Status + Price + Actions */}
        <div className="flex items-center gap-4">
          <div className="text-right">
            <StatusBadge status={booking.status} />
            {booking.calculatedPrice > 0 && (
              <p className="text-lg font-semibold text-gray-900 mt-2">
                {formatCurrency(booking.calculatedPrice)}
              </p>
            )}
          </div>
          {canCancel && onCancel && (
            <button
              onClick={() => onCancel(booking.id)}
              disabled={cancelling}
              className="px-4 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
            >
              Cancel
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
