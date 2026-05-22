import {
  buildFirestoreSuiteAccessMirror,
  getBridgeEndpointSecret,
  getConvexBridgeSecret,
  getBearerTokenFromAuthorizationHeader,
  hasActiveEntitlement,
  isActiveAccessStatus,
  isAllowedSuiteProduct,
  isTrustedFirebaseIdTokenClaims,
  parseSyncRequestBody,
  maskProviderAccountId,
} from "@/lib/suiteBridge";

describe("suiteBridge helpers", () => {
  test("extracts bearer token from authorization header", () => {
    expect(getBearerTokenFromAuthorizationHeader("Bearer abc.def.ghi")).toBe(
      "abc.def.ghi"
    );
    expect(getBearerTokenFromAuthorizationHeader("bearer token123")).toBe("token123");
  });

  test("rejects malformed authorization headers", () => {
    expect(getBearerTokenFromAuthorizationHeader(null)).toBeNull();
    expect(getBearerTokenFromAuthorizationHeader("Token abc")).toBeNull();
    expect(getBearerTokenFromAuthorizationHeader("Bearer")).toBeNull();
    expect(getBearerTokenFromAuthorizationHeader("")).toBeNull();
  });

  test("filters allowed suite products only", () => {
    expect(isAllowedSuiteProduct("winflowz_app")).toBe(true);
    expect(isAllowedSuiteProduct("winflowz_formation")).toBe(true);
    expect(isAllowedSuiteProduct("tubeflow")).toBe(true);
    expect(isAllowedSuiteProduct("legacy_product")).toBe(false);
  });

  test("accepts only active and trialing status for access", () => {
    expect(isActiveAccessStatus("active")).toBe(true);
    expect(isActiveAccessStatus("trialing")).toBe(true);
    expect(isActiveAccessStatus("refunded")).toBe(false);
  });

  test("detects active product entitlement", () => {
    expect(
      hasActiveEntitlement(
        [
          { productId: "winflowz_app", status: "trialing", plan: "monthly" },
          { productId: "tubeflow", status: "refunded", plan: "pro" },
        ],
        "winflowz_app"
      )
    ).toBe(true);
    expect(
      hasActiveEntitlement(
        [{ productId: "winflowz_app", status: "refunded", plan: "monthly" }],
        "winflowz_app"
      )
    ).toBe(false);
  });

  test("builds a Firestore suite access mirror for rules", () => {
    expect(
      buildFirestoreSuiteAccessMirror({
        globalUserId: "gu_123",
        entitlements: [
          { productId: "winflowz_app", status: "active", plan: "pro" },
          { productId: "tubeflow", status: "active", plan: "pro" },
        ],
      })
    ).toEqual({
      globalUserId: "gu_123",
      products: {
        winflowz_app: {
          active: true,
          status: "active",
          plan: "pro",
        },
      },
    });

    expect(
      buildFirestoreSuiteAccessMirror({
        globalUserId: "gu_123",
        entitlements: [
          { productId: "winflowz_app", status: "refunded", plan: "pro" },
        ],
      }).products.winflowz_app.active
    ).toBe(false);
  });

  test("masks provider account identifiers", () => {
    expect(maskProviderAccountId("1234567890")).toBe("123***890");
    expect(maskProviderAccountId("abc12")).toBe("a***2");
  });

  test("resolves bridge endpoint secret with sync override first", () => {
    expect(
      getBridgeEndpointSecret({
        SUITE_BRIDGE_SYNC_SECRET: "sync-secret",
        SUITE_BRIDGE_CONVEX_SECRET: "convex-secret",
      })
    ).toBe("sync-secret");
    expect(
      getBridgeEndpointSecret({
        SUITE_BRIDGE_CONVEX_SECRET: "convex-secret",
      })
    ).toBe("convex-secret");
    expect(
      getBridgeEndpointSecret({
        SUITE_BRIDGE_SYNC_SECRET: "",
        SUITE_BRIDGE_CONVEX_SECRET: "convex-secret",
      })
    ).toBe("convex-secret");
    expect(getBridgeEndpointSecret({})).toBeNull();
  });

  test("keeps Convex bridge secret separate from endpoint override", () => {
    expect(
      getConvexBridgeSecret({
        SUITE_BRIDGE_SYNC_SECRET: "sync-secret",
        SUITE_BRIDGE_CONVEX_SECRET: "convex-secret",
      })
    ).toBe("convex-secret");
    expect(getConvexBridgeSecret({ SUITE_BRIDGE_CONVEX_SECRET: "" })).toBeNull();
  });

  test("parses sync request body with required global user id", () => {
    expect(parseSyncRequestBody({ globalUserId: "gu_123" })).toEqual({
      globalUserId: "gu_123",
    });
    expect(parseSyncRequestBody({ globalUserId: "  gu_123  " })).toEqual({
      globalUserId: "gu_123",
    });
    expect(parseSyncRequestBody({})).toBeNull();
    expect(parseSyncRequestBody({ globalUserId: "" })).toBeNull();
    expect(parseSyncRequestBody(null)).toBeNull();
  });

  test("accepts trusted firebase id token claims", () => {
    expect(
      isTrustedFirebaseIdTokenClaims(
        {
          aud: "winflowz-prod",
          iss: "https://securetoken.google.com/winflowz-prod",
          sub: "firebase-user-123",
        },
        "winflowz-prod"
      )
    ).toBe(true);
  });

  test("rejects firebase claims with invalid issuer/audience/subject", () => {
    expect(
      isTrustedFirebaseIdTokenClaims(
        {
          aud: "wrong-project",
          iss: "https://securetoken.google.com/winflowz-prod",
          sub: "firebase-user-123",
        },
        "winflowz-prod"
      )
    ).toBe(false);

    expect(
      isTrustedFirebaseIdTokenClaims(
        {
          aud: "winflowz-prod",
          iss: "https://securetoken.google.com/wrong-project",
          sub: "firebase-user-123",
        },
        "winflowz-prod"
      )
    ).toBe(false);

    expect(
      isTrustedFirebaseIdTokenClaims(
        {
          aud: "winflowz-prod",
          iss: "https://securetoken.google.com/winflowz-prod",
          sub: "",
        },
        "winflowz-prod"
      )
    ).toBe(false);
  });
});
