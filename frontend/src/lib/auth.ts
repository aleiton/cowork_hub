// =============================================================================
// AUTH API
// =============================================================================
// Shared authentication functions for login and signup.

import { setAuthToken, apolloClient } from "./apollo-client";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000";

interface AuthResponse {
  success: boolean;
  error?: string;
  errors?: string[];
}

interface SignUpParams {
  email: string;
  password: string;
  passwordConfirmation: string;
}

interface SignInParams {
  email: string;
  password: string;
}

export async function signUp({ email, password, passwordConfirmation }: SignUpParams): Promise<AuthResponse> {
  try {
    const response = await fetch(`${API_URL}/users`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify({
        user: { email, password, password_confirmation: passwordConfirmation },
      }),
    });

    const authHeader = response.headers.get("Authorization");

    if (response.ok && authHeader) {
      setAuthToken(authHeader.replace("Bearer ", ""));
      await apolloClient.resetStore();
      return { success: true };
    }

    const data = await response.json();
    if (data.errors) {
      const errorMessages = Object.entries(data.errors).flatMap(
        ([field, messages]) =>
          (messages as string[]).map((msg) => `${field.charAt(0).toUpperCase() + field.slice(1)} ${msg}`)
      );
      return { success: false, errors: errorMessages };
    }

    return { success: false, error: data.error || "Registration failed. Please try again." };
  } catch {
    return { success: false, error: "Unable to connect to server. Please try again." };
  }
}

export async function signIn({ email, password }: SignInParams): Promise<AuthResponse> {
  try {
    const response = await fetch(`${API_URL}/users/sign_in`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify({ user: { email, password } }),
    });

    const authHeader = response.headers.get("Authorization");

    if (response.ok && authHeader) {
      setAuthToken(authHeader.replace("Bearer ", ""));
      await apolloClient.resetStore();
      return { success: true };
    }

    const data = await response.json();
    return { success: false, error: data.error || "Invalid email or password" };
  } catch {
    return { success: false, error: "Unable to connect to server. Please try again." };
  }
}
