import { shouldBypassClerkMiddleware } from "@/middleware/authRouting";

describe("auth routing middleware", () => {
  test("bypasses Clerk for server-owned API routes", () => {
    expect(shouldBypassClerkMiddleware("/api/bridge/firebase")).toBe(true);
    expect(shouldBypassClerkMiddleware("/api/bridge/sync")).toBe(true);
    expect(shouldBypassClerkMiddleware("/api/clerk/webhook")).toBe(true);
    expect(shouldBypassClerkMiddleware("/api/polar/webhook")).toBe(true);
    expect(shouldBypassClerkMiddleware("/api/newsletter/subscribe")).toBe(true);
  });

  test("keeps Clerk for account pages and Clerk-backed checkout", () => {
    expect(shouldBypassClerkMiddleware("/api/polar/checkout")).toBe(false);
    expect(shouldBypassClerkMiddleware("/dashboard")).toBe(false);
    expect(shouldBypassClerkMiddleware("/signin")).toBe(false);
  });
});
