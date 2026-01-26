// =============================================================================
// QUICK ACTIONS CARD
// =============================================================================
// Shows quick action links on the dashboard.

import Link from "next/link";
import { DashboardCard } from "./DashboardCard";

const actions = [
  { href: "/workspaces", icon: "🏢", label: "Book a workspace" },
  { href: "/workshops", icon: "🔧", label: "Reserve equipment" },
];

export function QuickActionsCard() {
  return (
    <DashboardCard title="Quick Actions" icon="⚡">
      <div className="space-y-3">
        {actions.map((action) => (
          <Link
            key={action.href}
            href={action.href}
            className="flex items-center p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <span className="text-xl mr-3">{action.icon}</span>
            <span className="text-sm font-medium text-gray-700">{action.label}</span>
          </Link>
        ))}
      </div>
    </DashboardCard>
  );
}
