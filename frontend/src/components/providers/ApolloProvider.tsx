// =============================================================================
// APOLLO PROVIDER
// =============================================================================
//
// This component wraps the app with ApolloProvider, making the Apollo Client
// available to all child components via React Context.
//
// WHY A SEPARATE FILE?
// In Next.js App Router, components are Server Components by default.
// Apollo Client requires client-side JavaScript (for caching, state, etc.),
// so we need to mark this as a Client Component with "use client".
//
// The root layout.tsx is a Server Component, but it can render Client Components.
// By isolating the Apollo setup here, we keep the provider client-side while
// letting other parts of the app benefit from Server Components.
//
// =============================================================================

"use client";

// In Apollo Client 4.x, React-specific exports moved to @apollo/client/react
import { ApolloProvider as BaseApolloProvider } from "@apollo/client/react";
import { apolloClient } from "@/lib/apollo-client";

interface Props {
  children: React.ReactNode;
}

export function ApolloProvider({ children }: Props) {
  return (
    <BaseApolloProvider client={apolloClient}>
      {children}
    </BaseApolloProvider>
  );
}
