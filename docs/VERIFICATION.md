---
artifact: verification_plan
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-27"
updated: "2026-05-10"
status: "reviewed"
source_skill: "sf-spec"
scope: "android_firebase_backend_agnostic_migration"
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
  - "test/widget_test.dart"
  - "specs/clipboard-backend-agnostic-api.md"
next_step: "/sf-start specs/firebase-backend-agnostic-migration.md"
---

# Verification — VoiceFlowz Android Firebase Backend-Agnostic Migration

## Required Automated Checks

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- Android build on a machine with Android toolchain.
- Android IME build/resource proof on an x64 Android runner when the local host is ARM64 and AAPT2 is unavailable.
- Android overlay sanity (without full build when toolchain is heavy): verify `flutter analyze`, then run on Android and check start/stop/cancel/status from Settings and Voice screens.
- Firebase configuration/rules/indexes validation when Firebase adapter is implemented.
- Firestore Security Rules tests or emulator smoke proving user-scoped isolation.

## Required Manual Checks

- Android: local speech, advanced recording, VoiceFlowz Keyboard enable/switch/type/private-field behavior, keyboard dictation permission denied/allowed, keyboard clipboard actions, keyboard media play/pause, overlay permission, accessibility fallback, clipboard fallback.
- iOS/macOS/Windows/Linux/web: out of current runtime scope. Keep platform limits documented and do not treat desktop/web build or launch as required proof for the Android MVP.

## Manual Platform Pass — 2026-05-10

| Surface | Status | Evidence | Remaining proof |
|---|---|---|---|
| Android overlay parity | Partial | Native overlay bubble, event queue, accessibility delivery, clipboard fallback, Settings size/opacity controls, and Blacksmith Android compile proof already exist. | Real Android device QA for bubble behavior, permissions, injection, clipboard fallback, size/opacity, and overlay/IME recording arbitration. |
| Android IME | Partial | Native IME declaration, Settings bridge, private-field gating, clipboard actions, Android speech recognition, and media key controls are implemented. | Real Android device QA for enable/switch/type/private-field/dictation/media flows. |
| iOS microphone/speech | Out of current scope | `Info.plist` declares microphone and speech recognition usage descriptions for future compatibility; overlay and IME remain unavailable. | None for Android MVP. |
| macOS desktop launch | Out of current scope | `Info.plist` declares microphone/speech usage and sandbox audio input entitlement for future compatibility; overlay/IME remain unavailable. | None for Android MVP. |
| Linux desktop launch | Out of current scope | Local speech is unavailable by capability rule and secure storage is degraded. Desktop launch is not required proof while the product is Android-only. | None for Android MVP. |
| Windows desktop launch | Out of current scope | Platform matrix keeps overlay/IME unavailable; local speech depends on plugin/runtime support. | None for Android MVP. |
| Web permission limits | Passed build | `PlatformCapabilities.localSpeechSupported` is false on web; secure storage remains degraded; overlay/IME are unavailable. `flutter build web` passed on 2026-05-10. | Browser smoke only if web scope reopens. |

## Security Gate

- No client bundle contains a service role key.
- No client bundle contains Firebase admin credentials or any backend service/admin credential.
- OpenAI/Anthropic keys are never synced to Firebase or another remote backend.
- Logs and copyable debug output redact keys, provider payloads, audio, and raw transcripts.
- Clipboard sync is opt-in and visibly pausable.
- Firestore Security Rules deny cross-user CRUD for every user-scoped collection.
- Overlay cannot silently start recording or inject without user action.
- IME cannot silently capture, sync, log, or enrich text in password/OTP/private fields.
- AI and sync retries are bounded and time out visibly.

## Android IME Manual Matrix

Run on at least one emulator or real Android device before closing the IME chantier:

| Case | Expected result |
|---|---|
| Enable VoiceFlowz in Android input method settings | VoiceFlowz Keyboard appears as an available keyboard. |
| Switch to VoiceFlowz from a normal text field | Native keyboard opens without launching a Flutter view inside the IME. |
| Type letters, space, backspace, enter | Focused field receives expected `InputConnection` updates; backspace deletes one code point including emoji/surrogate pairs. |
| Toggle QWERTY/AZERTY in Settings then reopen IME | Letter rows match selected layout profile and persist between sessions. |
| Enable swipe-corner mode then swipe key corners | Secondary corner glyphs are inserted; center-return gesture cancels insertion. |
| Disable swipe-corner mode | Same gestures fallback to primary tap behavior only. |
| Open Navigation panel and run cursor/edit actions | Char left/right works; word left/right and line start/end work when host supports context; unavailable cases show recoverable feedback. |
| Trigger delete word-left in Navigation panel | Deletes the previous word boundary or shows unavailable feedback when cursor context is absent. |
| Open Emoji panel and insert from categories | Emoji is inserted via `InputConnection` into active field. |
| Insert emoji in normal field then reopen Emoji panel | Recent emoji appears in local recents list. |
| Insert emoji in private/sensitive field | Emoji insertion works, but recent emoji list does not update. |
| Enable double-space to period and type in standard text field | Double-space converts to `. ` after word characters. |
| Enable punctuation auto-spacing and type `: ; ! ? . ,` in standard text field | Keyboard applies basic spacing rules around punctuation. |
| Try the same corrections in private/email/url/phone fields | Corrections are suppressed; raw input is kept. |
| Enable keyboard touch debug overlay | Key bounds + gesture classifier diagnostics appear without exposing typed text. |
| Focus password/OTP/no-personalized-learning field | Private mode is visible; dictation, clipboard capture, snippets and learning/sync are disabled. |
| Tap Mic without microphone permission | No recording starts; keyboard shows recoverable permission state. |
| Tap Mic with permission and speech recognition available | Recognized text is inserted into the active field. |
| Clipboard copy/paste actions | Copy is explicit from selected text; paste uses current system clipboard text only. |
| Toggle clipboard/media/snippets/settings mini-panels | Each panel opens/closes in-place and preserves base typing workflow. |
| Focus email, URL, phone, and search fields | Keyboard adapts symbols/enter action to the field context. |
| Tap Media while a media app is active | Android receives a play/pause media key; no metadata permission is requested. |
| Use Settings keyboard card | Input settings, switch keyboard, voice, clipboard sync intent, media controls, layout profile, corner mode, and privacy mode round-trip through `voiceflowz/keyboard`. |

## Purge Gate

Before deleting legacy JS/TS application code:

1. Snapshot rollback archive exists and includes legacy app, Convex, overlay, and docs.
2. Flutter parity checks pass for Voice, Clipboard, Settings, Snippets, Dictionary, Auth, and Android overlay.
3. Firebase rules/indexes and user-scoped access tests pass once Firebase adapter replaces Supabase.
4. Dry-run list of files to delete is reviewed.
5. Keep rules are explicit: keep docs, assets still referenced by Flutter, legacy backend archives until parity, native platform files, Kotlin overlay code, and migration specs.
6. Post-purge search for JS/TS application code passes.
