---
artifact: content_map
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "VoiceFlowz"
created: "2026-05-04"
updated: "2026-05-04"
status: draft
source_skill: sf-docs
scope: "content-routing"
owner: "Diane"
confidence: medium
risk_level: medium
docs_impact: yes
security_impact: yes
content_surfaces:
  - "README.md"
  - "PRODUCT.md"
  - "BUSINESS.md"
  - "BRANDING.md"
  - "docs/PLATFORM_BEHAVIOR.md"
  - "docs/OVERLAY_ANDROID.md"
  - "docs/VERIFICATION.md"
  - "docs/API_SUPABASE.md"
  - "docs/API.md"
evidence:
  - "Bootstrapped during Android IME chantier governance gate."
depends_on:
  - "BUSINESS.md@0.1.0"
  - "PRODUCT.md@0.1.0"
  - "BRANDING.md@0.1.0"
  - "GUIDELINES.md@0.1.0"
supersedes: []
next_review: "2026-06-04"
next_step: "/sf-docs editorial"
---

# Content Map — VoiceFlowz

VoiceFlowz currently has repository documentation, not a public marketing site
content tree. Public/user-facing claims live mainly in README and project docs.

## Surfaces

| Surface | Path | Audience | Update trigger |
| --- | --- | --- | --- |
| README | `README.md` | Developers/operators | Setup, supported platform, verification, or feature capability changes |
| Product context | `PRODUCT.md` | Product/build agents | Target workflow, non-goal, security, or platform promise changes |
| Business context | `BUSINESS.md` | Product/GTM agents | Market, model, offer, or positioning changes |
| Brand context | `BRANDING.md` | Copy/design agents | Voice, visual, or public-claim boundary changes |
| Platform docs | `docs/PLATFORM_BEHAVIOR.md`, `docs/OVERLAY_ANDROID.md`, `docs/VERIFICATION.md` | Developers/operators | Platform capability, permission, setup, or QA matrix changes |
| API docs | `docs/API_SUPABASE.md`, `docs/API.md` | Developers/operators | Schema, RLS, source, realtime, or repository changes |

## Editorial Governance

`docs/editorial/` is not bootstrapped yet because this repo has no public site
content tree. If README/product docs become distribution copy or a site is added,
run `/sf-docs editorial` and create the public-surface map and claim register.

## Maintenance Rule

Update this map when a new public surface, support/onboarding document, website,
pricing page, FAQ, or user-facing claim registry is added.
