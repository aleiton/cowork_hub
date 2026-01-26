// =============================================================================
// ROOT LAYOUT
// =============================================================================
//
// This is the root layout for the entire application.
// In Next.js App Router, layouts wrap all pages in their directory and below.
//
// KEY CONCEPTS:
// - This file defines the <html> and <body> tags
// - Metadata here applies to all pages (can be overridden per-page)
// - Providers (like ApolloProvider) wrap the children here
// - This is a Server Component, but can render Client Components
//
// =============================================================================

import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { ApolloProvider } from "@/components/providers/ApolloProvider";
import { Navigation } from "@/components/layout/Navigation";

// -----------------------------------------------------------------------------
// FONTS
// -----------------------------------------------------------------------------
// Next.js automatically optimizes fonts (self-hosting, no layout shift)

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

// -----------------------------------------------------------------------------
// METADATA
// -----------------------------------------------------------------------------
// Defines SEO metadata for the entire site

export const metadata: Metadata = {
  title: {
    template: "%s | CoworkHub",
    default: "CoworkHub - Coworking & Maker Space",
  },
  description: "Book workspaces, access maker tools, and join our creative community.",
};

// -----------------------------------------------------------------------------
// ROOT LAYOUT COMPONENT
// -----------------------------------------------------------------------------

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased bg-gray-50 min-h-screen`}
      >
        {/* ApolloProvider makes GraphQL client available to all components */}
        <ApolloProvider>
          <div className="flex flex-col min-h-screen">
            <Navigation />
            <main className="flex-1">
              {children}
            </main>
            <footer className="bg-gray-800 text-gray-400 py-8">
              <div className="container mx-auto px-4 text-center text-sm">
                © 2024 CoworkHub. Built with Rails + GraphQL + Next.js
              </div>
            </footer>
          </div>
        </ApolloProvider>
      </body>
    </html>
  );
}
