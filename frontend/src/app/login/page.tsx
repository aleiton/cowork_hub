// =============================================================================
// LOGIN PAGE
// =============================================================================

"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { setAuthToken, apolloClient } from "@/lib/apollo-client";
import { Input, Button, ErrorAlert, Alert, Card } from "@/components/ui";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const response = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000"}/users/sign_in`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json", Accept: "application/json" },
          body: JSON.stringify({ user: { email, password } }),
        }
      );

      const authHeader = response.headers.get("Authorization");

      if (response.ok && authHeader) {
        setAuthToken(authHeader.replace("Bearer ", ""));
        await apolloClient.resetStore();
        router.push("/dashboard");
      } else {
        const data = await response.json();
        setError(data.error || "Invalid email or password");
      }
    } catch {
      setError("Unable to connect to server. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center py-12 px-4">
      <div className="max-w-md w-full">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Welcome back</h1>
          <p className="mt-2 text-gray-600">Sign in to your CoworkHub account</p>
        </div>

        <Card>
          <form onSubmit={handleSubmit} className="space-y-6">
            <Input
              label="Email address"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
              placeholder="you@example.com"
            />

            <Input
              label="Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              autoComplete="current-password"
              placeholder="••••••••"
            />

            {error && <ErrorAlert>{error}</ErrorAlert>}

            <Button type="submit" loading={loading} loadingText="Signing in..." className="w-full">
              Sign in
            </Button>
          </form>

          <div className="mt-6 relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-200" />
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-white text-gray-500">Don&apos;t have an account?</span>
            </div>
          </div>

          <div className="mt-6">
            <Button href="/signup" variant="outline" className="w-full">
              Create an account
            </Button>
          </div>
        </Card>

        <Alert variant="info" className="mt-6">
          <p className="font-medium mb-1">Demo Credentials</p>
          <p><strong>Admin:</strong> admin@coworkhub.com</p>
          <p><strong>Member:</strong> member1@example.com</p>
          <p className="mt-1">Password: <code className="bg-blue-100 px-1 rounded">password123</code></p>
        </Alert>
      </div>
    </div>
  );
}
