---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "VoiceFlowz"
created: "2026-05-04"
updated: "2026-05-08"
status: draft
source_skill: sf-docs
scope: "flutter-app"
owner: "Diane"
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "Flutter"
  - "Riverpod"
  - "ClipboardHistoryApi"
  - "ClipboardHistoryStore"
  - "Supabase Flutter"
  - "Android MethodChannel"
depends_on:
  - "CLAUDE.md@1.2.0"
  - "GUIDELINES.md@0.1.0"
supersedes: []
evidence:
  - "Mapped before Android IME Settings bridge work."
next_review: "2026-06-04"
next_step: "/sf-docs technical audit"
---

# Technical Module Context: Flutter App

## Purpose

The Flutter app owns the user-facing screens, backend-agnostic feature APIs and
stores, platform capability gates, and MethodChannel bridge wrappers.
Provider-specific repositories such as Supabase are adapters, not product
contracts. Android-only capabilities must be hidden or described as unavailable
on non-Android platforms.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `lib/core/platform/**` | Platform capability and native bridge wrappers | Keep native channel names stable and return typed models instead of raw maps. |
| `lib/features/settings/**` | Runtime Settings UI | Surface permission/setup recovery paths honestly; do not show Android-only controls elsewhere. |
| `lib/features/**/domain/**` | Feature models | Keep validation allowlists aligned with SQL constraints. |
| `lib/features/clipboard/application/**` | Clipboard product API and provider composition | Keep UI and future Android bridges pointed at `ClipboardHistoryApi`, not provider repositories. |
| `lib/features/clipboard/domain/**` | Backend-neutral clipboard sources, sync state, sensitivity and dedupe contracts | Keep provider names, SQL columns and native Android details out of the domain. |
| `lib/features/clipboard/data/**` | Local/offline clipboard stores | Do not claim durable persistence unless a storage backend has been selected. |
| `lib/data/supabase/**` | Supabase adapter implementations | Never use service-role keys or client-sent user IDs for authorization; do not make these adapters UI contracts. |
| `test/**` | Dart/widget tests | Cover model validation and bridge parsing when native contracts change. |

## Entrypoints

- `lib/main.dart`: app bootstrap.
- `lib/app/voiceflowz_app.dart`: application shell.
- `lib/features/settings/presentation/settings_screen.dart`: Android permission and feature status surface.

## Control Flow

```text
Settings UI
  -> Dart bridge wrapper
  -> Android MethodChannel
  -> native status/settings action

Clipboard UI
  -> AndroidKeyboardBridge.drainKeyboardClipboardEvents
  -> ClipboardHistoryApi
  -> ClipboardHistoryStore
  -> local/offline store or provider adapter
```

## Invariants

- Supabase Auth/RLS owns user identity; Flutter client code must not send trusted `user_id` fields.
- Android-only controls render only when `PlatformCapabilities.isAndroid` is true.
- Domain model source allowlists must match database constraints.
- Clipboard UI, application APIs and domain models must not import Supabase adapters.
- Android native code emits platform actions/events; backend writes go through the Flutter product API or an equivalent store contract.
- Keyboard clipboard bridge events are imported by Flutter before listing clipboard items; sensitive automatic content can be rejected by the store without user confirmation.

## Failure Modes

- Native channel unavailable: show a recoverable Settings message instead of crashing.
- Supabase not configured: keep local UI usable with the local clipboard store where available and display configuration state for cloud sync.

## Security Notes

Secrets stay in local secure storage. Text, clipboard content, audio, provider
payloads, and tokens must not be logged into `client_events`.

## Validation

```bash
flutter analyze
flutter test
```

## Reader Checklist

- `lib/core/platform/**` changed -> verify native channel contract and Settings UI.
- Domain model source allowlist changed -> verify SQL constraints and tests.
- Repository metadata changed -> verify RLS docs and smoke tests.
- Clipboard API/store changed -> verify no feature UI imports `lib/data/supabase`, run clipboard tests and update provider docs.

## Maintenance Rule

Update this doc when Flutter bridge contracts, Settings capabilities, repository
contracts, or validation commands change.
