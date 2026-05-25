---
artifact: technical_decision
metadata_schema_version: "1.0"
artifact_version: "1.0.10"
project: "WinFlowz"
created: "2026-05-17"
updated: "2026-05-23"
status: reviewed
source_skill: sf-docs
scope: "suite-authentication-provider-strategy"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "winflows.com / WinFlowz Formation"
  - "WinFlowz Android app"
  - "ReplayGlowz"
  - "VoiceFlowz legacy naming for WinFlowz app"
  - "Clerk"
  - "Firebase Auth"
  - "Firestore"
  - "Convex"
  - "Polar"
  - "Clerk Billing"
depends_on:
  - artifact: "/home/claude/winflowz_app/docs/explorations/2026-05-16-unified-suite-auth.md"
    artifact_version: "1.0.0"
    required_status: "draft"
  - artifact: "/home/claude/winflowz_app/shipflow_data/workflow/specs/unified-suite-authentication.md"
    artifact_version: "1.0.25"
    required_status: "active"
supersedes: []
evidence:
  - "User decision 2026-05-17: document the suite auth decision in the main WinFlowz project because winflows.com presents the full tool suite."
  - "User accepted recommendation: Clerk as long-term suite identity, Firebase retained for Android app until Clerk Flutter/native is proven, entitlements server-owned."
  - "User clarification 2026-05-17: VoiceFlowz / VoiceFlows is the old name of the current WinFlowz app, not a separate product."
  - "Local evidence: WinFlowz Formation uses Clerk/Convex/Polar patterns; WinFlowz Android app targets Firebase Auth/Firestore."
  - "Clerk Billing docs checked 2026-05-17: Billing is beta and has business limitations, so it is not the sole entitlement source yet."
  - "Firebase Flutter/Auth and App Check docs checked 2026-05-17: Firebase is mature for Flutter/Android auth, session persistence, Firestore security and Android attestation."
  - "Implementation tranche 2026-05-20: WinFlowz Formation Convex now has a first server-owned identity/entitlement/event registry, and Polar grants no longer rely on email-only linking."
  - "Implementation tranche 2026-05-21: WinFlowz Formation now handles Polar refund/revoke conservatively, reads course access from the entitlement ledger, and keeps the app bridge state conservative until a server bridge exists."
  - "Implementation tranche 2026-05-21: server bridge endpoint and Flutter bridge client added behind Firebase Admin, `SUITE_BRIDGE_CONVEX_SECRET`, and `SUITE_IDENTITY_BRIDGE_URL`; real provider smoke remains open."
  - "Implementation tranche 2026-05-21: Firestore entitlement enforcement added through a server-owned `suiteAccess/{uid}` mirror and app store selection now requires `winflowz_app` entitlement."
  - "Implementation tranche 2026-05-21: `POST /api/bridge/sync` added so Polar grant/refund/revoke paths can recompute the Firestore `suiteAccess/{firebaseUid}` mirror from Convex by `globalUserId` outside the login bridge path."
  - "Implementation tranche 2026-05-21: `POST /api/bridge/firebase` now verifies Firebase ID tokens with Firebase Admin revocation checks enabled and rejects invalid issuer/audience/subject claims through a shared helper."
  - "Implementation tranche 2026-05-21: canonical support runbook added for operator triage, rollback, escalation and verification."
  - "User correction 2026-05-23: ReplayGlowz is the canonical YouTube product and `product_id=replayglowz`; the old YouTube product naming is legacy only."
  - "Implementation tranche 2026-05-23: `POST /api/bridge/entitlement` added on WinFlowz to verify a Clerk session token and return a redacted ReplayGlowz entitlement snapshot."
next_review: "2026-06-17"
next_step: "/sf-spec unified-suite-authentication provider decision"
---

# Suite Authentication Strategy

## Decision

WinFlowz uses a **suite identity model**:

- **Clerk is the long-term central identity provider for the WinFlowz suite.**
- **Firebase Auth remains the WinFlowz Android app auth adapter for now.**
- **A bridge maps Firebase users to the suite `global_user_id`.**
- **Product access is controlled by server-owned entitlements, not by account existence.**
- **Clerk Billing is promising, but it is not the sole source of truth for access while it remains beta and business-limited.**

This document is the canonical decision for the suite. Product projects should link here instead of copying the full decision.

## Why Clerk Is The Suite Identity

Clerk is the better long-term identity center for the WinFlowz suite because the main web products already lean in that direction:

