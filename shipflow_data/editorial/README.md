---
artifact: editorial_governance
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: winflowz
created: "2026-05-17"
updated: "2026-05-17"
status: reviewed
source_skill: sf-docs
scope: editorial-governance-index
owner: "Diane"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipflow_data/editorial/content-map.md
  - shipflow_data/editorial/public-surface-map.md
  - shipflow_data/editorial/page-intent-map.md
  - shipflow_data/editorial/claim-register.md
  - shipflow_data/editorial/editorial-update-gate.md
  - shipflow_data/editorial/astro-content-schema-policy.md
depends_on:
  - shipflow_data/business/business.md
  - shipflow_data/business/product.md
  - shipflow_data/business/branding.md
  - shipflow_data/business/gtm.md
supersedes: []
evidence:
  - src/content/blog/
  - src/content/docs/
  - src/content/products/
  - src/pages/[...lang]/
next_review: "2026-06-17"
next_step: "/sf-docs editorial audit"
---
# Editorial Governance

## Purpose

This directory is the canonical internal governance layer for public-facing content, claims, page roles, and content-schema constraints.

## Owned Files

- `shipflow_data/editorial/content-map.md`
- `shipflow_data/editorial/public-surface-map.md`
- `shipflow_data/editorial/page-intent-map.md`
- `shipflow_data/editorial/claim-register.md`
- `shipflow_data/editorial/editorial-update-gate.md`
- `shipflow_data/editorial/astro-content-schema-policy.md`
- `shipflow_data/editorial/blog-and-article-surface-policy.md`

## Entrypoints

- `shipflow_data/editorial/content-map.md`
- `shipflow_data/editorial/page-intent-map.md`
- `shipflow_data/editorial/claim-register.md`

## Invariants

- Canonical editorial governance lives under `shipflow_data/editorial/`.
- Runtime content schemas in `src/content/config.ts` override documentation guesses.
- Public claims about pricing, support, performance, social proof, and outcomes require proof tracking.

## Validation

```bash
python3 /home/claude/shipflow/tools/shipflow_metadata_lint.py shipflow_data/editorial/README.md shipflow_data/editorial/content-map.md shipflow_data/editorial/public-surface-map.md shipflow_data/editorial/page-intent-map.md shipflow_data/editorial/claim-register.md shipflow_data/editorial/editorial-update-gate.md shipflow_data/editorial/astro-content-schema-policy.md shipflow_data/editorial/blog-and-article-surface-policy.md
rg -n "Editorial Update Plan|Claim Impact Plan|pending final copy|surface missing|Astro content schema" shipflow_data/editorial/*.md
```

## Maintenance Rule

Update this index whenever a new editorial governance artifact is added, renamed, or retired.

