// =============================================================================
// AMENITIES LIST
// =============================================================================

import { AmenityTier } from "@/types";
import { getTierInfo } from "@/lib/format";

interface AmenitiesListProps {
  tier: AmenityTier;
}

function CheckIcon() {
  return (
    <svg
      className="w-5 h-5 text-green-500 mr-2"
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M5 13l4 4L19 7"
      />
    </svg>
  );
}

export function AmenitiesList({ tier }: AmenitiesListProps) {
  const tierInfo = getTierInfo(tier);

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <h2 className="text-lg font-semibold text-gray-900 mb-3">
        {tier} Tier Amenities
      </h2>
      <ul className="grid sm:grid-cols-2 gap-2">
        {tierInfo.features.map((feature) => (
          <li key={feature} className="flex items-center text-gray-600">
            <CheckIcon />
            {feature}
          </li>
        ))}
      </ul>
    </div>
  );
}