- WinFlowz Formation has existing Clerk, Convex and Polar work.
- ReplayGlowz has Clerk/Convex/YouTube OAuth history under a former product name.
- Clerk provides strong web account UX: sign-in, sign-up, profile, sessions, dashboard and SSO/OIDC patterns.
- Clerk fits a suite-of-products model better than Firebase as the customer account portal.
- Clerk Billing may later reduce billing integration work, but it must not be treated as production-critical entitlement truth until the beta and business constraints are acceptable.

## Why Firebase Stays In The Android App

Firebase remains the right near-term Android app adapter because:

- Firebase Auth and FlutterFire are mature for Flutter/Android.
- Native session persistence is handled well on Android.
- Google Sign-In, SHA fingerprints, `google-services.json`, Play services and app signing are native to the Android/Firebase workflow.
- Firestore Security Rules and Firebase App Check with Play Integrity fit Android data protection.
- The current WinFlowz app already targets backend-agnostic stores with Firebase Auth/Firestore as first adapter.
- Clerk Flutter exists, but the Flutter package is still beta, so forcing a production Android app onto it would add unnecessary risk.

## Architecture Target

```text
Clerk
  owns: suite identity, web sessions, account portal, suite SSO
  emits: user id, verified email/provider metadata, session tokens

Suite Identity Bridge
  maps: provider account ids -> global_user_id
  records: Firebase uid, Clerk user id, legacy ids, linking status
  forbids: silent email-only merges

Entitlement Ledger
  owns: product_id, plan, status, source, environment, audit events
  sources: Polar, Clerk Billing later, app stores, manual grants, migrations
  forbids: granting access because the account merely exists

Product Backends
  verify: token, issuer, audience, global_user_id, product entitlement
  store: product data under product/user namespaces
```

## Product Boundaries

### WinFlowz Formation / winflows.com

- Uses Clerk as the primary user account system.
- Keeps Convex/Polar integration until a separate migration says otherwise.
- Writes paid course/product access into the server-owned entitlement ledger.

### WinFlowz Android App

- Keeps Firebase Auth as app auth adapter while the app remains Android-first.
- Treats historical VoiceFlowz / VoiceFlows docs as old naming for this app.
- Maps Firebase `uid` to the suite `global_user_id`.
- Uses backend-agnostic interfaces so the app can later migrate to Clerk or another IdP if that becomes safer.
- Must not trust client-sent user ids or product ids.

### ReplayGlowz

- Uses suite identity for account recognition.
- Keeps YouTube OAuth separate from suite identity: YouTube grants are product permissions, not the user's WinFlowz identity.
- Requires product entitlement checks for `product_id=replayglowz` before private ReplayGlowz data access.
- Treats the old YouTube product id only as a legacy alias or migration input; new entitlements must use `replayglowz`.

### Legacy Naming: VoiceFlowz / VoiceFlows

- VoiceFlowz, sometimes written VoiceFlows, is historical naming for the current WinFlowz Android app.
- Do not create a separate `voiceflowz` auth domain or product entitlement from these old references.
- Migrate any useful historical voice, transcription, snippets, clipboard or overlay requirements into WinFlowz app specs before implementation.

## Billing And Entitlements

Clerk Billing can become part of the billing stack later, but the current rule is:

> Billing providers emit events; the WinFlowz entitlement ledger decides access.

Reasons:

- Clerk Billing is currently beta.
- Clerk Billing currently depends on Stripe but is separate from Stripe Billing.
- Some billing behaviors remain limited, including refunds, taxes/VAT, 3D Secure support and currency support.
- The suite may need multiple sources of entitlement: Polar, stores, manual grants, legacy purchases and future Clerk Billing.

## Implementation Status

As of 2026-05-21, the first Formation/app bridge tranche has started:

