---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-27"
updated: "2026-05-04"
status: "reviewed"
source_skill: "sf-spec"
scope: "android_overlay"
owner: "Diane"
confidence: "medium"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
depends_on:
  - "docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md@0.1.0"
supersedes: []
evidence:
  - "android/app/src/main/kotlin/com/voiceflowz/voiceflowz/OverlayForegroundService.kt"
  - "android/app/src/main/kotlin/com/voiceflowz/voiceflowz/ime/VoiceFlowzInputMethodService.kt"
  - "specs/android-ime-voiceflowz-keyboard.md"
next_step: "/sf-ready Migration totale VoiceFlowz vers Flutter + Supabase"
---

# Android Overlay — VoiceFlowz

## Contract

Android overlay is an Android-only native capability exposed to Flutter through a narrow Dart bridge. It must not be represented as available on iOS, macOS, Windows, Linux, or web.

VoiceFlowz Keyboard is now the preferred Android text-entry surface for in-field typing, dictation, clipboard actions, snippets entry points, and generic media play/pause. Overlay remains complementary for floating capture flows and fallback delivery, not the primary keyboard path.

## Permissions

- Overlay permission is required before showing the bubble.
- Microphone permission is required before recording.
- Accessibility permission is optional and required only for direct text injection.
- The app must explain accessibility use plainly: it injects final text into the focused editable field when the user explicitly starts dictation.

## Runtime Rules

- Starting recording from overlay requires an explicit user action.
- A foreground notification is visible while overlay recording is active.
- Stop and cancel are always available.
- If no editable field is focused, injection is skipped and final text is copied to clipboard.
- If the focused field appears sensitive/password-like where detectable, injection is skipped.
- Rapid tap/stop/cancel events are debounced and cannot start concurrent recordings.
- Service cleanup must run on app logout, permission revoke, crash recovery, and app shutdown where the platform allows.

## Flutter Bridge (MethodChannel `voiceflowz/overlay`)

- `getOverlayStatus`: returns `enabled`, `requestedEnabled`, `running`, `overlayPermissionGranted`, `accessibilityPermissionGranted`, `deliveryMode`.
- `setOverlayEnabled`: enables/disables overlay runtime capability.
- `startOverlayRecording`, `stopOverlayRecording`, `cancelOverlayRecording`: foreground service controls with idempotent stop/cancel and guarded start.
- `openOverlayPermissionSettings`, `openAccessibilitySettings`: deep-links to Android settings recovery paths.

`deliveryMode` is `clipboard_only` when accessibility is disabled, and `injection_and_clipboard` when enabled.

## Keyboard Relationship

- The IME uses Android `InputConnection` for insertion and must not use accessibility as its primary injection mechanism.
- Overlay and IME recording paths must not run concurrent active recordings. The current IME foundation uses native Android speech recognition; a shared recording coordinator is still required before claiming full overlay/app/keyboard voice-session arbitration.
- Sensitive field detection rules must stay aligned between overlay injection and IME private mode wherever Android exposes comparable signals.

## Fallback

Clipboard fallback is required for every successful overlay transcription. Direct injection is a best-effort enhancement, not the only delivery path.

## Required Tests

- Permission denied for overlay, microphone, and accessibility.
- No focused field.
- Non-editable field.
- Sensitive/password-like field where detectable.
- Locked screen/background transition.
- Rapid start/stop/cancel race.
- App logout while overlay is active.
- Android build with service and accessibility declarations.
- VoiceFlowz Keyboard appears in Android input method settings and can type in a standard text field.
