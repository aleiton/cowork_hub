// =============================================================================
// DASHBOARD CARD WRAPPER
// =============================================================================
// Consistent card styling for dashboard widgets.

import { ReactNode } from "react";

interface DashboardCardProps {
  title: string;
  icon: string;
  children: ReactNode;
  className?: string;
}

export function DashboardCard({ title, icon, children, className = "" }: DashboardCardProps) {
  return (
    <div className={`bg-white rounded-xl shadow-sm border border-gray-200 p-6 ${className}`}>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
        <span className="text-2xl">{icon}</span>
      </div>
      {children}
    </div>
  );
}
