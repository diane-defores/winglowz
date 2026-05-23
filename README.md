---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "WinFlowz"
created: "2026-04-26"
updated: "2026-05-14"
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
  - "Backend-agnostic stores"
  - "Firebase first adapter"
  - "OpenAI Whisper"
  - "Anthropic Messages API"
  - "Android overlay services"
  - "Android IME keyboard"
depends_on:
  - "docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md@0.1.0"
  - "docs/API_SUPABASE.md@1.0.0"
supersedes: []
evidence:
  - "docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md"
  - "shipflow_data/workflow/specs/android-ime-winflowz_app-keyboard.md"
  - "android/app/src/main/AndroidManifest.xml"
next_step: "$sf-docs update"
---

# WinFlowz

WinFlowz is migrating to a Flutter Android-first architecture with backend-agnostic data/settings contracts. Firebase Auth + Firestore is the first planned remote adapter.

WinFlowz is positioned as a sibling product of WinFlowz in the same ecosystem, with a product focus on voice-first capture and text workflow acceleration.

This repository now contains:
- A Flutter multi-platform project scaffold.
- Legacy Supabase SQL migrations with RLS-first contracts from the prior migration path.
- Android native overlay and a first native WinFlowz keyboard IME foundation.
- Migration docs and verification gates.
- Legacy Expo/Convex contracts preserved in docs for parity validation; no app-level JS/TS implementation remains in the repo.

## Go-to-Market Posture

- Product narrative: voice-first productivity and learning/watchflow support, not a generic all-in-one suite.
- Commercial narrative: LTD + subscription strategy is documented at business level, but runtime billing/entitlements are not yet implemented.
- Claim boundary: avoid public claims about production-grade billing, enterprise compliance, or finalized cross-device account isolation until the related runtime milestones are complete.

## Quick Start (Flutter baseline)

```bash
flutter pub get
flutter run
```

## Firebase Runtime Defines

Firebase is now wired as the first backend adapter behind backend-agnostic stores.
If these values are missing, WinFlowz stays in local mode so UI development does
not crash.

Never use backend admin/service credentials in Flutter/web/desktop/mobile clients.

Auth has three supported runtime paths:

- Firebase email/password session for cloud-backed product usage.
- Firebase Google session for cloud-backed product usage.
- Explicit local mode when Firebase is absent or the user chooses local-only use.

Local mode is not a cloud-auth bypass. It keeps the app usable locally, while
remote sync stays unavailable until a Firebase session exists.

Google Sign-In on Android requires the Firebase Android app package name,
enabled Google provider, `FIREBASE_WEB_CLIENT_ID` passed as the Google Sign-In
`serverClientId`, and the debug/release SHA fingerprints for the signing key
used by the APK. `FIREBASE_WEB_CLIENT_ID` is the OAuth 2.0 **Web client ID**
ending in `.apps.googleusercontent.com`; it is not the Firebase Android app id.
Missing or mismatched SHA/client configuration can surface as a canceled Google
flow, so treat those cases as setup failures during QA.

## Sentry Runtime Defines

Sentry is optional. If `SENTRY_DSN` is missing, WinFlowz does not initialize
Sentry and keeps diagnostics local-only.

Use Dart defines for builds that should report Flutter/native crashes:

```bash
flutter run \
  --dart-define=SENTRY_DSN=https://examplePublicKey@o0.ingest.sentry.io/0 \
  --dart-define=SENTRY_ENVIRONMENT=debug
```

WinFlowz configures Sentry with `sendDefaultPii=false`, screenshots disabled,
view hierarchy disabled, and build tags from `WINFLOWZ_APP_BUILD_*` defines.

## GitHub Actions / Blacksmith APK

The Android CI workflow runs on Blacksmith and uses GitHub Secrets for build-time configuration.
It also validates that the target Firebase project has Firebase Auth services and
project auth config enabled before producing an APK.

Add these repository secrets in GitHub: **Settings -> Secrets and variables -> Actions -> Repository secrets**.

Prepare these Firebase names now for the MVP adapter (do not introduce Doppler):

- `FIREBASE_PROJECT_ID` (`winflowz-dev`)
- `GCP_WIF_PROVIDER`
- `GCP_WIF_SERVICE_ACCOUNT`
- `FIREBASE_DEV_API_KEY`
- `FIREBASE_DEV_APP_ID`
- `FIREBASE_DEV_MESSAGING_SENDER_ID`
- `FIREBASE_DEV_AUTH_DOMAIN`
- `FIREBASE_DEV_STORAGE_BUCKET`
- `FIREBASE_WEB_CLIENT_ID` (OAuth Web client ID used as Android Google Sign-In `serverClientId`)
- `SENTRY_DSN` (optional crash reporting)
- `SENTRY_ENVIRONMENT` (optional, for example `debug`, `staging`, `production`)

Use `docs/technical/firebase-cli-foundation.md` for exact Firebase CLI commands:

- `firebase use winflowz-dev`
- `firebase deploy --only firestore`
- `firebase emulators:start --only firestore,auth`

The prior Supabase secrets are legacy and should not be expanded for new target work.
The Firestore CI deploy now uses GitHub OIDC + Google Workload Identity Federation
instead of a long-lived service account JSON key.

## Current Migration Scope

- Auth/data: backend-agnostic contracts replace direct Convex/Supabase coupling; Firebase Auth + Firestore adapters are wired with local fallback.
- UI: Flutter shell + auth gate + settings key storage baseline is in place.
- Security: Firestore rules and indexes are versioned; emulator and real Firebase validation still require `firebase-tools`.
- Android overlay: Flutter now has a native foreground overlay bubble foundation with queued native events, visual states, accessibility delivery, clipboard fallback, and Settings size/opacity controls. Real-device QA is still required before deleting the legacy Expo overlay reference or snapshot archive.
- Android IME: WinFlowz can be enabled as a native Android keyboard. The current foundation provides modular Canvas rows, tap + swipe-corner character selection, QWERTY/AZERTY profiles, Smart French corner defaults, normal/corner modes, numbers/accents/symbol layers, field-context variants (email/URL/phone/search), private-field gating, minimal navigation/emoji/clipboard/media/snippets/settings panels, basic double-space + punctuation auto-spacing corrections with exclusions, optional touch-debug overlay, local Android speech recognition, media key dispatch, and Settings status/preferences. Double-tap/long-press action policies from the full keyboard spec are still pending implementation. Cloud sync from the keyboard waits for Firebase CLI/emulator and real-device QA before it should be treated as production-ready.
- Non-Android limits: iOS/macOS declare microphone and speech permission prompts; Linux and web keep local speech unavailable/degraded where the current stack cannot support it; overlay and IME remain Android-only.

## Project Structure (target)

```text
lib/app/                     Flutter app shell
lib/core/                    bootstrap, router, theme, platform capability rules
lib/features/                auth, voice, clipboard, settings, shell
lib/data/                    Backend adapters and provider-neutral repositories
supabase/migrations/         Legacy SQL schema, constraints, RLS policies from prior path
docs/                        migration, API, platform, overlay, verification contracts
```

## Validation

```bash
dart format --set-exit-if-changed .
git diff --check
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

Before selling or publicly claiming production auth readiness, also run the
Android/Firebase auth smoke in `docs/VERIFICATION.md`: email/password,
Google success, controlled Google config failure or equivalent evidence, local
mode, sign-out, and protected deep-link redirects.

On Linux ARM64 hosts, Android resource tooling can fail because Google-distributed
AAPT2 binaries are x86_64. Use an x64 Android runner for APK/AAB proof if local
debug builds fail at AAPT2 startup.
