// =============================================================================
// DASHBOARD PAGE
// =============================================================================
// User's personal dashboard showing membership, bookings, and account info.

"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@apollo/client/react";
import { GET_ME_WITH_MEMBERSHIP, GET_MY_BOOKINGS } from "@/graphql/queries/user";
import { isAuthenticated } from "@/lib/apollo-client";
import { MeWithMembershipQueryResult, MyBookingsQueryResult } from "@/types";
import {
  MembershipCard,
  CantinaCard,
  QuickActionsCard,
  UpcomingBookings,
  AccountInfo,
} from "@/components/dashboard";

export default function DashboardPage() {
  const router = useRouter();

  // Auth check
  useEffect(() => {
    if (!isAuthenticated()) {
      router.push("/login");
    }
  }, [router]);

  // Fetch user data with membership and subscription
  const { data: userData, loading: userLoading } = useQuery<MeWithMembershipQueryResult>(GET_ME_WITH_MEMBERSHIP, {
    skip: typeof window === "undefined" || !isAuthenticated(),
  });

  // Fetch upcoming bookings
  const { data: bookingsData, loading: bookingsLoading } = useQuery<MyBookingsQueryResult>(GET_MY_BOOKINGS, {
    variables: { upcomingOnly: true },
    skip: typeof window === "undefined" || !isAuthenticated(),
  });

  const user = userData?.me;
  const membership = userData?.myCurrentMembership ?? null;
  const cantinaSubscription = userData?.myCantinaSubscription ?? null;
  const upcomingBookings = bookingsData?.myBookings?.slice(0, 3) || [];

  // Loading state
  if (userLoading || !userData) {
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
    return null;
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
        <MembershipCard membership={membership} />
        <CantinaCard subscription={cantinaSubscription} />
        <QuickActionsCard />
      </div>

      {/* Upcoming Bookings */}
      <UpcomingBookings bookings={upcomingBookings} loading={bookingsLoading} />

      {/* Account Info */}
      <AccountInfo email={user.email} role={user.role} />
    </div>
  );
}
