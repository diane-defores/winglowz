import type { APIRoute } from "astro";
import { ConvexHttpClient } from "convex/browser";
import { FieldValue } from "firebase-admin/firestore";
import { getFirebaseAdminState } from "@/lib/firebaseAdmin";
import {
  buildFirestoreSuiteAccessMirror,
  getBearerTokenFromAuthorizationHeader,
  isTrustedFirebaseIdTokenClaims,
  resolveBridgeEnvironment,
} from "@/lib/suiteBridge";

export const prerender = false;

const JSON_HEADERS = { "Content-Type": "application/json" };

export const POST: APIRoute = async ({ request }) => {
  const env = import.meta.env as Record<string, string | undefined>;
  const bridgeSecret = env.SUITE_BRIDGE_CONVEX_SECRET;

  if (!bridgeSecret) {
    return new Response(
      JSON.stringify({
        status: "unavailable",
        error: "bridge_secret_not_configured",
      }),
      { status: 503, headers: JSON_HEADERS }
    );
  }

  const firebaseAdmin = getFirebaseAdminState(env);
  if (!firebaseAdmin) {
    return new Response(
      JSON.stringify({
        status: "unavailable",
        error: "firebase_admin_not_configured",
      }),
      { status: 503, headers: JSON_HEADERS }
    );
  }

  const bearerToken = getBearerTokenFromAuthorizationHeader(
    request.headers.get("authorization")
  );
  if (!bearerToken) {
    return new Response(
      JSON.stringify({ status: "unauthorized", error: "missing_bearer_token" }),
      { status: 401, headers: JSON_HEADERS }
    );
  }

  const convexUrl = env.PUBLIC_CONVEX_URL;
  if (!convexUrl || convexUrl === "https://PLACEHOLDER.convex.cloud") {
    return new Response(
      JSON.stringify({ status: "unavailable", error: "convex_not_configured" }),
      { status: 503, headers: JSON_HEADERS }
    );
  }

  let decodedToken;
  try {
    decodedToken = await firebaseAdmin.auth.verifyIdToken(bearerToken, true);
  } catch {
    console.error("Firebase bridge token verification failed.");
    return new Response(
      JSON.stringify({ status: "unauthorized", error: "invalid_firebase_token" }),
      { status: 401, headers: JSON_HEADERS }
    );
  }

  if (!isTrustedFirebaseIdTokenClaims(decodedToken, firebaseAdmin.projectId)) {
    return new Response(
      JSON.stringify({
        status: "unauthorized",
        error: "invalid_token_audience_issuer_or_subject",
      }),
      { status: 401, headers: JSON_HEADERS }
    );
  }

  const convex = new ConvexHttpClient(convexUrl);

  try {
    const snapshot = await convex.mutation(
      "bridge:upsertFirebaseIdentity" as never,
      {
        firebaseUid: decodedToken.uid,
        firebaseEmail: decodedToken.email,
        environment: resolveBridgeEnvironment(env.NODE_ENV),
        sourceRef: request.headers.get("x-request-id") ?? undefined,
        bridgeSecret,
      } as never
    );

    const mirror = buildFirestoreSuiteAccessMirror({
      globalUserId: (snapshot as { globalUserId: string }).globalUserId,
      entitlements: (snapshot as {
        entitlements: { productId: string; status: string; plan?: string | null }[];
      }).entitlements,
    });

    await firebaseAdmin.firestore
      .collection("suiteAccess")
      .doc(decodedToken.uid)
      .set(
        {
          ...mirror,
          source: "suite_bridge_api",
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

    return new Response(JSON.stringify(snapshot), {
      status: 200,
      headers: JSON_HEADERS,
    });
  } catch (error) {
    console.error("Firebase bridge sync failed:", error);
    return new Response(
      JSON.stringify({ status: "error", error: "bridge_write_failed" }),
      { status: 500, headers: JSON_HEADERS }
    );
  }
};
