// =============================================================================
// CARD COMPONENT
// =============================================================================

import { ReactNode } from "react";

interface CardProps {
  children: ReactNode;
  className?: string;
  padding?: boolean;
}

export function Card({ children, className = "", padding = true }: CardProps) {
  return (
    <div className={`bg-white rounded-xl shadow-sm border border-gray-200 ${padding ? "p-6" : ""} ${className}`}>
      {children}
    </div>
  );
}

export function CardHeader({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div className={`flex items-center justify-between mb-4 ${className}`}>
      {children}
    </div>
  );
}

export function CardTitle({ children, icon }: { children: ReactNode; icon?: string }) {
  return (
    <div className="flex items-center gap-2">
      {icon && <span className="text-2xl">{icon}</span>}
      <h2 className="text-lg font-semibold text-gray-900">{children}</h2>
    </div>
  );
}
