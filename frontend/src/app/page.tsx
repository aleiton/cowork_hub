// =============================================================================
// HOME PAGE
// =============================================================================
//
// Landing page for CoworkHub.
// Redirects authenticated users to the dashboard.
//
// =============================================================================

"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { isAuthenticated } from "@/lib/apollo-client";

// Feature cards data
const features = [
  {
    title: "Flexible Workspaces",
    description: "From hot desks to private offices, find the perfect space for your work style.",
    icon: "🏢",
    href: "/workspaces",
  },
  {
    title: "Maker Spaces",
    description: "Access 3D printers, laser cutters, woodworking tools, and more.",
    icon: "🔧",
    href: "/workshops",
  },
  {
    title: "Community",
    description: "Connect with fellow creators, entrepreneurs, and remote workers.",
    icon: "👥",
    href: "/workspaces",
  },
  {
    title: "Cafeteria",
    description: "Fuel your creativity with our on-site cantina and meal subscriptions.",
    icon: "🍽️",
    href: "/dashboard",
  },
];

// Workspace type cards
const workspaceTypes = [
  {
    type: "Hot Desks",
    description: "Flexible seating in our open areas",
    price: "From $8/hour",
    image: "bg-gradient-to-br from-blue-400 to-blue-600",
  },
  {
    type: "Private Offices",
    description: "Dedicated space for focused work",
    price: "From $20/hour",
    image: "bg-gradient-to-br from-purple-400 to-purple-600",
  },
  {
    type: "Meeting Rooms",
    description: "Professional spaces for collaboration",
    price: "From $25/hour",
    image: "bg-gradient-to-br from-green-400 to-green-600",
  },
  {
    type: "Workshops",
    description: "Equipped maker spaces with pro tools",
    price: "From $25/hour",
    image: "bg-gradient-to-br from-orange-400 to-orange-600",
  },
];

export default function HomePage() {
  const router = useRouter();

  useEffect(() => {
    if (isAuthenticated()) {
      router.push("/dashboard");
    }
  }, [router]);

  return (
    <div>
      {/* Hero Section */}
      <section className="bg-linear-to-br from-indigo-600 via-indigo-700 to-purple-800 text-white">
        <div className="container mx-auto px-4 py-24">
          <div className="max-w-3xl">
            <h1 className="text-5xl font-bold mb-6">
              Where Work Meets
              <span className="text-indigo-200"> Creativity</span>
            </h1>
            <p className="text-xl text-indigo-100 mb-8">
              CoworkHub is a hybrid coworking and maker space. Book desks,
              meeting rooms, or fully-equipped workshops. Join a community
              of creators building the future.
            </p>
            <div className="flex flex-wrap gap-4">
              <Link
                href="/workspaces"
                className="px-8 py-3 bg-white text-indigo-700 font-semibold rounded-lg hover:bg-indigo-50 transition-colors"
              >
                Browse Workspaces
              </Link>
              <Link
                href="/signup"
                className="px-8 py-3 bg-indigo-500 text-white font-semibold rounded-lg hover:bg-indigo-400 transition-colors border border-indigo-400"
              >
                Get Started
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12 text-gray-900">
            Everything You Need
          </h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature) => (
              <Link
                key={feature.title}
                href={feature.href}
                className="p-6 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors group"
              >
                <div className="text-4xl mb-4">{feature.icon}</div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2 group-hover:text-indigo-600 transition-colors">
                  {feature.title}
                </h3>
                <p className="text-gray-600">{feature.description}</p>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Workspace Types Section */}
      <section className="py-20 bg-gray-50">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-4 text-gray-900">
            Find Your Space
          </h2>
          <p className="text-center text-gray-600 mb-12 max-w-2xl mx-auto">
            Whether you need a quiet corner to focus or a fully-equipped workshop
            to bring your ideas to life, we have the perfect space for you.
          </p>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {workspaceTypes.map((ws) => (
              <div
                key={ws.type}
                className="bg-white rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow"
              >
                <div className={`h-32 ${ws.image}`} />
                <div className="p-5">
                  <h3 className="font-semibold text-gray-900 mb-1">{ws.type}</h3>
                  <p className="text-sm text-gray-600 mb-3">{ws.description}</p>
                  <p className="text-sm font-medium text-indigo-600">{ws.price}</p>
                </div>
              </div>
            ))}
          </div>
          <div className="text-center mt-10">
            <Link
              href="/workspaces"
              className="inline-flex items-center px-6 py-3 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 transition-colors"
            >
              View All Workspaces
              <svg
                className="w-4 h-4 ml-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </Link>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-indigo-600">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold text-white mb-4">
            Ready to Get Started?
          </h2>
          <p className="text-indigo-100 mb-8 max-w-xl mx-auto">
            Join CoworkHub today and get access to all our spaces, equipment,
            and community perks.
          </p>
          <Link
            href="/signup"
            className="inline-block px-8 py-3 bg-white text-indigo-600 font-semibold rounded-lg hover:bg-indigo-50 transition-colors"
          >
            Create Free Account
          </Link>
        </div>
      </section>
    </div>
  );
}
