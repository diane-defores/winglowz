export const SUITE_PRODUCT_ALLOWLIST = [
  "winflowz_app",
  "winflowz_formation",
  "tubeflow",
] as const;

const ACTIVE_ENTITLEMENT_STATUSES = new Set(["active", "trialing"]);
const FIRESTORE_ENTITLEMENT_PRODUCTS = ["winflowz_app"] as const;

type BridgeEntitlement = {
  productId: string;
  status: string;
  plan?: string | null;
};
const ALLOWED_PRODUCT_SET = new Set<string>(SUITE_PRODUCT_ALLOWLIST);

export type BridgeEntitlementSnapshot = {
  productId: string;
  plan: string;
  status: string;
};

export function isAllowedSuiteProduct(productId: string): boolean {
  return ALLOWED_PRODUCT_SET.has(productId);
}

export function isActiveAccessStatus(status: string): boolean {
  return ACTIVE_ENTITLEMENT_STATUSES.has(status);
}

export function hasActiveEntitlement(
  entitlements: BridgeEntitlement[],
  productId: string
): boolean {
  return entitlements.some(
    (entry) =>
      entry.productId === productId && isActiveAccessStatus(entry.status)
  );
}

export function buildFirestoreSuiteAccessMirror({
  globalUserId,
  entitlements,
}: {
  globalUserId: string;
  entitlements: BridgeEntitlement[];
}) {
  const products = Object.fromEntries(
    FIRESTORE_ENTITLEMENT_PRODUCTS.map((productId) => {
      const entitlement = entitlements.find(
        (entry) =>
          entry.productId === productId && isActiveAccessStatus(entry.status)
      );

      return [
        productId,
        {
          active: entitlement != null,
          status: entitlement?.status ?? "inactive",
          plan: entitlement?.plan ?? null,
        },
      ];
    })
  );

  return {
    globalUserId,
    products,
  };
}

export function maskProviderAccountId(value: string): string {
  if (value.length <= 6) {
    return `${value[0] ?? ""}***${value[value.length - 1] ?? ""}`;
  }

  return `${value.slice(0, 3)}***${value.slice(-3)}`;
}

export function getBearerTokenFromAuthorizationHeader(
  authorizationHeader: string | null
): string | null {
  if (!authorizationHeader) {
    return null;
  }

  const parts = authorizationHeader.trim().split(/\s+/);
  if (parts.length !== 2 || parts[0]?.toLowerCase() !== "bearer" || !parts[1]) {
    return null;
  }

  return parts[1];
}

type FirebaseIdTokenClaimsLike = {
  aud?: unknown;
  iss?: unknown;
  sub?: unknown;
  uid?: unknown;
};

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

export function isTrustedFirebaseIdTokenClaims(
  claims: FirebaseIdTokenClaimsLike,
  projectId: string
): boolean {
  const expectedIssuer = `https://securetoken.google.com/${projectId}`;
  const subject = claims.sub ?? claims.uid;

  return (
    isNonEmptyString(projectId) &&
    claims.aud === projectId &&
    claims.iss === expectedIssuer &&
    isNonEmptyString(subject)
  );
}

export function resolveBridgeEnvironment(nodeEnv: string | undefined): string {
  if (nodeEnv === "development" || nodeEnv === "test") {
    return nodeEnv;
  }
  return "production";
}

function cleanSecret(value: string | undefined): string | null {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

export function getBridgeEndpointSecret(
  env: Record<string, string | undefined>
): string | null {
  return cleanSecret(env.SUITE_BRIDGE_SYNC_SECRET) ?? cleanSecret(env.SUITE_BRIDGE_CONVEX_SECRET);
}

export function getConvexBridgeSecret(
  env: Record<string, string | undefined>
): string | null {
  return cleanSecret(env.SUITE_BRIDGE_CONVEX_SECRET);
}

export function isValidGlobalUserId(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

export function parseSyncRequestBody(body: unknown): { globalUserId: string } | null {
  if (!body || typeof body !== "object") {
    return null;
  }

  const globalUserId = (body as Record<string, unknown>).globalUserId;
  if (!isValidGlobalUserId(globalUserId)) {
    return null;
  }

  return { globalUserId: globalUserId.trim() };
}
