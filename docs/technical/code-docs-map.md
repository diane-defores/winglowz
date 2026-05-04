---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "VoiceFlowz"
created: "2026-05-04"
updated: "2026-05-04"
status: draft
source_skill: sf-docs
scope: "code-docs-map"
owner: "Diane"
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "Flutter"
  - "Android native"
  - "Supabase"
depends_on:
  - "docs/technical/README.md@0.1.0"
supersedes: []
evidence:
  - "Bootstrapped before Android IME implementation."
next_review: "2026-06-04"
next_step: "/sf-docs technical audit"
---

# Code Docs Map — VoiceFlowz

| Code path / pattern | Subsystem | Primary technical doc | Validation | Docs update trigger |
| --- | --- | --- | --- | --- |
| `lib/**` | Flutter app | `docs/technical/flutter-app.md` | `flutter analyze`; `flutter test` | Platform bridge contract, Settings UI, repository, domain model, or feature behavior changes |
| `android/app/src/main/**` | Android native | `docs/technical/android-native.md` | `./gradlew :app:compileDebugKotlin` or `flutter build apk --debug` on supported host | Manifest/service/permission, MethodChannel, overlay, IME, media, clipboard, accessibility, or lifecycle changes |
| `supabase/migrations/**`, `supabase/tests/**` | Supabase data | `docs/technical/supabase-data.md` | Supabase migration apply and `supabase/tests/rls_smoke.sql` against a linked project | Table, policy, constraint, RLS, realtime, repository metadata, or smoke-test changes |
| `docs/**`, `README.md`, `PRODUCT.md`, `BUSINESS.md` | Documentation | `docs/technical/code-docs-map.md` plus target doc | Markdown review and relevant code checks | User-visible platform capability, setup, verification, API, or security promise changes |

## Documentation Update Plan Format

- Code changed: `path/or/pattern`
- Subsystem: `name`
- Primary technical doc: `docs/technical/example.md`
- Secondary docs: `...`
- Required action: `none | review | update | create`
- Priority: `low | medium | high`
- Reason: `why this doc is impacted`
- Owner role: `executor | integrator`
- Parallel-safe: `yes | no`
- Notes: `constraints or blockers`

## Maintenance Rule

Update this map when new code areas become first-class or when validation
commands, subsystem ownership, or documentation triggers change.