- Convex defines `globalUsers`, `identityAccounts`, `productEntitlements` and `productAccessEvents`.
- Clerk webhook sync creates a suite identity account through the Clerk provider id, not by merging email matches.
- Polar checkout metadata includes the canonical Formation product id and Clerk user id.
- Polar order grants are idempotent and grant Formation access only when the identity is resolved through a trusted account link or metadata.
- Email-only payment events are held for `pending_review` instead of granting access.
- Polar `order.refunded`, `subscription.revoked` and effective subscription revocations update the Formation entitlement ledger and legacy compatibility fields only when the event is clearly scoped to `winflowz_formation` / `winflowz-training`.
- Formation course gating now prefers the entitlement ledger through Convex and falls back to legacy fields for older deployments.
- `POST /api/bridge/firebase` exists on the WinFlowz Formation server. It requires `Authorization: Bearer <Firebase ID token>`, verifies the token with Firebase Admin revocation checks enabled, checks issuer/audience/subject against the configured Firebase project, then writes the Firebase provider account through Convex.
- The Convex bridge mutation is protected by `SUITE_BRIDGE_CONVEX_SECRET`; if Firebase Admin, Convex, or the bridge secret is missing, the endpoint fails closed and performs no identity write.
- Revoked or disabled Firebase sessions are rejected before Convex identity linking and before Firestore `suiteAccess/{firebaseUid}` writes. This policy has no environment toggle.
- The WinFlowz Android app has a bridge client behind compile-time `SUITE_IDENTITY_BRIDGE_URL`; absent URL, HTTP errors, invalid JSON, unknown products, or schema mismatches produce a conservative local snapshot with no `globalUserId` and no product access.
- The bridge now mirrors `winflowz_app` access into Firestore as a server-owned `suiteAccess/{firebaseUid}` document. Firestore Security Rules check `products.winflowz_app.active == true` before allowing reads or writes under `users/{uid}` product subcollections.
- The WinFlowz Android app also gates Firestore-backed stores on `suiteIdentityProvider.hasAccessTo(winflowz_app)`. A signed-in Firebase user without suite entitlement stays on local stores instead of receiving remote product data.
- Convex exposes a protected entitlement snapshot by `globalUserId`; the internal Formation endpoint `POST /api/bridge/sync` accepts only `{ globalUserId }` plus `x-suite-bridge-secret`, re-reads Convex entitlements, resolves linked Firebase UIDs, and rewrites the Firestore mirror with Firebase Admin.
- Polar grant/refund/revoke webhook handling now calls the sync endpoint after entitlement changes. If the sync fails, webhook handling fails closed with retryable server error semantics instead of silently leaving stale product access.
- `POST /api/bridge/entitlement` exists on the WinFlowz Formation server for ReplayGlowz. It requires `x-suite-entitlement-secret`, `Authorization: Bearer <Clerk session token>`, `CLERK_SECRET_KEY`, `PUBLIC_CONVEX_URL` and `SUITE_BRIDGE_CONVEX_SECRET`; it verifies the Clerk token server-side, resolves the Clerk user in Convex, checks `product_id=replayglowz`, accepts `tubeflow` only as a legacy alias, and returns only `hasAccess`, `globalUserId`, `matchedProductId` and `reasonCode`.

This is not a completed suite auth launch yet. Cross-product smoke tests with real Firebase/Convex provider payloads and deployed `SUITE_BRIDGE_SYNC_URL` proof remain open.

## Non-Negotiables

- One account does not mean access to all products.
- Entitlements are server-owned and audited.
- Product access is denied by default.
- No silent merge based on email alone.
- No tenant-per-product model for consumer suite identity.
- No tokens, secrets, private OAuth payloads or payment payloads in docs/logs/support copy.
- Local, preview, staging and production remain separate auth/billing environments.

## Implementation Gate

Before implementation starts, the suite spec must be updated so `/sf-ready` can pass with:

- provider gate resolved as `Clerk central + Firebase Android bridge`;
- first proof pair selected, preferably WinFlowz Formation + WinFlowz Android app;
- product id canon selected, with `replayglowz` as the YouTube product and the old product id only as a legacy alias.

## Support Runbook

Canonical operator guide:

`/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication-support-runbook.md`

Use that runbook for account recognition without access, duplicate-email linking, entitlement recovery, refund/revoke handling, provider outages, wrong-environment checks, Firebase bridge failures, stale mirror sync, revoked sessions, and ReplayGlowz YouTube OAuth confusion. This strategy document stays architectural.

## Source Links

- WinFlowz app exploration: `/home/claude/winflowz_app/docs/explorations/2026-05-16-unified-suite-auth.md`
- WinFlowz app spec: `/home/claude/winflowz_app/shipflow_data/workflow/specs/unified-suite-authentication.md`
- WinFlowz app architecture: `/home/claude/winflowz_app/shipflow_data/technical/architecture.md`
- Workspace auth playbook: `/home/claude/shipflow_data/specs/master-auth-playbook.md`
- Clerk Billing overview: https://clerk.com/docs/guides/billing/overview
- Firebase Auth for Flutter: https://firebase.google.com/docs/auth/flutter/start
- Firebase App Check with Play Integrity on Android: https://firebase.google.com/docs/app-check/android/play-integrity-provider
