// =============================================================================
// BADGE COMPONENT
// =============================================================================
// Small labels for status, categories, etc.

import { ReactNode } from "react";

type BadgeVariant = "gray" | "blue" | "green" | "yellow" | "red" | "purple" | "indigo";

interface BadgeProps {
  variant?: BadgeVariant;
  children: ReactNode;
  className?: string;
}

const variantStyles: Record<BadgeVariant, string> = {
  gray: "bg-gray-100 text-gray-700",
  blue: "bg-blue-100 text-blue-700",
  green: "bg-green-100 text-green-700",
  yellow: "bg-yellow-100 text-yellow-700",
  red: "bg-red-100 text-red-700",
  purple: "bg-purple-100 text-purple-700",
  indigo: "bg-indigo-100 text-indigo-700",
};

export function Badge({ variant = "gray", children, className = "" }: BadgeProps) {
  return (
    <span
      className={`inline-block px-2.5 py-0.5 rounded-full text-xs font-medium ${variantStyles[variant]} ${className}`}
    >
      {children}
    </span>
  );
}

// Pre-configured status badge for booking status
type BookingStatus = "PENDING" | "CONFIRMED" | "CANCELLED" | "COMPLETED";

const statusVariants: Record<BookingStatus, BadgeVariant> = {
  PENDING: "yellow",
  CONFIRMED: "green",
  CANCELLED: "red",
  COMPLETED: "gray",
};

export function StatusBadge({ status }: { status: BookingStatus }) {
  return <Badge variant={statusVariants[status]}>{status}</Badge>;
}

// Pre-configured tier badge
type AmenityTier = "BASIC" | "STANDARD" | "PREMIUM";

const tierVariants: Record<AmenityTier, BadgeVariant> = {
  BASIC: "gray",
  STANDARD: "blue",
  PREMIUM: "purple",
};

export function TierBadge({ tier }: { tier: AmenityTier }) {
  return <Badge variant={tierVariants[tier]}>{tier}</Badge>;
}
