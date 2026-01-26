// =============================================================================
// ALERT COMPONENTS
// =============================================================================
// Feedback messages for errors, success, warnings, and info.

import { ReactNode } from "react";

type AlertVariant = "error" | "success" | "warning" | "info";

interface AlertProps {
  variant?: AlertVariant;
  title?: string;
  children: ReactNode;
  className?: string;
}

const variantStyles: Record<AlertVariant, { container: string; title: string }> = {
  error: {
    container: "bg-red-50 border-red-200 text-red-700",
    title: "text-red-800",
  },
  success: {
    container: "bg-green-50 border-green-200 text-green-700",
    title: "text-green-800",
  },
  warning: {
    container: "bg-yellow-50 border-yellow-200 text-yellow-700",
    title: "text-yellow-800",
  },
  info: {
    container: "bg-blue-50 border-blue-200 text-blue-700",
    title: "text-blue-800",
  },
};

export function Alert({
  variant = "info",
  title,
  children,
  className = "",
}: AlertProps) {
  const styles = variantStyles[variant];

  return (
    <div className={`border rounded-lg p-4 ${styles.container} ${className}`}>
      {title && (
        <p className={`font-medium mb-1 ${styles.title}`}>{title}</p>
      )}
      <div className="text-sm">{children}</div>
    </div>
  );
}

// Convenience components
export function ErrorAlert({ children, ...props }: Omit<AlertProps, "variant">) {
  return <Alert variant="error" {...props}>{children}</Alert>;
}

export function SuccessAlert({ children, ...props }: Omit<AlertProps, "variant">) {
  return <Alert variant="success" {...props}>{children}</Alert>;
}
