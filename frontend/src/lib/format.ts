// =============================================================================
// FORMATTING UTILITIES
// =============================================================================
// Common formatting functions used across the app.

export function formatDate(dateStr: string, options?: Intl.DateTimeFormatOptions): string {
  const defaultOptions: Intl.DateTimeFormatOptions = {
    weekday: "short",
    month: "short",
    day: "numeric",
  };
  return new Date(dateStr).toLocaleDateString("en-US", options || defaultOptions);
}

export function formatDateLong(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
    year: "numeric",
  });
}

export function formatTime(timeStr: string): string {
  // Handle "HH:MM:SS" or "HH:MM" format from Rails
  const [hours, minutes] = timeStr.split(":");
  const hour = parseInt(hours, 10);
  const ampm = hour >= 12 ? "PM" : "AM";
  const hour12 = hour % 12 || 12;
  return `${hour12}:${minutes} ${ampm}`;
}

export function formatCurrency(amount: number): string {
  return `$${amount.toFixed(2)}`;
}

export function formatWorkspaceType(type: string): string {
  const labels: Record<string, string> = {
    DESK: "Hot Desk",
    PRIVATE_OFFICE: "Private Office",
    MEETING_ROOM: "Meeting Room",
    WORKSHOP: "Workshop",
  };
  return labels[type] || type;
}

export type TierInfo = {
  color: string;
  features: string[];
};

export function getTierInfo(tier: string): TierInfo {
  const info: Record<string, TierInfo> = {
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
}
