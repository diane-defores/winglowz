---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "VoiceFlowz"
created: "2026-05-04"
updated: "2026-05-04"
status: draft
source_skill: sf-docs
scope: "android-native"
owner: "Diane"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "Android InputMethodService"
  - "Android ClipboardManager"
  - "Android AudioManager"
  - "Android overlay/accessibility services"
  - "Flutter MethodChannel"
depends_on:
  - "CLAUDE.md@1.2.0"
  - "GUIDELINES.md@0.1.0"
  - "docs/OVERLAY_ANDROID.md@0.1.0"
supersedes: []
evidence:
  - "Mapped before Android IME native implementation."
next_review: "2026-06-04"
next_step: "/sf-docs technical audit"
---

# Technical Module Context: Android Native

## Purpose

Android native code owns system-level capabilities that Flutter cannot provide
directly: overlay foreground service, accessibility fallback, and the VoiceFlowz
IME. The IME must stay lightweight, native, and privacy-aware because it runs
inside other apps' input fields.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `android/app/src/main/AndroidManifest.xml` | Android service, activity, and permission declarations | Keep IME and overlay declarations explicit; avoid broad permissions before use. |
| `android/app/src/main/kotlin/com/voiceflowz/voiceflowz/MainActivity.kt` | Flutter MethodChannel owner | Keep `voiceflowz/overlay` and `voiceflowz/keyboard` contracts separate. |
| `android/app/src/main/kotlin/com/voiceflowz/voiceflowz/Overlay*.kt` | Overlay runtime | Do not allow concurrent overlay and keyboard recording without coordinator logic. |
| `android/app/src/main/kotlin/com/voiceflowz/voiceflowz/ime/**` | Native IME services/controllers | No raw text logging; sensitive fields disable capture/sync/enriched insertion. |
| `android/app/src/main/res/xml/**` | Android service metadata | IME metadata must match manifest service declarations. |

## Entrypoints

- `VoiceFlowzInputMethodService.onCreateInputView`: creates the native keyboard.
- `VoiceFlowzInputMethodService.onStartInput`: evaluates the focused field policy.
- `MainActivity.configureFlutterEngine`: registers platform channels used by Settings.

## Control Flow

```text
Android input field
  -> VoiceFlowzInputMethodService
  -> VoiceFlowzKeyboardView
  -> InputConnection / ClipboardManager / AudioManager
```

## Invariants

- The IME uses `InputConnection` for insertion, never accessibility injection.
- Password, OTP, `noPersonalizedLearning`, and app-marked sensitive fields must disable voice capture, clipboard sync, snippets, and learning behavior.
- Base media control sends generic play/pause key events only; it must not read metadata without explicit richer permission.
- IME state preferences store only non-sensitive flags and counters, never typed or dictated text.

## Failure Modes

- IME not enabled: Settings must open Android input method settings.
- InputConnection unavailable or host app blocks access: show recoverable keyboard feedback.
- Microphone permission unavailable: do not start recording.
- No media consumer: play/pause action may be ignored by Android; show best-effort feedback.

## Security Notes

The keyboard is a high-trust surface. Do not log user text, selected text,
clipboard text, dictated text, raw audio, tokens, or provider payloads.

## Validation

```bash
./gradlew :app:compileDebugKotlin
flutter build apk --debug
```

Manual Android validation is still required for IME visibility, typing,
clipboard, dictation, media keys, and OEM behavior.

## Reader Checklist

- Manifest or `res/xml` changed -> verify VoiceFlowz appears in Android keyboard settings.
- `KeyboardSecurityPolicy` changed -> recheck password/OTP/no-personalized-learning behavior.
- Clipboard controller changed -> recheck sensitive clipboard flags and no background clipboard capture.
- Media controller changed -> recheck no metadata permission is introduced silently.

## Maintenance Rule

Update this doc when Android service declarations, IME lifecycle, platform
channel contracts, permissions, or security invariants change.
