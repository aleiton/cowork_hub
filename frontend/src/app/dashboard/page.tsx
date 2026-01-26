// =============================================================================
// DASHBOARD PAGE
// =============================================================================
//
// User's personal dashboard showing:
// - Profile information
// - Current membership status
// - Upcoming bookings
// - Cantina subscription (meal credits)
//
// PROTECTED ROUTE:
// This page requires authentication. If the user is not logged in,
// they are redirected to the login page.
//
// =============================================================================

"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useQuery } from "@apollo/client/react";
import { GET_ME_WITH_MEMBERSHIP, GET_MY_BOOKINGS } from "@/graphql/queries/user";
import { isAuthenticated } from "@/lib/apollo-client";

// Format date for display
const formatDate = (dateStr: string): string => {
  return new Date(dateStr).toLocaleDateString("en-US", {
    weekday: "short",
    month: "short",
    day: "numeric",
  });
};

// Format time for display
const formatTime = (timeStr: string): string => {
  // Handle "HH:MM:SS" format from Rails
  const [hours, minutes] = timeStr.split(":");
  const hour = parseInt(hours, 10);
  const ampm = hour >= 12 ? "PM" : "AM";
  const hour12 = hour % 12 || 12;
  return `${hour12}:${minutes} ${ampm}`;
};

export default function DashboardPage() {
  const router = useRouter();

  // Check authentication on mount
  useEffect(() => {
    if (!isAuthenticated()) {
      router.push("/login");
    }
  }, [router]);

  // Fetch user data with membership and subscription
  const { data: userData, loading: userLoading } = useQuery(GET_ME_WITH_MEMBERSHIP, {
    skip: typeof window === "undefined" || !isAuthenticated(),
  });

  // Fetch upcoming bookings
  const { data: bookingsData, loading: bookingsLoading } = useQuery(GET_MY_BOOKINGS, {
    variables: { upcomingOnly: true },
    skip: typeof window === "undefined" || !isAuthenticated(),
  });

  const user = userData?.me;
  const membership = userData?.myCurrentMembership;
  const cantinaSubscription = userData?.myCantinaSubscription;
  const upcomingBookings = bookingsData?.myBookings?.slice(0, 3) || [];

  // Loading state
  if (userLoading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="animate-pulse space-y-8">
          <div className="h-8 bg-gray-200 rounded w-1/4" />
          <div className="grid md:grid-cols-3 gap-6">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-40 bg-gray-200 rounded-lg" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  // Not authenticated
  if (!user) {
    return null; // Will redirect via useEffect
  }

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">
          Welcome back{user.email ? `, ${user.email.split("@")[0]}` : ""}!
        </h1>
        <p className="text-gray-600 mt-1">
          Here&apos;s an overview of your CoworkHub activity
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid md:grid-cols-3 gap-6 mb-8">
        {/* Membership Card */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Membership</h2>
            <span className="text-2xl">🎫</span>
          </div>
          {membership ? (
            <>
              <div className="mb-3">
                <span className="inline-block px-3 py-1 bg-indigo-100 text-indigo-700 rounded-full text-sm font-medium">
                  {membership.membershipType.replace("_", " ")}
                </span>
                <span className="inline-block ml-2 px-3 py-1 bg-purple-100 text-purple-700 rounded-full text-sm font-medium">
                  {membership.amenityTier}
                </span>
              </div>
              <p className="text-sm text-gray-600">
                {membership.remainingDays} days remaining
              </p>
              <p className="text-xs text-gray-500 mt-1">
                Expires: {formatDate(membership.endsAt)}
              </p>
            </>
          ) : (
            <div>
              <p className="text-gray-500 mb-3">No active membership</p>
              <Link
                href="/memberships"
                className="text-indigo-600 hover:text-indigo-700 text-sm font-medium"
              >
                Get a membership →
              </Link>
            </div>
          )}
        </div>

        {/* Cantina Card */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Cantina</h2>
            <span className="text-2xl">🍽️</span>
          </div>
          {cantinaSubscription ? (
            <>
              <div className="mb-3">
                <span className="text-3xl font-bold text-gray-900">
                  {cantinaSubscription.mealsRemaining}
                </span>
                <span className="text-gray-500 ml-2">meals left</span>
              </div>
              <p className="text-sm text-gray-600">
                {cantinaSubscription.planType} Plan
              </p>
              <p className="text-xs text-gray-500 mt-1">
                Renews: {formatDate(cantinaSubscription.renewsAt)}
              </p>
            </>
          ) : (
            <div>
              <p className="text-gray-500 mb-3">No meal subscription</p>
              <Link
                href="/cantina"
                className="text-indigo-600 hover:text-indigo-700 text-sm font-medium"
              >
                Subscribe to cantina →
              </Link>
            </div>
          )}
        </div>

        {/* Quick Actions Card */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Quick Actions</h2>
            <span className="text-2xl">⚡</span>
          </div>
          <div className="space-y-3">
            <Link
              href="/workspaces"
              className="flex items-center p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <span className="text-xl mr-3">🏢</span>
              <span className="text-sm font-medium text-gray-700">Book a workspace</span>
            </Link>
            <Link
              href="/workshops"
              className="flex items-center p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <span className="text-xl mr-3">🔧</span>
              <span className="text-sm font-medium text-gray-700">Reserve equipment</span>
            </Link>
          </div>
        </div>
      </div>

      {/* Upcoming Bookings */}
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

        {bookingsLoading ? (
          <div className="animate-pulse space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-20 bg-gray-100 rounded-lg" />
            ))}
          </div>
        ) : upcomingBookings.length > 0 ? (
          <div className="space-y-4">
            {upcomingBookings.map((booking: {
              id: string;
              date: string;
              startTime: string;
              endTime: string;
              status: string;
              workspace: { name: string; workspaceType: string };
            }) => (
              <div
                key={booking.id}
                className="flex items-center justify-between p-4 bg-gray-50 rounded-lg"
              >
                <div className="flex items-center">
                  <div className="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center mr-4">
                    <span className="text-xl">
                      {booking.workspace.workspaceType === "WORKSHOP" ? "🔧" : "🏢"}
                    </span>
                  </div>
                  <div>
                    <h3 className="font-medium text-gray-900">
                      {booking.workspace.name}
                    </h3>
                    <p className="text-sm text-gray-500">
                      {formatDate(booking.date)} • {formatTime(booking.startTime)} -{" "}
                      {formatTime(booking.endTime)}
                    </p>
                  </div>
                </div>
                <span
                  className={`px-3 py-1 rounded-full text-xs font-medium ${
                    booking.status === "CONFIRMED"
                      ? "bg-green-100 text-green-700"
                      : booking.status === "PENDING"
                      ? "bg-yellow-100 text-yellow-700"
                      : "bg-gray-100 text-gray-700"
                  }`}
                >
                  {booking.status}
                </span>
              </div>
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

      {/* Account Info */}
      <div className="mt-8 bg-gray-50 rounded-xl p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Account Info</h2>
        <div className="grid sm:grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-gray-500">Email</p>
            <p className="font-medium text-gray-900">{user.email}</p>
          </div>
          <div>
            <p className="text-sm text-gray-500">Role</p>
            <p className="font-medium text-gray-900 capitalize">{user.role?.toLowerCase()}</p>
          </div>
        </div>
      </div>
    </div>
  );
}
