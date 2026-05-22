---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: winflowz
created: "2026-04-25"
updated: "2026-05-17"
status: reviewed
source_skill: sf-docs
scope: readme
owner: "Diane"
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - package.json
  - shipflow_data/
next_step: /sf-docs update
---
# WinFlowz

WinFlowz is a Windows-first productivity project centered on `Windows Mastery`, with bilingual content, gated learning surfaces, and companion product pages.

Production: https://winflowz.com

## What This Repo Contains

- Astro site with `en` and `fr` routes
- content collections for blog, docs, and products
- flagship route family around `Windows Mastery`
- account, checkout, and newsletter API surfaces under `src/pages/api/*`
- supporting Convex workspace for backend logic

## Quick Start

Requirements:

- Node.js 22.12+
- pnpm

Install and run:

```bash
pnpm install
pnpm dev
```

The local dev server runs on `http://localhost:3011`.

## Tech Stack

- Astro 6
- Astro Starlight
- Tailwind CSS 3
- React islands
- Clerk
- Polar.sh
- Convex
- Resend
- Vercel
- Vitest
- Playwright

## Project Structure

```text
winflowz/
├── src/
│   ├── assets/             # Global styles, scripts, and images
│   ├── components/         # Astro and React UI components
│   ├── content/            # Blog posts, docs, products, and services content
│   ├── i18n/               # Translation dictionaries and route labels
│   ├── layouts/            # Shared Astro layouts
│   ├── lib/                # Shared clients and helpers
│   ├── middleware/         # i18n, CORS, and rate limiting
│   ├── pages/              # Marketing pages, dashboard routes, and API routes
│   ├── types/              # Shared TypeScript types
│   └── utils/              # Routing, docs, UI, and course access helpers
├── convex/                 # Convex HTTP handlers, schema, and functions
├── docs/                   # Supplementary design and CSS docs
├── public/                 # Static assets
├── scripts/                # Project scripts, including Polar product setup
└── tests/                  # Vitest setup and mocks
```

## Main Routes

- `/` and `/fr` — localized homepages
- `/landing` and `/fr/landing` — landing surfaces
- `/windows-mastery` and `/fr/maitrise-windows` — flagship offer surfaces
- `/products` and `/fr/produits` — product catalog routes
- `/dashboard/*` — authenticated surfaces
- `/api/newsletter/*` — newsletter subscribe and unsubscribe
- `/api/polar/*` — checkout/webhook surfaces
- `/api/bridge/firebase` — Firebase ID token bridge to suite identity snapshot
- `/api/bridge/sync` — internal entitlement mirror sync by `globalUserId` + shared secret

## Environment Variables

Copy `.env.example` to `.env` and fill the values required by your environment.

### App and public config

- `SITE`
- `PUBLIC_SITE_URL`
- `PUBLIC_CONVEX_URL`
- `SUITE_API_ALLOWED_ORIGINS` (comma-separated browser origins allowed to call API routes, including the WinFlowz app web origin)
- `PORT`

### Firebase Admin bridge

For `POST /api/bridge/firebase`, the backend verifies Firebase ID tokens with Firebase Admin SDK using revocation checks (`checkRevoked=true`) and fails closed when config is missing.

- `FIREBASE_SERVICE_ACCOUNT_JSON` (recommended single env var, no secrets in repo)
- `FIREBASE_PROJECT_ID` (fallback split config)
- `FIREBASE_CLIENT_EMAIL` (fallback split config)
- `FIREBASE_PRIVATE_KEY` (fallback split config, keep escaped newlines)
- `SUITE_BRIDGE_CONVEX_SECRET` (shared secret required by the Convex bridge mutation)
- `SUITE_BRIDGE_SYNC_SECRET` (optional override; defaults to `SUITE_BRIDGE_CONVEX_SECRET`)

`POST /api/bridge/sync` accepts only:
- header `x-suite-bridge-secret` with the shared secret;
- JSON body `{ "globalUserId": "..." }`.

It recomputes entitlements from Convex (`productEntitlements` source of truth), discovers linked Firebase identity accounts, and writes server-owned Firestore `suiteAccess/{firebaseUid}` documents.

The bridge also writes a server-owned Firestore mirror at `suiteAccess/{firebaseUid}` after Convex entitlement lookup. WinFlowz app Firestore rules use that mirror to allow or deny `winflowz_app` data under `users/{uid}`.

### Clerk

- `PUBLIC_CLERK_PUBLISHABLE_KEY`
- `CLERK_SECRET_KEY`
- `CLERK_WEBHOOK_SECRET`

### Polar

- `POLAR_ACCESS_TOKEN`
- `POLAR_PRODUCT_ID`
- `POLAR_WINFLOWZ_PRODUCT_ID`
- `POLAR_WEBHOOK_SECRET`
- `POLAR_SERVER`
- `SUITE_BRIDGE_SYNC_URL` (used by Convex Polar webhook handling to call `/api/bridge/sync`)

### Resend

- `RESEND_API_KEY`
- `RESEND_AUDIENCE_ID`

## Scripts

Use `pnpm run` to list all scripts in your local checkout.

Common commands:

- `pnpm dev`
- `pnpm build`
- `pnpm preview`

## Documentation

- [CLAUDE.md](./CLAUDE.md) — agent workflow and context rules
- [AGENT.md](./AGENT.md) — short repo execution contract
- [shipflow_data/business/business.md](./shipflow_data/business/business.md) — business contract centered on `Windows Mastery`
- [shipflow_data/business/branding.md](./shipflow_data/business/branding.md) — brand voice and claim policy
- [shipflow_data/business/product.md](./shipflow_data/business/product.md) — product scope and user journey
- [shipflow_data/business/gtm.md](./shipflow_data/business/gtm.md) — go-to-market structure
- [shipflow_data/editorial/content-map.md](./shipflow_data/editorial/content-map.md) — content routing map
- [shipflow_data/technical/guidelines.md](./shipflow_data/technical/guidelines.md) — project-specific engineering guidelines
- [shipflow_data/technical/architecture.md](./shipflow_data/technical/architecture.md) — system boundaries and integrations
- [shipflow_data/technical/context.md](./shipflow_data/technical/context.md) — repository context map
- [docs/DESIGN_SPECIFICATION.md](./docs/DESIGN_SPECIFICATION.md) — design system notes
- [docs/COMPONENT_CLASSES.md](./docs/COMPONENT_CLASSES.md) — reusable CSS class reference

## Deployment

The project is configured for Vercel server output through `@astrojs/vercel`.

Typical production flow:

```bash
pnpm build
```

## Contributing

1. Install dependencies with `pnpm install`.
2. Create `.env` from `.env.example`.
3. Keep docs and localized routes aligned when changing offer or conversion pages.
4. Keep claims in product and marketing docs aligned with observable implementation.
