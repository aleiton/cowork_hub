// =============================================================================
// CANTINA CARD
// =============================================================================
// Shows meal subscription status on the dashboard.

import Link from "next/link";
import { DashboardCard } from "./DashboardCard";
import { formatDate } from "@/lib/format";

interface CantinaData {
  planType: string;
  mealsRemaining: number;
  renewsAt: string;
}

interface CantinaCardProps {
  subscription: CantinaData | null;
}

export function CantinaCard({ subscription }: CantinaCardProps) {
  return (
    <DashboardCard title="Cantina" icon="🍽️">
      {subscription ? (
        <>
          <div className="mb-3">
            <span className="text-3xl font-bold text-gray-900">
              {subscription.mealsRemaining}
            </span>
            <span className="text-gray-500 ml-2">meals left</span>
          </div>
          <p className="text-sm text-gray-600">{subscription.planType} Plan</p>
          <p className="text-xs text-gray-500 mt-1">
            Renews: {formatDate(subscription.renewsAt)}
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
    </DashboardCard>
  );
}
