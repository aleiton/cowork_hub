// =============================================================================
// MEMBERSHIP CARD
// =============================================================================
// Shows current membership status on the dashboard.

import Link from "next/link";
import { DashboardCard } from "./DashboardCard";
import { formatDate } from "@/lib/format";

interface MembershipData {
  membershipType: string;
  amenityTier: string;
  remainingDays: number;
  endsAt: string;
}

interface MembershipCardProps {
  membership: MembershipData | null;
}

export function MembershipCard({ membership }: MembershipCardProps) {
  return (
    <DashboardCard title="Membership" icon="🎫">
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
    </DashboardCard>
  );
}
