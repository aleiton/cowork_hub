// =============================================================================
// WORKSHOPS / MAKER SPACES PAGE
// =============================================================================
// Shows workshop-type workspaces with their available equipment.

"use client";

import Link from "next/link";
import { useQuery } from "@apollo/client/react";
import { GET_WORKSHOPS } from "@/graphql/queries/workspaces";
import { Workspace, WorkspacesQueryResult } from "@/types";
import { SkeletonCard, ErrorAlert, EmptyState, TierBadge } from "@/components/ui";
import { formatCurrency } from "@/lib/format";

export default function WorkshopsPage() {
  const { data, loading, error } = useQuery<WorkspacesQueryResult>(GET_WORKSHOPS);
  const workshops: Workspace[] = data?.workspaces || [];

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Maker Spaces</h1>
        <p className="text-gray-600">
          Fully-equipped workshops with professional tools for your creative projects
        </p>
      </div>

      {/* Loading */}
      {loading && (
        <div className="grid md:grid-cols-2 gap-6">
          {[...Array(4)].map((_, i) => <SkeletonCard key={i} />)}
        </div>
      )}

      {/* Error */}
      {error && (
        <ErrorAlert title="Error loading workshops">{error.message}</ErrorAlert>
      )}

      {/* Workshops List */}
      {!loading && !error && (
        workshops.length === 0 ? (
          <EmptyState
            icon="🔧"
            title="No workshops available"
            description="Check back later for maker space availability"
          />
        ) : (
          <div className="grid md:grid-cols-2 gap-6">
            {workshops.map((workshop) => (
              <Link
                key={workshop.id}
                href={`/workspaces/${workshop.id}`}
                className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow group"
              >
                {/* Header */}
                <div className="bg-gradient-to-r from-orange-500 to-amber-500 p-6 text-white">
                  <div className="flex justify-between items-start">
                    <div>
                      <h2 className="text-xl font-bold mb-1 group-hover:underline">
                        {workshop.name}
                      </h2>
                      <p className="text-orange-100 text-sm">
                        Capacity: {workshop.capacity} people
                      </p>
                    </div>
                    <div className="text-right">
                      <TierBadge tier={workshop.amenityTier} />
                      <p className="text-xl font-bold mt-2">
                        {formatCurrency(workshop.hourlyRate)}/hr
                      </p>
                    </div>
                  </div>
                </div>

                {/* Equipment */}
                <div className="p-6">
                  <h3 className="text-sm font-medium text-gray-500 mb-3">
                    Available Equipment
                  </h3>
                  {workshop.equipment && workshop.equipment.length > 0 ? (
                    <div className="flex flex-wrap gap-2">
                      {workshop.equipment.slice(0, 6).map((eq) => (
                        <span
                          key={eq.id}
                          className="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm"
                        >
                          {eq.name}
                          <span className="text-gray-400 ml-1">×{eq.quantityAvailable}</span>
                        </span>
                      ))}
                      {workshop.equipment.length > 6 && (
                        <span className="px-3 py-1 text-gray-500 text-sm">
                          +{workshop.equipment.length - 6} more
                        </span>
                      )}
                    </div>
                  ) : (
                    <p className="text-gray-400 text-sm">No equipment listed</p>
                  )}
                </div>
              </Link>
            ))}
          </div>
        )
      )}
    </div>
  );
}
