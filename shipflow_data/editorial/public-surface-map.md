---
artifact: editorial_governance
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: winflowz
created: "2026-05-17"
updated: "2026-05-17"
status: reviewed
source_skill: sf-docs
scope: public-surface-map
owner: "Diane"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - src/pages/[...lang]/
  - src/content/blog/
  - src/content/docs/
  - src/content/products/
depends_on:
  - shipflow_data/editorial/content-map.md
supersedes: []
evidence:
  - src/pages/[...lang]/index.astro
  - src/pages/[...lang]/landing.astro
  - src/pages/[...lang]/[windows_mastery].astro
  - src/pages/[...lang]/[products].astro
  - src/pages/[...lang]/[blog].astro
next_review: "2026-06-17"
next_step: "/sf-docs update"
---
# Public Surface Map

## Purpose

Identify the public surfaces that carry product promises, educational claims, or conversion risk.

## Surface Inventory

| Surface | Paths | Audience | Risk | Notes |
| --- | --- | --- | --- | --- |
| Homepage | `/`, `/fr` | broad discovery | high | first-positioning surface |
| Landing page | `/landing`, `/fr/landing` | paid and qualified traffic | high | CTA and proof framing must stay aligned |
| Flagship offer page | `/windows-mastery`, `/fr/maitrise-windows` | high-intent buyers | high | pricing, support, curriculum, and promise claims |
| Product catalog and detail pages | `/products`, `/fr/produits`, localized product routes | buyers comparing offers | high | status, CTA destination, availability |
| Blog index and articles | localized blog routes | top-of-funnel discovery | medium | claim discipline and internal linking |
| Docs and training hub | localized docs routes and dashboard docs | learners and paid users | high | access model, curriculum, and lesson framing |
| Legal pages | privacy, terms, copyright, legal, disclaimer routes | users and regulators | high | policy accuracy matters |

## Update Triggers

- route additions or removals
- CTA changes
- product-status changes
- pricing or support wording changes
- localization changes on commercial pages
- docs access or curriculum changes

## Surface Missing Policy

- If a planned editorial surface is absent, report `surface missing` with the exact surface name.
- Do not invent runtime surfaces that do not exist in `src/pages/` or `src/content/`.

## Maintenance Rule

Update this map when a public route family, content collection, or conversion surface changes materially.

