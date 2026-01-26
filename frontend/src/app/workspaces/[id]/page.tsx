// =============================================================================
// WORKSPACE DETAIL PAGE
// =============================================================================
//
// Shows details for a single workspace and allows booking.
//
// DYNAMIC ROUTES:
// The [id] in the folder name creates a dynamic route.
// /workspaces/1 -> params.id = "1"
// /workspaces/abc -> params.id = "abc"
//
// Next.js passes the route params as props to the page component.
//
// =============================================================================

"use client";

import { useState } from "react";
import { useQuery, useMutation } from "@apollo/client/react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { GET_WORKSPACE } from "@/graphql/queries/workspaces";
import { GET_ME } from "@/graphql/queries/user";
import { CREATE_BOOKING } from "@/graphql/mutations/bookings";
import { Workspace, AmenityTier } from "@/types";

// Props type for dynamic route
interface PageProps {
  params: Promise<{ id: string }>;
}

// Helper to format workspace type
const formatWorkspaceType = (type: string): string => {
  const labels: Record<string, string> = {
    DESK: "Hot Desk",
    PRIVATE_OFFICE: "Private Office",
    MEETING_ROOM: "Meeting Room",
    WORKSHOP: "Workshop",
  };
  return labels[type] || type;
};

// Helper for tier badge
const getTierInfo = (tier: AmenityTier): { color: string; features: string[] } => {
  const info: Record<AmenityTier, { color: string; features: string[] }> = {
    BASIC: {
      color: "bg-gray-100 text-gray-700",
      features: ["WiFi", "Basic furniture", "Shared amenities"],
    },
    STANDARD: {
      color: "bg-blue-100 text-blue-700",
      features: ["High-speed WiFi", "Ergonomic furniture", "Coffee & tea", "Printing"],
    },
    PREMIUM: {
      color: "bg-purple-100 text-purple-700",
      features: [
        "Fiber internet",
        "Premium furniture",
        "Unlimited refreshments",
        "Dedicated support",
        "Meeting room credits",
      ],
    },
  };
  return info[tier] || info.BASIC;
};

