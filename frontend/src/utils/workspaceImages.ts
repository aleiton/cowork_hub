// =============================================================================
// WORKSPACE IMAGES
// =============================================================================
// Maps workspace types to their default images.
// Phase 1: Static default images stored in public/images/workspaces/
// Phase 2 (future): Custom images per workspace via Active Storage + S3

import { WorkspaceType } from "@/types";

const WORKSPACE_IMAGES: Record<WorkspaceType, string> = {
  DESK: "/images/workspaces/desk.jpg",
  PRIVATE_OFFICE: "/images/workspaces/private-office.jpg",
  MEETING_ROOM: "/images/workspaces/meeting-room.jpg",
  WORKSHOP: "/images/workspaces/workshop.jpg",
};

const DEFAULT_IMAGE = "/images/workspaces/default.jpg";

export function getWorkspaceImage(type: WorkspaceType): string {
  return WORKSPACE_IMAGES[type] || DEFAULT_IMAGE;
}
