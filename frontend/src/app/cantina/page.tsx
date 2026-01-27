// =============================================================================
// CANTINA PAGE
// =============================================================================

"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useMutation } from "@apollo/client/react";
import { GET_ME_WITH_MEMBERSHIP } from "@/graphql/queries/user";
import { CREATE_CANTINA_SUBSCRIPTION, USE_CANTINA_CREDIT } from "@/graphql/mutations/memberships";
import { isAuthenticated } from "@/lib/apollo-client";
import { CantinaPlanType, MeWithMembershipQueryResult, CreateCantinaSubscriptionResult, UseCantinaCredResult } from "@/types";
import { Button, Card, ErrorAlert, SuccessAlert } from "@/components/ui";
import { formatDate } from "@/lib/format";

const cantinaPlans: { type: CantinaPlanType; label: string; meals: number; price: number; description: string }[] = [
  { type: "FIVE_MEALS", label: "5 Meals", meals: 5, price: 40, description: "Perfect for occasional visits" },
  { type: "TEN_MEALS", label: "10 Meals", meals: 10, price: 75, description: "Great for weekly lunches" },
  { type: "TWENTY_MEALS", label: "20 Meals", meals: 20, price: 140, description: "Best value for daily use" },
];

export default function CantinaPage() {
  const router = useRouter();
  const [selectedPlan, setSelectedPlan] = useState<CantinaPlanType>("TEN_MEALS");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // Auth check
  useEffect(() => {
    if (!isAuthenticated()) {
      router.push("/login");
    }
  }, [router]);

  // Fetch current subscription
  const { data, loading, refetch } = useQuery<MeWithMembershipQueryResult>(GET_ME_WITH_MEMBERSHIP, {
    skip: typeof window === "undefined" || !isAuthenticated(),
  });

  // Create subscription mutation
  const [createSubscription, { loading: creating }] = useMutation<CreateCantinaSubscriptionResult>(CREATE_CANTINA_SUBSCRIPTION, {
    onCompleted: (data) => {
      if (data?.createCantinaSubscription.errors?.length > 0) {
        setError(data.createCantinaSubscription.errors.join(", "));
      } else {
        setSuccess("Subscription created successfully!");
        setError("");
        refetch();
      }
    },
    onError: (err) => {
      setError(err.message);
    },
  });

  // Use credit mutation
  const [consumeCredit, { loading: consumingCredit }] = useMutation<UseCantinaCredResult>(USE_CANTINA_CREDIT, {
    onCompleted: (data) => {
      if (data?.useCantinaCredit.errors?.length > 0) {
        setError(data.useCantinaCredit.errors.join(", "));
      } else {
        setSuccess("Meal credit used! Enjoy your meal.");
        setError("");
        refetch();
      }
    },
    onError: (err) => {
      setError(err.message);
    },
  });

  const subscription = data?.myCantinaSubscription;

  const handleSubscribe = async () => {
    setError("");
    setSuccess("");
    await createSubscription({
      variables: { planType: selectedPlan },
    });
  };

  const handleUseCredit = async () => {
    setError("");
    setSuccess("");
    await consumeCredit();
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
        <h1 className="text-3xl font-bold text-gray-900">Cantina</h1>
        <p className="text-gray-600 mt-1">Meal plans for our on-site cafeteria</p>
      </div>

      {/* Current Subscription */}
      {subscription && (
        <Card className="mb-8 border-l-4 border-l-orange-500">
          <div className="flex flex-wrap justify-between items-start gap-4">
            <div>
              <h2 className="text-lg font-semibold text-gray-900 mb-3">Your Subscription</h2>
              <div className="flex items-baseline gap-2 mb-2">
                <span className="text-4xl font-bold text-gray-900">{subscription.mealsRemaining}</span>
                <span className="text-gray-500">meals remaining</span>
              </div>
              <p className="text-sm text-gray-600">
                <span className="px-2 py-1 bg-orange-100 text-orange-700 rounded text-xs font-medium mr-2">
                  {subscription.planType}
                </span>
                Renews: {formatDate(subscription.renewsAt)}
              </p>
            </div>
            <Button
              onClick={handleUseCredit}
              loading={consumingCredit}
              loadingText="Processing..."
              disabled={subscription.mealsRemaining <= 0}
              variant={subscription.mealsRemaining > 0 ? "primary" : "secondary"}
            >
              Use Meal Credit
            </Button>
          </div>
        </Card>
      )}

      {/* Alerts */}
      {error && <ErrorAlert className="mb-6">{error}</ErrorAlert>}
      {success && <SuccessAlert className="mb-6">{success}</SuccessAlert>}

      {/* Plan Selection */}
      <h2 className="text-lg font-semibold text-gray-900 mb-4">
        {subscription ? "Change Plan" : "Choose a Plan"}
      </h2>
      <div className="grid md:grid-cols-3 gap-6 mb-8">
        {cantinaPlans.map(({ type, label, meals, price, description }) => {
          const isSelected = selectedPlan === type;
          const isCurrentPlan = subscription?.planType === type;

          return (
            <div
              key={type}
              onClick={() => setSelectedPlan(type)}
              className={`bg-white rounded-lg shadow-sm p-6 cursor-pointer transition-all relative ${
                isSelected
                  ? "ring-2 ring-indigo-600 shadow-md"
                  : "hover:shadow-md"
              }`}
            >
              {isCurrentPlan && (
                <div className="absolute -top-3 left-4 px-2 py-1 bg-orange-500 text-white text-xs font-medium rounded">
                  Current Plan
                </div>
              )}

              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="text-xl font-bold text-gray-900">{label}</h3>
                  <p className="text-sm text-gray-500">{description}</p>
                </div>
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
                <span className="text-gray-500 ml-1">/ month</span>
              </div>

              <div className="flex items-center text-gray-600">
                <span className="text-2xl mr-2">🍽️</span>
                <span>
                  <strong>{meals}</strong> meals included
                </span>
              </div>

              <div className="mt-4 pt-4 border-t border-gray-100">
                <p className="text-sm text-gray-500">
                  ${(price / meals).toFixed(2)} per meal
                </p>
              </div>
            </div>
          );
        })}
      </div>

      {/* Subscribe Button */}
      <div className="flex justify-center">
        <Button
          onClick={handleSubscribe}
          loading={creating}
          loadingText="Processing..."
          size="lg"
          className="px-12"
        >
          {subscription ? "Change to" : "Subscribe to"} {cantinaPlans.find((p) => p.type === selectedPlan)?.label} Plan - $
          {cantinaPlans.find((p) => p.type === selectedPlan)?.price}
        </Button>
      </div>

      {/* Info Section */}
      <div className="mt-12 bg-gray-50 rounded-lg p-6">
        <h3 className="font-semibold text-gray-900 mb-3">How it works</h3>
        <ul className="space-y-2 text-sm text-gray-600">
          <li className="flex items-start">
            <span className="mr-2">1.</span>
            Choose a meal plan that fits your needs
          </li>
          <li className="flex items-start">
            <span className="mr-2">2.</span>
            Use the &quot;Use Meal Credit&quot; button when you&apos;re at the cantina
          </li>
          <li className="flex items-start">
            <span className="mr-2">3.</span>
            Show the confirmation to the staff and enjoy your meal
          </li>
          <li className="flex items-start">
            <span className="mr-2">4.</span>
            Unused meals roll over until your renewal date
          </li>
        </ul>
      </div>
    </div>
  );
}
