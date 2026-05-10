---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-26"
updated: "2026-05-10"
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
  - "specs/android-ime-voiceflowz-keyboard.md"
  - "android/app/src/main/AndroidManifest.xml"
next_step: "$sf-docs update"
---

# VoiceFlowz

VoiceFlowz is migrating to a Flutter Android-first architecture with backend-agnostic data/settings contracts. Firebase Auth + Firestore is the first planned remote adapter.

VoiceFlowz is positioned as a sibling product of WinFlowz in the same ecosystem, with a product focus on voice-first capture and text workflow acceleration.

This repository now contains:
- A Flutter multi-platform project scaffold.
- Legacy Supabase SQL migrations with RLS-first contracts from the prior migration path.
- Android native overlay and a first native VoiceFlowz Keyboard IME foundation.
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
If these values are missing, VoiceFlowz stays in local mode so UI development does
not crash.

Never use backend admin/service credentials in Flutter/web/desktop/mobile clients.

## GitHub Actions / Blacksmith APK

The Android CI workflow runs on Blacksmith and uses GitHub Secrets for build-time configuration.

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
- Android IME: VoiceFlowz can be enabled as a native Android keyboard. The current foundation provides modular Canvas rows, tap + swipe-corner character selection, QWERTY/AZERTY profiles, normal/corner modes, numbers/accents/symbol layers, field-context variants (email/URL/phone/search), private-field gating, minimal navigation/emoji/clipboard/media/snippets/settings panels, basic double-space + punctuation auto-spacing corrections with exclusions, optional touch-debug overlay, local Android speech recognition, media key dispatch, and Settings status/preferences. Double-tap/long-press action policies from the full keyboard spec are still pending implementation. Cloud sync from the keyboard waits for Firebase CLI/emulator and real-device QA before it should be treated as production-ready.
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
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

On Linux ARM64 hosts, Android resource tooling can fail because Google-distributed
AAPT2 binaries are x86_64. Use an x64 Android runner for APK/AAB proof if local
debug builds fail at AAPT2 startup.
