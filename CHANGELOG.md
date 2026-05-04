---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "VoiceFlowz"
created: "2026-03-18"
updated: "2026-04-26"
status: "draft"
source_skill: "sf-docs"
scope: "update"
owner: "unknown"
confidence: "medium"
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

### Changed
- Repaired the local Flox Flutter environment and pinned it to an executable Flutter SDK variant.
- Protected direct app routes behind Supabase auth state instead of allowing private screens to load before sign-in.
- Updated `.env.example` to document Supabase runtime defines instead of legacy Convex/Clerk variables.

### Security
- Converted the RLS smoke script into a pgTAP-style test covering own-user access, forged user denial, anonymous denial, tombstone preservation and sensitive client-event metadata keys.
- Added database guardrails for tombstone preservation, client event metadata size, sensitive metadata keys and user-scoped query indexes.

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
