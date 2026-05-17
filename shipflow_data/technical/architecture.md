---
artifact: architecture_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: winflowz
created: "2026-05-17"
updated: "2026-05-17"
status: reviewed
source_skill: sf-docs
scope: architecture
owner: "Diane"
confidence: high
risk_level: medium
docs_impact: yes
security_impact: yes
evidence:
  - package.json
  - src/content/config.ts
  - src/middleware/index.ts
  - src/middleware/i18n.ts
  - src/pages/api/polar/checkout.ts
  - src/pages/api/newsletter/subscribe.ts
  - convex/http.ts
  - convex/schema.ts
linked_systems:
  - src/content
  - src/pages
  - src/middleware
  - convex
  - Clerk
  - Polar
  - Resend
external_dependencies:
  - Astro
  - Vercel
  - Clerk
  - Convex
  - Polar
  - Resend
invariants:
  - English routes remain unprefixed while French routes stay under /fr.
  - Checkout initiation and webhook entitlement updates remain coordinated between Astro routes and Convex.
  - Typed content collections continue to define valid docs, blog, product, and service content.
depends_on:
  - shipflow_data/technical/guidelines.md
  - shipflow_data/business/business.md
  - shipflow_data/business/branding.md
supersedes:
  - ARCHITECTURE.md
next_review: "2026-06-17"
next_step: "pnpm build:check"
---
# Architecture

## Purpose

Describe the stable system boundaries for WinFlowz so technical and docs changes stay aligned with the current runtime.

## Owned Files

- `src/pages/**`
- `src/middleware/**`
- `src/content/config.ts`
- `convex/**`

## Entrypoints

- `src/middleware/index.ts`
- `src/pages/api/polar/checkout.ts`
- `src/pages/api/polar/webhook.ts`
- `src/pages/api/newsletter/subscribe.ts`
- `src/pages/api/clerk/webhook.ts`
- `convex/http.ts`

## System Overview

WinFlowz is a server-rendered Astro application deployed to Vercel. It combines public content, gated training routes, and backend integrations for authentication, billing, newsletter operations, and user entitlements.

## Core Architectural Layers

### Presentation layer

- Astro pages under `src/pages/`
- layouts under `src/layouts/`
- components under `src/components/`
- React islands for interactive UI where needed

### Content layer

Typed collections in `src/content/config.ts` define valid shapes for:

- docs
- products
- blog
- services

### Request orchestration layer

`src/middleware/index.ts` sequences Clerk middleware first, then application middleware that routes `/api/*` through CORS handling and other requests through i18n handling.

### Integration API layer

Astro API routes act as thin integration controllers for:

- Polar checkout
- Polar webhook proxying
- newsletter subscribe and unsubscribe
- Clerk webhook intake

### Backend state layer

Convex is the primary state store. Current tables in `convex/schema.ts` are:

- `users`
- `apiKeys`
- `features`

## Invariants

- English routes remain unprefixed while French routes stay under `/fr`.
- Checkout initiation and webhook entitlement updates remain coordinated between Astro routes and Convex.
- Typed content collections continue to define valid docs, blog, product, and service content.
- API routes should stay thin; durable business state belongs in Convex or provider systems.

## Validation

```bash
pnpm build:check
python3 /home/claude/shipflow/tools/shipflow_metadata_lint.py shipflow_data/technical/architecture.md
```

## Reader Checklist

- Read this doc before changing auth, billing, webhook, or backend boundaries.
- Cross-check route-flow details in `shipflow_data/technical/context-function-tree.md`.
- Cross-check product and claim boundaries before changing public promises.

## Maintenance Rule

Update this doc when architectural boundaries, primary integrations, or persistent data contracts change.
