---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-26"
updated: "2026-05-04"
status: "reviewed"
source_skill: "sf-docs"
scope: "components"
owner: "Diane"
confidence: "high"
risk_level: "medium"
security_impact: "low"
docs_impact: "yes"
linked_systems:
  - "Flutter"
  - "Android native overlay"
  - "Android native IME"
depends_on:
  - "../ARCHITECTURE.md@0.1.0"
  - "../docs/MIGRATION_FLUTTER.md@0.1.0"
supersedes: []
evidence:
  - "../components/OverlayBridge.tsx"
  - "../components/AudioWaveform.tsx"
  - "../components/RecordingControls.tsx"
  - "../modules/floating-overlay/android/src/main/java/expo/modules/floatingoverlay/FloatingOverlayModule.kt"
  - "../android/app/src/main/kotlin/com/voiceflowz/voiceflowz/ime/VoiceFlowzInputMethodService.kt"
next_step: "$sf-docs components"
---

# Components — VoiceFlowz

## Scope

This inventory separates:

- target Flutter component contracts (implementation target),
- legacy React Native components (reference-only parity map).

## Target component contracts (Flutter)

### Voice flow

- `VoiceScreen`:
  primary dictation workflow, state visibility, copy/edit/share actions.
- `RecordingControls`:
  start/stop/cancel controls with explicit mode state.
- `AudioMeter`:
  visual feedback for recording activity.

### Clipboard flow

- `ClipboardScreen`:
  list, copy, pin/unpin, delete, sync status.
- `ClipboardListItem`:
  dense row actions and timestamp metadata.

### Settings flow

- `SettingsScreen`:
  language, permissions, key management status, auth session visibility,
  Android overlay status, and Android keyboard IME status/preferences.
- `PermissionCards`:
  platform-specific permission status + recovery actions.

### Snippets and dictionary

- `SnippetsScreen` + editor sheet/dialog for CRUD and trigger uniqueness errors.
- `DictionaryScreen` + editor sheet/dialog for CRUD and replacement validation.

### Overlay integration (Android)

- `OverlayController` (service/controller layer):
  bridge to native plugin for show/hide/state/event operations.
- `OverlayStatusBanner` (UI):
  user-visible status of overlay/accessibility readiness.

### Keyboard integration (Android)

- `VoiceFlowzInputMethodService`:
  native Android `InputMethodService` for system keyboard entry.
- `VoiceFlowzKeyboardView`:
  native minimal QWERTY keyboard with action row for dictation, clipboard,
  snippets entry point, Settings, and media play/pause.
- `KeyboardSecurityPolicy`:
  detects password, OTP, no-personalized-learning and host private fields to
  force private mode.
- `AndroidKeyboardBridge`:
  Dart MethodChannel wrapper for IME enabled/active status, input-method
  settings, keyboard picker, and non-sensitive preferences.

Native event contract to preserve from Kotlin module:

- `onBubbleTap`
- `onRecordStop`
- `onRecordCancel`
- `onBubbleLongPress`

Native command contract to preserve:

- `showBubble`
- `hideBubble`
- `startRecordingService`
- `stopRecordingService`
- `setOverlayState`
- `updateMeterLevel`
- `setResultText`
- `injectText`

## Legacy component reference (non-target)

Legacy components remain useful only for parity checks:

- `components/AudioWaveform.tsx`
- `components/RecordingControls.tsx`
- `components/OverlayFAB.tsx`
- `components/OverlayBridge.tsx`
- `app/(tabs)/index.tsx`
- `app/(tabs)/clipboard.tsx`
- `app/(tabs)/settings.tsx`

They do not define target implementation technology choices.
