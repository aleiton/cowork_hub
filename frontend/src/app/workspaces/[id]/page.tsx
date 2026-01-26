// =============================================================================
// WORKSPACE DETAIL PAGE
// =============================================================================

"use client";

import { useState } from "react";
import { useQuery } from "@apollo/client/react";
import Link from "next/link";
import { GET_WORKSPACE } from "@/graphql/queries/workspaces";
import { GET_ME } from "@/graphql/queries/user";
import { Workspace } from "@/types";
import {
  WorkspaceHeader,
  AmenitiesList,
  EquipmentList,
  BookingForm,
} from "@/components/workspaces";

interface PageProps {
  params: Promise<{ id: string }>;
}

export default function WorkspaceDetailPage({ params }: PageProps) {
  const [id, setId] = useState<string | null>(null);

  // Unwrap params (Next.js 15+ makes params a Promise)
  if (!id) {
    params.then((p) => setId(p.id));
  }

  // Fetch workspace details
  const { data, loading, error } = useQuery(GET_WORKSPACE, {
    variables: { id },
    skip: !id,
  });

  // Check if user is authenticated
  const { data: userData } = useQuery(GET_ME, {
    errorPolicy: "ignore",
  });

  const workspace: Workspace | null = data?.workspace;
  const isAuthenticated = !!userData?.me;
  const isWorkshop = workspace?.workspaceType === "WORKSHOP";

  // Loading state
  if (!id || loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/3 mb-4" />
          <div className="h-64 bg-gray-200 rounded mb-8" />
          <div className="grid md:grid-cols-2 gap-8">
            <div className="h-48 bg-gray-200 rounded" />
            <div className="h-48 bg-gray-200 rounded" />
          </div>
        </div>
      </div>
    );
  }

  // Error state
  if (error || !workspace) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <h2 className="text-xl font-semibold text-red-700 mb-2">
            Workspace Not Found
          </h2>
          <p className="text-red-600 mb-4">
            {error?.message || "The requested workspace does not exist."}
          </p>
          <Link
            href="/workspaces"
            className="text-indigo-600 hover:text-indigo-700 font-medium"
          >
            &larr; Back to Workspaces
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Breadcrumb */}
      <nav className="mb-6">
        <Link href="/workspaces" className="text-indigo-600 hover:text-indigo-700">
          &larr; Back to Workspaces
        </Link>
      </nav>

      <WorkspaceHeader workspace={workspace} />

      <div className="grid lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-8">
          {/* Description */}
          {workspace.description && (
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-3">
                About this Space
              </h2>
              <p className="text-gray-600">{workspace.description}</p>
            </div>
          )}

          <AmenitiesList tier={workspace.amenityTier} />

          {isWorkshop && <EquipmentList equipment={workspace.equipment || []} />}
        </div>

        {/* Booking Sidebar */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg shadow-sm p-6 sticky top-24">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Book this Space
            </h2>
            <BookingForm
              workspaceId={workspace.id}
              isWorkshop={isWorkshop}
              equipment={workspace.equipment}
              isAuthenticated={isAuthenticated}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
