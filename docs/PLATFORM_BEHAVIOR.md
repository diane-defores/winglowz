---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-27"
updated: "2026-05-10"
status: "reviewed"
source_skill: "sf-spec"
scope: "platform_behavior"
owner: "Diane"
confidence: "medium"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
depends_on:
  - "specs/firebase-backend-agnostic-migration.md@0.1.0"
supersedes: []
evidence:
  - "specs/android-ime-voiceflowz-keyboard.md"
  - "lib/core/platform/platform_capabilities.dart"
  - "android/app/src/main/kotlin/com/voiceflowz/voiceflowz/ime/VoiceFlowzInputMethodService.kt"
next_step: "/sf-start specs/firebase-backend-agnostic-migration.md"
---

# Platform Behavior — VoiceFlowz

## Shared Rules

- Remote data sync requires a valid authenticated session through the active backend adapter. Firebase Auth is the first adapter for the Android MVP.
- OpenAI and Anthropic keys are BYOK local secrets and are never synced to a remote backend.
- If secure local storage is unavailable or materially degraded, cloud AI features must be disabled or clearly marked degraded until the user accepts the risk.
- Clipboard sync is opt-in and visibly controllable.
- Platform limitations must be visible in Settings and docs.

## Capability Matrix

| Platform | Local speech | Advanced recording + Whisper | Secure key storage | Clipboard sync | Overlay | VoiceFlowz Keyboard IME |
|---|---|---|---|---|---|---|
| Android | supported when `speech_to_text` or Android speech recognition supports locale/device | supported | Android keystore via `flutter_secure_storage` | opt-in; respect background limits | supported | supported as native Kotlin IME |
| iOS | supported when permission and locale allow | supported | Keychain via `flutter_secure_storage` | opt-in; no Android-style overlay | unavailable | unavailable |
| macOS | supported when package/platform allows | supported | keychain-backed where available | opt-in | unavailable | unavailable |
| Windows | supported when package/platform allows | supported | platform secure storage where available | opt-in | unavailable | unavailable |
| Linux | local speech unavailable unless package support changes | supported via recording + Whisper | may be degraded; require explicit UI state | opt-in | unavailable | unavailable |
| Web | unavailable for current Android-first work | unavailable for current Android-first work | degraded compared with native keychain/keystore | not a current priority | unavailable | unavailable |

## Android Keyboard IME

- VoiceFlowz Keyboard is declared as an Android `InputMethodService` and is configurable from Settings through the `voiceflowz/keyboard` MethodChannel.
- The keyboard provides a native minimal QWERTY layout, explicit clipboard copy/paste actions, Android speech recognition, and a generic play/pause media key.
- Password, OTP, `noPersonalizedLearning`, and host-marked private fields force private mode: dictation, clipboard capture, snippets, sync intent, and learning are disabled while basic typing remains available.
- Clipboard sync from the keyboard is opt-in and represented as intent/status. Real cloud sync and cross-account queue flushing require the backend-agnostic Firebase adapter before production claims.
- Non-Android platforms must not show IME activation controls.

## Android Overlay

- The Android overlay is implemented as a native foreground service with a draggable `WindowManager` bubble.
- The bubble can emit queued events to Flutter for tap, long press, stop, cancel, and native service errors.
- Accessibility delivery is optional and best-effort; clipboard fallback remains mandatory for final text.
- The overlay and IME must not run concurrent voice sessions. Until full arbitration is implemented, UI and logs must treat this as a high-risk QA case.
- Non-Android platforms must not show overlay activation controls.

## Direct AI Calls

Android may call OpenAI/Anthropic directly with user-provided keys where secure local storage and provider behavior allow. Web is intentionally ignored for now and must stay disabled for advanced cloud AI until a later reviewed decision reopens it.

## Apple Microphone And Speech Permissions

iOS and macOS must declare microphone and speech recognition usage descriptions before any dictation or recording prompt is tested. macOS also requires sandbox audio input entitlement for microphone capture. These declarations do not reopen overlay or IME scope outside Android.

## Limits

- Max audio duration: 10 minutes for advanced mode unless a reviewed product decision changes it.
- Max audio upload size: 25 MB or the current provider limit, whichever is lower.
- Max synced text payload: 100,000 characters per transcription and 50,000 characters per clipboard item.
- Retries: bounded to 2 automatic retries for network/transient failures; user action required after that.
- Timeouts: AI and remote sync operations must surface recoverable errors.
