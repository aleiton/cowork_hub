// =============================================================================
// WORKSPACES PAGE
// =============================================================================

"use client";

import { useState } from "react";
import { useQuery } from "@apollo/client/react";
import { GET_WORKSPACES } from "@/graphql/queries/workspaces";
import { Workspace, WorkspaceType, AmenityTier, WorkspacesQueryResult } from "@/types";
import { Select, SkeletonCard, ErrorAlert, EmptyState, Button } from "@/components/ui";
import { WorkspaceCard } from "@/components/workspaces/WorkspaceCard";

const typeOptions = [
  { value: "", label: "All Types" },
  { value: "DESK", label: "Hot Desks" },
  { value: "PRIVATE_OFFICE", label: "Private Offices" },
  { value: "MEETING_ROOM", label: "Meeting Rooms" },
  { value: "WORKSHOP", label: "Workshops" },
];

const tierOptions = [
  { value: "", label: "All Tiers" },
  { value: "BASIC", label: "Basic" },
  { value: "STANDARD", label: "Standard" },
  { value: "PREMIUM", label: "Premium" },
];

export default function WorkspacesPage() {
  const [typeFilter, setTypeFilter] = useState<WorkspaceType | "">("");
  const [tierFilter, setTierFilter] = useState<AmenityTier | "">("");

  const { data, loading, error } = useQuery<WorkspacesQueryResult>(GET_WORKSPACES, {
    variables: {
      workspaceType: typeFilter || undefined,
      amenityTier: tierFilter || undefined,
    },
  });

  const workspaces: Workspace[] = data?.workspaces || [];
  const hasFilters = typeFilter || tierFilter;

  const clearFilters = () => {
    setTypeFilter("");
    setTierFilter("");
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Workspaces</h1>
        <p className="text-gray-600">Find and book the perfect space for your needs</p>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm p-4 mb-8">
        <div className="flex flex-wrap gap-4 items-end">
          <Select
            label="Type"
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value as WorkspaceType | "")}
            options={typeOptions}
            className="w-48"
          />
          <Select
            label="Amenity Tier"
            value={tierFilter}
            onChange={(e) => setTierFilter(e.target.value as AmenityTier | "")}
            options={tierOptions}
            className="w-48"
          />
          {hasFilters && (
            <Button variant="ghost" onClick={clearFilters}>
              Clear filters
            </Button>
          )}
        </div>
      </div>

      {/* Loading */}
      {loading && (
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[...Array(6)].map((_, i) => <SkeletonCard key={i} />)}
        </div>
      )}

      {/* Error */}
      {error && (
        <ErrorAlert title="Error loading workspaces">{error.message}</ErrorAlert>
      )}

      {/* Results */}
      {!loading && !error && (
        <>
          <p className="text-sm text-gray-500 mb-4">
            {workspaces.length} workspace{workspaces.length !== 1 ? "s" : ""} found
          </p>

          {workspaces.length === 0 ? (
            <EmptyState
              icon="🏢"
              title="No workspaces found"
              description={hasFilters ? "Try adjusting your filters" : "No workspaces available"}
              action={hasFilters ? undefined : { label: "Refresh", href: "/workspaces" }}
            />
          ) : (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {workspaces.map((workspace) => (
                <WorkspaceCard key={workspace.id} workspace={workspace} />
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
}
