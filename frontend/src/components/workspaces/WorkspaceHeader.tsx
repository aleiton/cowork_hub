// =============================================================================
// WORKSPACE HEADER
// =============================================================================

import { Workspace } from "@/types";
import { formatWorkspaceType, formatCurrency, getTierInfo } from "@/lib/format";

interface WorkspaceHeaderProps {
  workspace: Workspace;
}

export function WorkspaceHeader({ workspace }: WorkspaceHeaderProps) {
  const tierInfo = getTierInfo(workspace.amenityTier);

  return (
    <div className="mb-8">
      <div className="flex items-start justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            {workspace.name}
          </h1>
          <div className="flex items-center gap-3">
            <span className="text-gray-600">
              {formatWorkspaceType(workspace.workspaceType)}
            </span>
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${tierInfo.color}`}>
              {workspace.amenityTier}
            </span>
          </div>
        </div>
        <div className="text-right">
          <div className="text-3xl font-bold text-indigo-600">
            {formatCurrency(workspace.hourlyRate)}
            <span className="text-lg text-gray-500 font-normal">/hr</span>
          </div>
          <div className="text-sm text-gray-500">
            Capacity: {workspace.capacity} {workspace.capacity === 1 ? "person" : "people"}
          </div>
        </div>
      </div>
    </div>
  );
}
