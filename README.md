---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-26"
updated: "2026-04-27"
status: "reviewed"
source_skill: "sf-docs"
scope: "readme"
owner: "Diane"
confidence: "medium"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "Flutter"
  - "Supabase"
  - "OpenAI Whisper"
  - "Anthropic Messages API"
  - "Android overlay services"
depends_on:
  - "docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md@0.1.0"
  - "docs/API_SUPABASE.md@0.1.0"
---

# VoiceFlowz

VoiceFlowz is migrating to a Flutter + Supabase architecture across Android, iOS, macOS, Windows, Linux and web.

VoiceFlowz is positioned as a sibling product of WinFlowz in the same ecosystem, with a product focus on voice-first capture and text workflow acceleration.

This repository now contains:
- A Flutter multi-platform project scaffold.
- Supabase SQL migrations with RLS-first contracts.
- Migration docs and verification gates.
- Legacy Expo/Convex contracts preserved in docs for parity validation; no app-level JS/TS implementation remains in the repo.

## Go-to-Market Posture

- Product narrative: voice-first productivity and learning/watchflow support, not a generic all-in-one suite.
- Commercial narrative: LTD + subscription strategy is documented at business level, but runtime billing/entitlements are not yet implemented.
- Claim boundary: avoid public claims about production-grade billing, enterprise compliance, or finalized cross-device account isolation until the related runtime milestones are complete.

## Quick Start (Flutter baseline)

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

## Required Runtime Defines

| Variable | Required | Purpose |
|---|---:|---|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anon key for client auth/data paths |

Never use `SUPABASE_SERVICE_ROLE_KEY` in Flutter/web/desktop/mobile clients.

## Current Migration Scope

- Auth: Supabase Auth replaces Clerk target path.
- Data: Supabase Postgres + RLS replaces Convex target path.
- UI: Flutter shell + auth gate + settings key storage baseline is in place.
- Security: SQL constraints + RLS policies are in migration files.

## Project Structure (target)

```text
lib/app/                     Flutter app shell
lib/core/                    bootstrap, router, theme, platform capability rules
lib/features/                auth, voice, clipboard, settings, shell
lib/data/supabase/           Supabase client + repositories
supabase/migrations/         SQL schema, constraints, RLS policies
docs/                        migration, API, platform, overlay, verification contracts
```

## Validation

```bash
flutter analyze
flutter test
flutter build web
```
