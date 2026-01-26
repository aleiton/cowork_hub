// =============================================================================
// APOLLO CLIENT CONFIGURATION
// =============================================================================
//
// Apollo Client is a GraphQL client that manages:
// - Fetching data from the GraphQL API
// - Caching results (so repeated queries don't hit the server)
// - Managing local state
// - Handling authentication via headers
//
// WHY APOLLO CLIENT?
// 1. Normalized cache - automatically updates related data across queries
// 2. Declarative data fetching with React hooks (useQuery, useMutation)
// 3. Built-in loading/error states
// 4. DevTools for debugging queries
//
// =============================================================================

import { ApolloClient, InMemoryCache, createHttpLink } from "@apollo/client";
import { setContext } from "@apollo/client/link/context";

// -----------------------------------------------------------------------------
// HTTP LINK
// -----------------------------------------------------------------------------
// This creates the connection to our GraphQL endpoint.
// In development, the Rails server runs on port 3000.

const httpLink = createHttpLink({
  uri: process.env.NEXT_PUBLIC_GRAPHQL_URL || "http://localhost:3000/graphql",
  // credentials: "include" would send cookies, but we use JWT tokens instead
});

// -----------------------------------------------------------------------------
// AUTH LINK
// -----------------------------------------------------------------------------
// This middleware adds the JWT token to every request.
// The token is stored in localStorage after login.
//
// HOW JWT AUTH WORKS:
// 1. User logs in with email/password
// 2. Server returns a JWT token
// 3. We store the token in localStorage
// 4. Every subsequent request includes the token in the Authorization header
// 5. Server validates the token and identifies the user

const authLink = setContext((_, { headers }) => {
  // Get the token from localStorage (only in browser)
  const token = typeof window !== "undefined" ? localStorage.getItem("token") : null;

  return {
    headers: {
      ...headers,
      // Bearer token format is the standard for JWT
      authorization: token ? `Bearer ${token}` : "",
    },
  };
});

// -----------------------------------------------------------------------------
// APOLLO CLIENT INSTANCE
// -----------------------------------------------------------------------------

export const apolloClient = new ApolloClient({
  // Chain the auth link before the http link
  // Request flow: authLink (add token) -> httpLink (send to server)
  link: authLink.concat(httpLink),

  // InMemoryCache stores query results
  // It uses a normalized cache structure where each object is stored by its ID
  cache: new InMemoryCache({
    typePolicies: {
      // Define how to identify objects in the cache
      // This ensures proper cache updates when objects are modified
      Query: {
        fields: {
          // Workspaces are keyed by their arguments (filters)
          workspaces: {
            // Merge incoming data with existing cache
            merge(existing = [], incoming) {
              return incoming;
            },
          },
        },
      },
    },
  }),

  // Default options for all queries
  defaultOptions: {
    watchQuery: {
      // "cache-and-network" fetches from cache immediately,
      // then updates from network (good UX - fast + fresh)
      fetchPolicy: "cache-and-network",
    },
  },
});

// -----------------------------------------------------------------------------
// HELPER FUNCTIONS
// -----------------------------------------------------------------------------

// Store the JWT token after login
export const setAuthToken = (token: string) => {
  localStorage.setItem("token", token);
};

// Remove the token on logout
export const clearAuthToken = () => {
  localStorage.removeItem("token");
  // Clear the Apollo cache to remove user-specific data
  apolloClient.clearStore();
};

// Check if user is authenticated (has a token)
export const isAuthenticated = () => {
  if (typeof window === "undefined") return false;
  return !!localStorage.getItem("token");
};
