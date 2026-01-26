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
