---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "VoiceFlowz"
created: "2026-03-18"
updated: "2026-05-10"
status: "draft"
source_skill: "sf-docs"
scope: "update"
owner: "unknown"
confidence: "medium"
risk_level: "medium"
security_impact: "unknown"
docs_impact: "yes"
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - "git history"
next_step: "$sf-changelog"
---

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Added Android overlay appearance controls in Settings for floating bubble size and opacity.
- Added native Android overlay bridge support for persisted bubble appearance preferences.
- Added first-run onboarding that explains the startup path, Android keyboard setup, microphone, overlay, accessibility and cloud sync permissions.
- Added a Settings backend-provider diagnostic card with a copyable Supabase/local-mode error.
- Added the Android VoiceFlowz Keyboard IME foundation with native input service declaration, minimal keyboard UI, Settings bridge, Android speech recognition trigger, explicit clipboard actions and generic media play/pause.
- Added keyboard-origin Supabase schema fields, source allowlists, clipboard hash dedupe metadata, RLS smoke coverage and Dart model/bridge tests.
- Added project technical governance docs and a content map for future ShipFlow code/doc update gates.
- Added `docs/technical/firebase-oidc-ci-playbook.md` with a reusable GitHub OIDC/WIF Firestore deploy runbook and troubleshooting matrix.

### Changed
- Changed first-run onboarding into a dismissible overlay so tab content remains visible while setup guidance is shown.
- Changed Android/system Back handling inside the shell so Back returns to the previous app tab before exiting.
- Moved the missing Supabase configuration diagnostic out of the global shell banner and into Settings so local-mode screens are not crowded while the backend provider remains undecided.
- Repaired the local Flox Flutter environment and pinned it to an executable Flutter SDK variant.
- Protected direct app routes behind Supabase auth state instead of allowing private screens to load before sign-in.
- Updated `.env.example` to document Supabase runtime defines instead of legacy Convex/Clerk variables.
- Renamed Supabase runtime configuration to `SUPABASE_PUBLISHABLE_KEY` in app bootstrap and docs, while keeping the old key name as an internal compatibility fallback.
- Updated README, platform, overlay, component, API and verification docs to describe Android IME scope and proof gaps.
- Switched Firestore CI deploy from interactive Firebase CLI auth to GitHub OIDC/WIF in `.github/workflows/android-build.yml`.
- Updated Firebase CI documentation to require `GCP_WIF_PROVIDER` and `GCP_WIF_SERVICE_ACCOUNT` instead of long-lived service account JSON secrets.
- Archived Supabase migration target docs as legacy-only references and pointed execution to `specs/firebase-backend-agnostic-migration.md`.
- Removed unnecessary Firestore indexes that caused hosted deploy errors on `settings` and `transcriptions` collection groups.

### Security
- Converted the RLS smoke script into a pgTAP-style test covering own-user access, forged user denial, anonymous denial, tombstone preservation and sensitive client-event metadata keys.
- Added database guardrails for tombstone preservation, client event metadata size, sensitive metadata keys and user-scoped query indexes.
- Added IME private-field gating for password, OTP, no-personalized-learning and host-marked sensitive fields so dictation, snippets and clipboard capture are disabled there.

## [2026-04-26]

### Added
- Added Node/npm runtime metadata and Dependabot coverage for npm and GitHub Actions updates.

### Changed
- Refreshed compatible npm dependencies within the current Expo SDK 55 / React Native 0.83 constraints.

### Security
- Updated transitive packages to remove known critical and high npm audit findings, including the Clerk shared SDK advisory.
- Documented remaining moderate Expo toolchain audit findings that require a separate migration path rather than `npm audit fix --force`.

## [0.1.0] — 2026-03-18

### Added
- Initial project setup with Expo SDK 55 + React Native 0.83
- Dual-mode voice transcription: free on-device (expo-speech-recognition) + advanced (Whisper API)
- AI text cleanup via Claude Haiku + local regex cleanup (filler words FR/EN)
- "Enhance with AI" button for per-transcription upgrade from free to advanced
- `useVoiceRecording` hook — reusable recording state machine with metering
- Audio waveform visualization component (animated bars from recorder metering)
- Clipboard sync via Convex (real-time polling, dedup, cross-device)
- In-app floating action button (FAB) — draggable, snap-to-edge, expand/collapse with waveform + cancel/done controls
- Native Android overlay module (Kotlin) — FloatingOverlayService, OverlayView, WaveformView
- System overlay via TYPE_APPLICATION_OVERLAY with foreground service
- Text injection: AccessibilityService (opt-in) + clipboard fallback (default)
- Overlay permissions hook (`useOverlayPermissions`) with guided setup in Settings
- Expo config plugin (`withFloatingOverlay`) for AndroidManifest permissions and service declarations
- Settings screen: API keys (SecureStore), language selector (10 languages), overlay permissions
- Convex schema: clipboardItems, transcriptions, snippets, dictionary tables
- Transcriptions auto-saved to Convex after every successful recording
- GitHub Actions CI: Android APK debug build on every push
- EAS Build config (development, preview, production profiles)
- CLAUDE.md with full project documentation
