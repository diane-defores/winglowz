---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "WinFlowz"
created: "2026-04-27"
updated: "2026-05-10"
status: "reviewed"
source_skill: "sf-spec"
scope: "android_overlay"
owner: "Diane"
confidence: "medium"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
depends_on:
  - "shipflow_data/workflow/specs/firebase-backend-agnostic-migration.md@0.1.0"
supersedes: []
evidence:
  - "android/app/src/main/kotlin/com/winflowz_app/winflowz_app/OverlayForegroundService.kt"
  - "android/app/src/main/kotlin/com/winflowz_app/winflowz_app/OverlayView.kt"
  - "android/app/src/main/kotlin/com/winflowz_app/winflowz_app/OverlayEventQueue.kt"
  - "android/app/src/main/kotlin/com/winflowz_app/winflowz_app/OverlayTextInjectionHelper.kt"
  - "android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzInputMethodService.kt"
  - "shipflow_data/workflow/specs/android-ime-winflowz_app-keyboard.md"
next_step: "/sf-verify shipflow_data/workflow/specs/android-overlay-flutter-parity-repair.md"
---

# Android Overlay — WinFlowz

## Contract

Android overlay is an Android-only native capability exposed to Flutter through a narrow Dart bridge. It must not be represented as available on iOS, macOS, Windows, Linux, or web.

WinFlowz keyboard is now the preferred Android text-entry surface for in-field typing, dictation, clipboard actions, snippets entry points, and generic media play/pause. Overlay remains complementary for floating capture flows and fallback delivery, not the primary keyboard path.

The Flutter port now owns an actual native overlay bubble through `OverlayForegroundService`, `OverlayView`, `WaveformView`, `OverlayEventQueue`, and `OverlayTextInjectionHelper`. The old Expo module remains a legacy reference only and must not be used at runtime.

## Permissions

- Overlay permission is required before showing the bubble.
- Microphone permission is required before recording.
- Accessibility permission is optional and required only for direct text injection.
- The app must explain accessibility use plainly: it injects final text into the focused editable field when the user explicitly starts dictation.

## Runtime Rules

- The visible overlay bubble runs as a user-controlled Android foreground service with `specialUse`; it must not require microphone runtime permission merely to appear.
- Starting recording from overlay requires an explicit user action.
- A foreground notification is visible while the overlay service is active.
- Stop and cancel are always available.
- The collapsed bubble can be dragged to reposition it; expanded recording controls expose a dedicated drag handle so stop/cancel taps stay reliable.
- If no editable field is focused, injection is skipped and final text is copied to clipboard.
- If the focused field appears sensitive/password-like where detectable, injection is skipped.
- Rapid tap/stop/cancel events are debounced and cannot start concurrent recordings.
- Service cleanup must run on app logout, permission revoke, crash recovery, and app shutdown where the platform allows.

## Flutter Bridge (MethodChannel `winflowz_app/overlay`)

- `getOverlayStatus`: returns `enabled`, `requestedEnabled`, `running`, `overlayPermissionGranted`, `accessibilityPermissionGranted`, `deliveryMode`.
- `setOverlayEnabled`: enables/disables overlay runtime capability.
- `startOverlayRecording`, `stopOverlayRecording`, `cancelOverlayRecording`: foreground service controls with idempotent stop/cancel and guarded start.
- `drainOverlayEvents`: returns queued native overlay events such as `bubbleTap`, `longPress`, `recordStop`, `recordCancel`, and `serviceError`.
- `setOverlayState`, `updateMeterLevel`, `setResultText`: lets Flutter mirror voice pipeline state into the native bubble.
- `deliverText`: attempts accessibility injection and always attempts clipboard fallback for non-empty text.
- `openOverlayPermissionSettings`, `openAccessibilitySettings`: deep-links to Android settings recovery paths.

`deliveryMode` is `clipboard_only` when accessibility is disabled, and `injection_and_clipboard` when enabled.

## Keyboard Relationship

- The IME uses Android `InputConnection` for insertion and must not use accessibility as its primary injection mechanism.
- Overlay and IME recording paths must not run concurrent active recordings. The current IME foundation uses native Android speech recognition; a shared recording coordinator is still required before claiming full overlay/app/keyboard voice-session arbitration.
- Sensitive field detection rules must stay aligned between overlay injection and IME private mode wherever Android exposes comparable signals.

## Fallback

Clipboard fallback is required for every successful overlay transcription. Direct injection is a best-effort enhancement, not the only delivery path.

`deliverText` returns whether text was injected, copied to clipboard, and blocked by a sensitive field. It must not log text content.

## Legacy Reference

Keep `modules/floating-overlay/` and `winflowz_app_snapshots/winflowz_app-pre-flutter-migration-20260427-081046.tar.gz` until a real Android QA pass confirms parity. Cleanup belongs in a separate chantier after proof.

## Required Tests

- Permission denied for overlay, microphone, and accessibility.
- No focused field.
- Non-editable field.
- Sensitive/password-like field where detectable.
- Locked screen/background transition.
- Rapid start/stop/cancel race.
- App logout while overlay is active.
- Android build with service and accessibility declarations.
- WinFlowz keyboard appears in Android input method settings and can type in a standard text field.
