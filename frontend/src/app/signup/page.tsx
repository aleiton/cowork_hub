// =============================================================================
// SIGNUP PAGE
// =============================================================================

"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { setAuthToken, apolloClient } from "@/lib/apollo-client";
import { Input, Button, ErrorAlert, Card } from "@/components/ui";

export default function SignupPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const [errors, setErrors] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  const validateForm = (): boolean => {
    const newErrors: string[] = [];
    if (password.length < 6) newErrors.push("Password must be at least 6 characters");
    if (password !== passwordConfirmation) newErrors.push("Password confirmation doesn't match");
    setErrors(newErrors);
    return newErrors.length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrors([]);
    if (!validateForm()) return;

    setLoading(true);
    try {
      const response = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000"}/users`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json", Accept: "application/json" },
          body: JSON.stringify({
            user: { email, password, password_confirmation: passwordConfirmation },
          }),
        }
      );

      const authHeader = response.headers.get("Authorization");

      if (response.ok && authHeader) {
        setAuthToken(authHeader.replace("Bearer ", ""));
        await apolloClient.resetStore();
        router.push("/dashboard");
      } else {
        const data = await response.json();
        if (data.errors) {
          const errorMessages = Object.entries(data.errors).flatMap(
            ([field, messages]) =>
              (messages as string[]).map((msg) => `${field.charAt(0).toUpperCase() + field.slice(1)} ${msg}`)
          );
          setErrors(errorMessages);
        } else {
          setErrors([data.error || "Registration failed. Please try again."]);
        }
      }
    } catch {
      setErrors(["Unable to connect to server. Please try again."]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center py-12 px-4">
      <div className="max-w-md w-full">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Create your account</h1>
          <p className="mt-2 text-gray-600">Join CoworkHub and start booking workspaces</p>
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
              autoComplete="new-password"
              placeholder="••••••••"
              minLength={6}
            />

            <Input
              label="Confirm password"
              type="password"
              value={passwordConfirmation}
              onChange={(e) => setPasswordConfirmation(e.target.value)}
              required
              autoComplete="new-password"
              placeholder="••••••••"
            />

            {errors.length > 0 && (
              <ErrorAlert>
                <ul className="list-disc list-inside space-y-1">
                  {errors.map((error, i) => <li key={i}>{error}</li>)}
                </ul>
              </ErrorAlert>
            )}

            <Button type="submit" loading={loading} loadingText="Creating account..." className="w-full">
              Create account
            </Button>

            <p className="text-xs text-gray-500 text-center">
              By signing up, you agree to our Terms of Service and Privacy Policy
            </p>
          </form>

          <div className="mt-6 relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-200" />
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-white text-gray-500">Already have an account?</span>
            </div>
          </div>

          <div className="mt-6">
            <Button href="/login" variant="outline" className="w-full">
              Sign in instead
            </Button>
          </div>
        </Card>

        <div className="mt-8 grid grid-cols-3 gap-4 text-center">
          {[
            { icon: "🏢", label: "Book Workspaces" },
            { icon: "🔧", label: "Access Equipment" },
            { icon: "👥", label: "Join Community" },
          ].map((item) => (
            <div key={item.label}>
              <div className="text-2xl mb-1">{item.icon}</div>
              <p className="text-xs text-gray-600">{item.label}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
