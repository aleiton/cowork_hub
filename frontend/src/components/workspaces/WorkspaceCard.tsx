// =============================================================================
// WORKSPACE CARD
// =============================================================================

import Link from "next/link";
import Image from "next/image";
import { Workspace, WorkspaceType } from "@/types";
import { TierBadge } from "@/components/ui";
import { formatWorkspaceType, formatCurrency } from "@/lib/format";
import { getWorkspaceImage } from "@/utils/workspaceImages";

const typeIcons: Record<WorkspaceType, string> = {
  DESK: "💻",
  PRIVATE_OFFICE: "🚪",
  MEETING_ROOM: "👥",
  WORKSHOP: "🔧",
};

interface WorkspaceCardProps {
  workspace: Workspace;
}

export function WorkspaceCard({ workspace }: WorkspaceCardProps) {
  const icon = typeIcons[workspace.workspaceType] || "📍";

  return (
    <Link
      href={`/workspaces/${workspace.id}`}
      className="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow group"
    >
      <div className="relative h-32 overflow-hidden rounded-t-lg">
        <Image
          src={getWorkspaceImage(workspace.workspaceType)}
          alt={`${workspace.name} - ${workspace.workspaceType}`}
          fill
          sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
          className="object-cover"
        />
        <div className="absolute inset-0 bg-black/20" />
        <div className="absolute bottom-3 left-3">
          <span className="text-3xl drop-shadow-md">{icon}</span>
        </div>
        <div className="absolute top-3 right-3">
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
