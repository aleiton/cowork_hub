// =============================================================================
// DIVIDER COMPONENT
// =============================================================================
// A horizontal divider with optional centered text.

interface DividerProps {
  children?: React.ReactNode;
  className?: string;
}

export function Divider({ children, className = "" }: DividerProps) {
  if (!children) {
    return <div className={`w-full border-t border-gray-200 ${className}`} />;
  }

  return (
    <div className={`relative ${className}`}>
      <div className="absolute inset-0 flex items-center">
        <div className="w-full border-t border-gray-200" />
      </div>
      <div className="relative flex justify-center text-sm">
        <span className="px-2 bg-white text-gray-500">{children}</span>
      </div>
    </div>
  );
}
