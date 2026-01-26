// =============================================================================
// WORKSPACE CARD
// =============================================================================

import Link from "next/link";
import { Workspace, WorkspaceType, AmenityTier } from "@/types";
import { TierBadge } from "@/components/ui";
import { formatWorkspaceType, formatCurrency } from "@/lib/format";

const typeStyles: Record<WorkspaceType, { bg: string; icon: string }> = {
  DESK: { bg: "bg-blue-500", icon: "💻" },
  PRIVATE_OFFICE: { bg: "bg-purple-500", icon: "🚪" },
  MEETING_ROOM: { bg: "bg-green-500", icon: "👥" },
  WORKSHOP: { bg: "bg-orange-500", icon: "🔧" },
};

interface WorkspaceCardProps {
  workspace: Workspace;
}

export function WorkspaceCard({ workspace }: WorkspaceCardProps) {
  const style = typeStyles[workspace.workspaceType] || { bg: "bg-gray-500", icon: "📍" };

  return (
    <Link
      href={`/workspaces/${workspace.id}`}
      className="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow group"
    >
      <div className={`h-32 ${style.bg} relative`}>
        <div className="absolute inset-0 bg-black/10" />
        <div className="absolute bottom-4 left-4">
          <span className="text-4xl">{style.icon}</span>
        </div>
        <div className="absolute top-4 right-4">
          <TierBadge tier={workspace.amenityTier} />
        </div>
      </div>

      <div className="p-5">
        <h3 className="font-semibold text-gray-900 mb-1 group-hover:text-indigo-600 transition-colors">
          {workspace.name}
        </h3>
        <p className="text-sm text-gray-500 mb-3">
          {formatWorkspaceType(workspace.workspaceType)}
        </p>
        {workspace.description && (
          <p className="text-sm text-gray-600 mb-3 line-clamp-2">
            {workspace.description}
          </p>
        )}
        <div className="flex justify-between items-center pt-3 border-t border-gray-100">
          <span className="text-sm text-gray-500">Capacity: {workspace.capacity}</span>
          <span className="font-semibold text-indigo-600">
            {formatCurrency(workspace.hourlyRate)}/hr
          </span>
        </div>
      </div>
    </Link>
  );
}
