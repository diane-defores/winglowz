---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "WinFlowz"
created: "2026-05-24"
updated: "2026-05-24"
status: "draft"
source_skill: sf-start
scope: "repository_guidance"
owner: "Diane"
confidence: "medium"
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "winflowz_site"
  - "winflowz_app"
  - "shipflow_data"
depends_on:
  - "shipflow_data/technical/architecture.md"
  - "shipflow_data/technical/guidelines.md"
supersedes: []
evidence:
  - "README.md"
  - "winflowz_site/AGENT.md"
  - "winflowz_app/AGENTS.md"
next_step: "/sf-verify shipflow_data/workflow/specs/winflowz-monorepo-migration.md"
---

# AGENT

## Purpose

This repository is the canonical WinFlowz monorepo for the Astro site and Flutter app.

## Repository Layout

- `winflowz_site/`: Astro site with content, account, commerce, Convex, and bridge API surfaces.
- `winflowz_app/`: Flutter Android-first app with Firebase, native Android IME work, and app-level docs.
- `shipflow_data/`: monorepo-level governance, specs, bugs, audits, and workflow artifacts.

## Working Rules

- Treat `shipflow_data/` at the repository root as the only canonical governance corpus.
- Keep subproject changes inside their subproject unless root CI, docs, or governance files must change.
- Preserve public content language rules in the site and app docs; user-facing French should remain natural and accented.
- Do not add secrets to root or subproject docs, workflows, or env examples.
- Do not use the sibling `/home/claude/winflowz_app` checkout as an active source after this monorepo is verified.

## Validation

Use focused checks from the changed subproject:

```bash
(cd winflowz_site && pnpm build:check)
(cd winflowz_site && pnpm test:unit)
(cd winflowz_app && flutter analyze)
(cd winflowz_app && flutter test)
```

Run ShipFlow metadata validation for governance docs when governance files change:

```bash
/home/claude/shipflow/tools/shipflow_metadata_lint.py AGENT.md shipflow_data
```
