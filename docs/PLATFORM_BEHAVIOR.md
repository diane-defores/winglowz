---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-27"
updated: "2026-05-04"
status: "reviewed"
source_skill: "sf-spec"
scope: "platform_behavior"
owner: "Diane"
confidence: "medium"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
depends_on:
  - "docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md@0.1.0"
supersedes: []
evidence:
  - "specs/android-ime-voiceflowz-keyboard.md"
  - "lib/core/platform/platform_capabilities.dart"
  - "android/app/src/main/kotlin/com/voiceflowz/voiceflowz/ime/VoiceFlowzInputMethodService.kt"
next_step: "/sf-ready Migration totale VoiceFlowz vers Flutter + Supabase"
---

# Platform Behavior — VoiceFlowz

## Shared Rules

- Supabase data sync requires a valid authenticated session.
- OpenAI and Anthropic keys are BYOK local secrets and are never synced to Supabase.
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
| Web | browser-dependent | supported only if direct API call/proxy decision is implemented safely | degraded compared with native keychain/keystore | permission/browser-limited and opt-in | unavailable | unavailable |

## Android Keyboard IME

- VoiceFlowz Keyboard is declared as an Android `InputMethodService` and is configurable from Settings through the `voiceflowz/keyboard` MethodChannel.
- The keyboard provides a native minimal QWERTY layout, explicit clipboard copy/paste actions, Android speech recognition, and a generic play/pause media key.
- Password, OTP, `noPersonalizedLearning`, and host-marked private fields force private mode: dictation, clipboard capture, snippets, sync intent, and learning are disabled while basic typing remains available.
- Clipboard sync from the keyboard is opt-in and represented as intent/status. Real Supabase sync and cross-account queue flushing still require linked-project validation before production claims.
- Non-Android platforms must not show IME activation controls.

## Direct AI Calls

Native mobile and desktop may call OpenAI/Anthropic directly with user-provided keys. Web must be explicitly verified before enabling direct calls; if browser CORS, key exposure, or provider constraints make direct calls unacceptable, web advanced mode remains disabled until a proxy contract is specified.

## Limits

- Max audio duration: 10 minutes for advanced mode unless a reviewed product decision changes it.
- Max audio upload size: 25 MB or the current provider limit, whichever is lower.
- Max synced text payload: 100,000 characters per transcription and 50,000 characters per clipboard item.
- Retries: bounded to 2 automatic retries for network/transient failures; user action required after that.
- Timeouts: AI and Supabase operations must surface recoverable errors.
