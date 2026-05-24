---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "WinFlowz"
created: "2026-05-04"
updated: "2026-05-24"
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
  - "Backend-agnostic stores"
  - "Firebase first adapter"
  - "Android MethodChannel"
depends_on:
  - "CLAUDE.md@1.2.0"
  - "shipflow_data/technical/guidelines.md@0.1.0"
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
Provider-specific repositories such as Supabase legacy or Firebase are adapters,
not product contracts. Android-only capabilities must be hidden or described as
unavailable on non-Android platforms.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `lib/core/platform/**` | Platform capability and native bridge wrappers | Keep native channel names stable and return typed models instead of raw maps. |
| `lib/core/router/app_router.dart` | App route table and auth/local-mode guard | Protected product routes must pass through the app shell and must not build without signed-in or explicit local fallback state. |
| `lib/core/diagnostics/**` | Local diagnostics and redaction helpers | Redact secrets/tokens/password-like fields before support copy, breadcrumbs, or event details. |
| `lib/features/auth/**` | Auth contracts, Firebase/Google adapters, auth gate, and sign-in UI | Keep SDK errors behind typed domain failures; UI should not parse raw Firebase/Google exceptions directly. |
| `lib/features/settings/**` | Runtime Settings UI | Surface permission/setup recovery paths honestly; do not show Android-only controls elsewhere. |
| `lib/features/**/domain/**` | Feature models | Keep validation allowlists aligned with SQL constraints. |
| `lib/features/clipboard/application/**` | Clipboard product API and provider composition | Keep UI and future Android bridges pointed at `ClipboardHistoryApi`, not provider repositories. |
| `lib/features/clipboard/domain/**` | Backend-neutral clipboard sources, sync state, sensitivity and dedupe contracts | Keep provider names, SQL columns and native Android details out of the domain. |
| `lib/features/clipboard/data/**` | Local/offline clipboard stores | Local fallback history is persisted through secure storage; keep provider adapters outside this module. |
| `lib/data/supabase/**` | Legacy Supabase adapter implementations | Keep compiling until Firebase parity exists; do not add new target behavior here. |
| `lib/data/firebase/**` | Firebase adapter implementations | Keep Firebase behind backend-agnostic stores and Firestore Security Rules. |
| `test/**` | Dart/widget tests | Cover model validation and bridge parsing when native contracts change. |

## Entrypoints

- `lib/main.dart`: app bootstrap.
- `lib/app/winflowz_app.dart`: application shell.
- `lib/features/settings/presentation/settings_screen.dart`: Android permission and feature status surface.

## Control Flow

```text
Settings UI
  -> Dart bridge wrapper
  -> Android MethodChannel
  -> native status/settings action

Keyboard corner editor / preview
  -> AndroidKeyboardCornerConfig + KeyboardCornerPresetCatalog
  -> KeyboardCornerDraft + guided action catalog for draft-before-save editing
  -> selectable keyboard preview for key/corner selection
  -> AndroidKeyboardBridge get/set/reset corner config on Android
  -> local simulation only on web/non-Android preview

Clipboard UI
  -> AndroidKeyboardBridge.drainKeyboardClipboardEvents
  -> ClipboardHistoryApi
  -> ClipboardHistoryStore
  -> secure local persistent store or provider adapter
```

## Invariants

- Remote auth owns user identity; Flutter client code must not send trusted `user_id` fields.
- Firebase Auth + Firestore Security Rules are the first target adapter for the Android MVP.
- Product routes are protected by `app_router.dart`; signed-out direct links
  redirect to auth, while explicit local mode and signed-in sessions open
  through `AppShellScreen`.
- Firebase/Google SDK exceptions cross into presentation as typed
  `AuthFailure` values with redacted support details.
- Android-only controls render only when `PlatformCapabilities.isAndroid` is true.
- Domain model source allowlists must match database constraints.
- Clipboard UI, application APIs and domain models must not import Supabase adapters.
- Signed-out, local fallback, and entitlement-missing sessions keep clipboard history usable through `PersistentClipboardHistoryStore`.
- Android native code emits platform actions/events; backend writes go through the Flutter product API or an equivalent store contract.
- Keyboard clipboard bridge events are imported by Flutter before listing clipboard items; sensitive automatic content can be rejected by the store without user confirmation.
- Keyboard corner config models in `lib/features/keyboard/domain/keyboard_models.dart` mirror the native preset/override wire shape. Kotlin native owns functional preset tables; Flutter keeps preset ids/names as DTO/UI fallback and resolves only explicit overrides.
- `KeyboardCornerShortcutsScreen` edits corner shortcuts as a draft. It must not call the native save bridge until the user explicitly saves, and unsupported platforms must remain simulation-only.
- `KeyboardPreviewScreen` and `KeyboardCornerSelectablePreview` can render explicit override shortcuts and simulate simple text-like override outputs. They do not recreate native preset defaults; Android key events, field policy enforcement, persistence, preset resolution, and system dispatch still require Android IME validation.

## Failure Modes

- Native channel unavailable: show a recoverable Settings message instead of crashing.
- Remote backend not configured: keep local UI usable with the secure persistent clipboard store and display configuration state for cloud sync.
- Auth provider unavailable or misconfigured: show a recoverable French auth
  message, keep support detail redacted/copyable only when useful, and do not
  publish a partial signed-in state.
- Google Sign-In canceled after account selection can indicate Android
  configuration trouble; treat configuration hints as setup failures instead of
  pure user cancellation.
- Native corner config validation failure: keep the current editor state visible, show the bridge error, and do not pretend the shortcut was saved.

## Security Notes

Secrets stay in local secure storage. Text, clipboard content, audio, provider
payloads, and tokens must not be logged into `client_events`.

Auth support detail, AppDiagnostics, and Sentry events must not contain raw API
keys, OAuth/JWT tokens, password-like values, raw provider payloads, clipboard
content, transcripts, or private user text.

## Validation

```bash
flutter analyze
flutter test
```

## Reader Checklist

- `lib/core/platform/**` changed -> verify native channel contract and Settings UI.
- `lib/features/keyboard/domain/keyboard_models.dart` or keyboard preview changed -> verify preset id parsing, explicit override precedence, private-mode filtering, and widget tests for preview rendering.
- `lib/features/keyboard/presentation/keyboard_corner_shortcuts_screen.dart` changed -> verify draft/save separation, private-mode warnings, snippet search, import/export safety, and unsupported-platform copy.
- Domain model source allowlist changed -> verify SQL constraints and tests.
- Repository metadata changed -> verify backend adapter docs and security rules/tests.
- Clipboard API/store changed -> verify no feature UI imports `lib/data/supabase`, run clipboard tests including persistent local history, and update provider docs.
- Auth adapter/router/sign-in changed -> run auth failure, sign-in, router guard,
  full Flutter tests, and the Android auth smoke before claiming ship readiness.

## Maintenance Rule

Update this doc when Flutter bridge contracts, Settings capabilities, repository
contracts, or validation commands change.
