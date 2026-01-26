// =============================================================================
// USE AUTH HOOK
// =============================================================================
// Centralizes authentication logic: current user, login status, logout.

"use client";

import { useQuery } from "@apollo/client/react";
import { useRouter } from "next/navigation";
import { GET_ME } from "@/graphql/queries/user";
import { clearAuthToken, isAuthenticated } from "@/lib/apollo-client";

export function useAuth() {
  const router = useRouter();

  const { data, loading, error } = useQuery(GET_ME, {
    skip: typeof window === "undefined" || !isAuthenticated(),
    errorPolicy: "ignore",
  });

  const user = data?.me || null;
  const isLoggedIn = !!user;

  const logout = () => {
    clearAuthToken();
    router.push("/");
    // Force page reload to clear Apollo cache
    window.location.href = "/";
  };

  const requireAuth = () => {
    if (!loading && !isLoggedIn) {
      router.push("/login");
    }
  };

  return {
    user,
    loading,
    error,
    isLoggedIn,
    logout,
    requireAuth,
  };
}
