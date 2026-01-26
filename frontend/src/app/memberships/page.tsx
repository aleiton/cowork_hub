// =============================================================================
// MEMBERSHIPS PAGE
// =============================================================================

"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useMutation } from "@apollo/client/react";
import { GET_ME_WITH_MEMBERSHIP } from "@/graphql/queries/user";
import { CREATE_MEMBERSHIP } from "@/graphql/mutations/memberships";
import { isAuthenticated } from "@/lib/apollo-client";
import { MembershipType, AmenityTier } from "@/types";
import { Button, Card, ErrorAlert, SuccessAlert } from "@/components/ui";
import { formatDate, getTierInfo } from "@/lib/format";

const membershipTypes: { type: MembershipType; label: string; duration: string }[] = [
  { type: "DAY_PASS", label: "Day Pass", duration: "1 day" },
  { type: "WEEKLY", label: "Weekly", duration: "7 days" },
  { type: "MONTHLY", label: "Monthly", duration: "30 days" },
  { type: "ANNUAL", label: "Annual", duration: "365 days" },
];

const amenityTiers: { tier: AmenityTier; price: { DAY_PASS: number; WEEKLY: number; MONTHLY: number; ANNUAL: number } }[] = [
  { tier: "BASIC", price: { DAY_PASS: 25, WEEKLY: 150, MONTHLY: 500, ANNUAL: 5000 } },
  { tier: "STANDARD", price: { DAY_PASS: 40, WEEKLY: 250, MONTHLY: 800, ANNUAL: 8000 } },
  { tier: "PREMIUM", price: { DAY_PASS: 60, WEEKLY: 400, MONTHLY: 1200, ANNUAL: 12000 } },
];

export default function MembershipsPage() {
  const router = useRouter();
  const [selectedType, setSelectedType] = useState<MembershipType>("MONTHLY");
  const [selectedTier, setSelectedTier] = useState<AmenityTier>("STANDARD");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  // Auth check
  useEffect(() => {
    if (!isAuthenticated()) {
      router.push("/login");
    }
  }, [router]);

  // Fetch current membership
  const { data, loading, refetch } = useQuery(GET_ME_WITH_MEMBERSHIP, {
    skip: typeof window === "undefined" || !isAuthenticated(),
  });

  // Create membership mutation
  const [createMembership, { loading: creating }] = useMutation(CREATE_MEMBERSHIP, {
    onCompleted: (data) => {
      if (data.createMembership.errors?.length > 0) {
        setError(data.createMembership.errors.join(", "));
      } else {
        setSuccess(true);
        refetch();
      }
    },
    onError: (err) => {
      setError(err.message);
    },
  });

  const currentMembership = data?.myCurrentMembership;

  const handlePurchase = async () => {
    setError("");
    setSuccess(false);
    await createMembership({
      variables: {
        membershipType: selectedType,
        amenityTier: selectedTier,
      },
    });
  };

  const getPrice = (tier: AmenityTier, type: MembershipType) => {
    const tierData = amenityTiers.find((t) => t.tier === tier);
    return tierData?.price[type] || 0;
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="animate-pulse space-y-8">
          <div className="h-8 bg-gray-200 rounded w-1/4" />
          <div className="h-40 bg-gray-200 rounded-lg" />
          <div className="grid md:grid-cols-3 gap-6">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-64 bg-gray-200 rounded-lg" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Memberships</h1>
        <p className="text-gray-600 mt-1">Choose a membership plan that works for you</p>
      </div>

      {/* Current Membership */}
      {currentMembership && (
        <Card className="mb-8 border-l-4 border-l-indigo-500">
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Current Membership</h2>
          <div className="flex flex-wrap items-center gap-3 mb-2">
            <span className="px-3 py-1 bg-indigo-100 text-indigo-700 rounded-full text-sm font-medium">
              {currentMembership.membershipType.replace("_", " ")}
            </span>
            <span className={`px-3 py-1 rounded-full text-sm font-medium ${getTierInfo(currentMembership.amenityTier).color}`}>
              {currentMembership.amenityTier}
            </span>
          </div>
          <p className="text-sm text-gray-600">
            <strong>{currentMembership.remainingDays}</strong> days remaining
            <span className="text-gray-400 mx-2">•</span>
            Expires: {formatDate(currentMembership.endsAt)}
          </p>
        </Card>
      )}

      {/* Alerts */}
      {error && <ErrorAlert className="mb-6">{error}</ErrorAlert>}
      {success && (
        <SuccessAlert className="mb-6">
          Membership purchased successfully! Your new membership is now active.
        </SuccessAlert>
      )}

      {/* Duration Selection */}
      <div className="mb-8">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Select Duration</h2>
        <div className="flex flex-wrap gap-3">
          {membershipTypes.map(({ type, label, duration }) => (
            <button
              key={type}
              onClick={() => setSelectedType(type)}
              className={`px-4 py-2 rounded-lg border-2 transition-colors ${
                selectedType === type
                  ? "border-indigo-600 bg-indigo-50 text-indigo-700"
                  : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <div className="font-medium">{label}</div>
              <div className="text-xs text-gray-500">{duration}</div>
            </button>
          ))}
        </div>
      </div>

      {/* Tier Selection */}
      <h2 className="text-lg font-semibold text-gray-900 mb-4">Select Tier</h2>
      <div className="grid md:grid-cols-3 gap-6 mb-8">
        {amenityTiers.map(({ tier }) => {
          const tierInfo = getTierInfo(tier);
          const price = getPrice(tier, selectedType);
          const isSelected = selectedTier === tier;

          return (
            <div
              key={tier}
              onClick={() => setSelectedTier(tier)}
              className={`bg-white rounded-lg shadow-sm p-6 cursor-pointer transition-all ${
                isSelected
                  ? "ring-2 ring-indigo-600 shadow-md"
                  : "hover:shadow-md"
              }`}
            >
              <div className="flex justify-between items-start mb-4">
                <span className={`px-3 py-1 rounded-full text-sm font-medium ${tierInfo.color}`}>
                  {tier}
                </span>
                {isSelected && (
                  <span className="text-indigo-600">
                    <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                  </span>
                )}
              </div>

              <div className="mb-4">
                <span className="text-3xl font-bold text-gray-900">${price}</span>
                <span className="text-gray-500 ml-1">
                  / {membershipTypes.find((t) => t.type === selectedType)?.duration}
                </span>
              </div>

              <ul className="space-y-2">
                {tierInfo.features.map((feature) => (
                  <li key={feature} className="flex items-center text-sm text-gray-600">
                    <svg className="w-4 h-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    {feature}
                  </li>
                ))}
              </ul>
            </div>
          );
        })}
      </div>

      {/* Purchase Button */}
      <div className="flex justify-center">
        <Button
          onClick={handlePurchase}
          loading={creating}
          loadingText="Processing..."
          size="lg"
          className="px-12"
        >
          Purchase {selectedTier} {selectedType.replace("_", " ")} - ${getPrice(selectedTier, selectedType)}
        </Button>
      </div>
    </div>
  );
}