export default function WorkspaceDetailPage({ params }: PageProps) {
  const router = useRouter();

  // Unwrap params (Next.js 15+ makes params a Promise)
  const [id, setId] = useState<string | null>(null);

  // Unwrap the params promise
  if (!id) {
    params.then((p) => setId(p.id));
  }

  // Form state for booking
  const [date, setDate] = useState("");
  const [startTime, setStartTime] = useState("09:00");
  const [endTime, setEndTime] = useState("10:00");
  const [selectedEquipment, setSelectedEquipment] = useState<string[]>([]);
  const [bookingError, setBookingError] = useState("");
  const [bookingSuccess, setBookingSuccess] = useState(false);

  // Fetch workspace details
  const { data, loading, error } = useQuery(GET_WORKSPACE, {
    variables: { id },
    skip: !id,
  });

  // Check if user is authenticated
  const { data: userData } = useQuery(GET_ME, {
    errorPolicy: "ignore",
  });

  // Booking mutation
  const [createBooking, { loading: bookingLoading }] = useMutation(CREATE_BOOKING, {
    onCompleted: (data) => {
      if (data.createBooking.errors.length > 0) {
        setBookingError(data.createBooking.errors.join(", "));
      } else {
        setBookingSuccess(true);
        setTimeout(() => {
          router.push("/bookings");
        }, 2000);
      }
    },
    onError: (err) => {
      setBookingError(err.message);
    },
  });

  const workspace: Workspace | null = data?.workspace;
  const isAuthenticated = !!userData?.me;
  const isWorkshop = workspace?.workspaceType === "WORKSHOP";
  const tierInfo = workspace ? getTierInfo(workspace.amenityTier) : null;

  // Handle booking submission
  const handleBooking = async (e: React.FormEvent) => {
    e.preventDefault();
    setBookingError("");

    if (!isAuthenticated) {
      router.push("/login");
      return;
    }

    await createBooking({
      variables: {
        workspaceId: id,
        date,
        startTime,
        endTime,
        equipmentIds: selectedEquipment.length > 0 ? selectedEquipment : undefined,
      },
    });
  };

  // Toggle equipment selection
  const toggleEquipment = (equipmentId: string) => {
    setSelectedEquipment((prev) =>
      prev.includes(equipmentId)
        ? prev.filter((id) => id !== equipmentId)
        : [...prev, equipmentId]
    );
  };

  // Loading state
  if (!id || loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/3 mb-4" />
          <div className="h-64 bg-gray-200 rounded mb-8" />
          <div className="grid md:grid-cols-2 gap-8">
            <div className="h-48 bg-gray-200 rounded" />
            <div className="h-48 bg-gray-200 rounded" />
          </div>
        </div>
      </div>
    );
  }

  // Error state
  if (error || !workspace) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <h2 className="text-xl font-semibold text-red-700 mb-2">
            Workspace Not Found
          </h2>
          <p className="text-red-600 mb-4">
            {error?.message || "The requested workspace does not exist."}
          </p>
          <Link
            href="/workspaces"
            className="text-indigo-600 hover:text-indigo-700 font-medium"
          >
            ← Back to Workspaces
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Breadcrumb */}
      <nav className="mb-6">
        <Link
          href="/workspaces"
          className="text-indigo-600 hover:text-indigo-700"
        >
          ← Back to Workspaces
        </Link>
      </nav>

      {/* Header */}
      <div className="mb-8">
        <div className="flex items-start justify-between flex-wrap gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              {workspace.name}
            </h1>
            <div className="flex items-center gap-3">
              <span className="text-gray-600">
                {formatWorkspaceType(workspace.workspaceType)}
              </span>
              <span className={`px-2 py-1 rounded-full text-xs font-medium ${tierInfo?.color}`}>
                {workspace.amenityTier}
              </span>
            </div>
          </div>
          <div className="text-right">
            <div className="text-3xl font-bold text-indigo-600">
              ${workspace.hourlyRate}
              <span className="text-lg text-gray-500 font-normal">/hr</span>
            </div>
            <div className="text-sm text-gray-500">
              Capacity: {workspace.capacity} {workspace.capacity === 1 ? "person" : "people"}
            </div>
          </div>
        </div>
      </div>

      <div className="grid lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-8">
          {/* Description */}
          {workspace.description && (
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-3">
                About this Space
              </h2>
              <p className="text-gray-600">{workspace.description}</p>
            </div>
          )}

          {/* Amenities */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-3">
              {workspace.amenityTier} Tier Amenities
            </h2>
            <ul className="grid sm:grid-cols-2 gap-2">
              {tierInfo?.features.map((feature) => (
                <li key={feature} className="flex items-center text-gray-600">
                  <svg
                    className="w-5 h-5 text-green-500 mr-2"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M5 13l4 4L19 7"
                    />
                  </svg>
                  {feature}
                </li>
              ))}
            </ul>
          </div>

          {/* Equipment (for workshops) */}
          {isWorkshop && workspace.equipment && workspace.equipment.length > 0 && (
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-3">
                Available Equipment
              </h2>
              <div className="grid sm:grid-cols-2 gap-4">
                {workspace.equipment.map((eq) => (
                  <div
                    key={eq.id}
                    className="border border-gray-200 rounded-lg p-4"
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-medium text-gray-900">{eq.name}</h3>
                        {eq.description && (
                          <p className="text-sm text-gray-500 mt-1">
                            {eq.description}
                          </p>
                        )}
                      </div>
                      <span className="text-sm text-gray-500">
                        {eq.quantityAvailable} available
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Booking Sidebar */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg shadow-sm p-6 sticky top-24">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Book this Space
            </h2>

            {bookingSuccess ? (
              <div className="bg-green-50 border border-green-200 rounded-lg p-4 text-center">
                <svg
                  className="w-12 h-12 text-green-500 mx-auto mb-3"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
                <p className="text-green-700 font-medium">Booking Confirmed!</p>
                <p className="text-green-600 text-sm mt-1">
                  Redirecting to your bookings...
                </p>
              </div>
            ) : (
              <form onSubmit={handleBooking} className="space-y-4">
                {/* Date */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Date
                  </label>
                  <input
                    type="date"
                    value={date}
                    onChange={(e) => setDate(e.target.value)}
                    min={new Date().toISOString().split("T")[0]}
                    required
                    className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                  />
                </div>

                {/* Time Range */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Start Time
                    </label>
                    <input
                      type="time"
                      value={startTime}
                      onChange={(e) => setStartTime(e.target.value)}
                      required
                      className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      End Time
                    </label>
                    <input
                      type="time"
                      value={endTime}
                      onChange={(e) => setEndTime(e.target.value)}
                      required
                      className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                    />
                  </div>
                </div>

                {/* Equipment Selection (for workshops) */}
                {isWorkshop && workspace.equipment && workspace.equipment.length > 0 && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Equipment Needed
                    </label>
                    <div className="space-y-2 max-h-40 overflow-y-auto">
                      {workspace.equipment.map((eq) => (
                        <label
                          key={eq.id}
                          className="flex items-center gap-2 cursor-pointer"
                        >
                          <input
                            type="checkbox"
                            checked={selectedEquipment.includes(eq.id)}
                            onChange={() => toggleEquipment(eq.id)}
                            className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                          />
                          <span className="text-sm text-gray-700">{eq.name}</span>
                        </label>
                      ))}
                    </div>
                  </div>
                )}

                {/* Error Message */}
                {bookingError && (
                  <div className="bg-red-50 border border-red-200 rounded-md p-3">
                    <p className="text-sm text-red-700">{bookingError}</p>
                  </div>
                )}

                {/* Submit Button */}
                <button
                  type="submit"
                  disabled={bookingLoading}
                  className="w-full py-3 px-4 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {bookingLoading ? "Booking..." : isAuthenticated ? "Book Now" : "Login to Book"}
                </button>

                {!isAuthenticated && (
                  <p className="text-sm text-gray-500 text-center">
                    <Link href="/login" className="text-indigo-600 hover:text-indigo-700">
                      Login
                    </Link>{" "}
                    or{" "}
                    <Link href="/signup" className="text-indigo-600 hover:text-indigo-700">
                      Sign up
                    </Link>{" "}
                    to make a booking
                  </p>
                )}
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
