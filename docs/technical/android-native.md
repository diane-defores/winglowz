---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "WinFlowz"
created: "2026-05-04"
updated: "2026-05-16"
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
  - "shipflow_data/technical/guidelines.md@0.1.0"
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
directly: overlay foreground service, accessibility fallback, and the WinFlowz
IME. The IME must stay lightweight, native, and privacy-aware because it runs
inside other apps' input fields.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `android/app/src/main/AndroidManifest.xml` | Android service, activity, and permission declarations | Keep IME and overlay declarations explicit; avoid broad permissions before use. |
| `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/MainActivity.kt` | Flutter MethodChannel owner | Keep `winflowz_app/overlay` and `winflowz_app/keyboard` contracts separate. |
| `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/Overlay*.kt` | Overlay runtime | Do not allow concurrent overlay and keyboard recording without coordinator logic. |
| `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/**` | Native IME services/controllers | No raw text logging; sensitive fields disable capture/sync/enriched insertion; clipboard bridge events stay in memory unless durable storage is explicitly selected. |
| `android/app/src/main/res/xml/**` | Android service metadata | IME metadata must match manifest service declarations. |

## Entrypoints

- `WinFlowzInputMethodService.onCreateInputView`: creates the native keyboard.
- `WinFlowzInputMethodService.onStartInput`: evaluates the focused field policy and field context (`text`, `email`, `url`, `phone`, `search`).
- `MainActivity.configureFlutterEngine`: registers platform channels used by Settings.

## Control Flow

```text
Android input field
  -> WinFlowzInputMethodService
  -> KeyboardInputContextResolver + KeyboardSecurityPolicy
  -> WinFlowzKeyboardView (Canvas)
  -> KeyboardLayoutBuilder + KeyboardKeyValueEngine + KeyboardGestureClassifier
  -> InputConnection / ClipboardManager / AudioManager

Keyboard clipboard action
  -> KeyboardClipboardEventQueue in memory
  -> winflowz_app/keyboard MethodChannel drain
  -> ClipboardHistoryApi / ClipboardHistoryStore
```

## Invariants

- The IME uses `InputConnection` for insertion, never accessibility injection.
- Backspace deletes one Unicode code point when no selection exists (`deleteSurroundingTextInCodePoints` fallback to legacy delete).
- Navigation panel uses `InputConnection` + key events for: char left/right, word left/right, line start/end, and word deletion before cursor with graceful fallback.
- Emoji panel provides local categories and local recents; private mode does not persist new emoji recents.
- Basic typing corrections are local and opt-in:
  - double-space to `. `
  - punctuation auto-spacing
  - both disabled automatically for private/email/url/phone contexts.
- Debug touch overlay can render key bounds and gesture classifier diagnostics without exposing user text.
- Password, OTP, `noPersonalizedLearning`, and app-marked sensitive fields must disable voice capture, clipboard sync, snippets, and learning behavior.
- Base media control sends generic play/pause key events only; it must not read metadata without explicit richer permission.
- Keyboard preferences are persisted in `KeyboardStateStore` and round-tripped through `winflowz_app/keyboard`:
  - `layoutProfile`: `QWERTY` / `AZERTY`
  - `cornerModeEnabled`: `true` / `false`
  - `cornerConfig`: versioned JSON with a preset id and per-key/per-slot overrides
  - `themeConfig`: versioned JSON (`version`, `presetId`, colors, linear/radial gradient style, border/radius/shadow values, local image reference, press-effect/easing metadata) persisted under `KEY_THEME_CONFIG` with size cap (48 KB)
  - `privacyMode`: `auto` / `strict` / `standard`
- IME state preferences store only non-sensitive flags and counters, never typed or dictated text.
- Corner shortcut execution uses `KeyboardCornerShortcuts`, `KeyboardCornerShortcutResolver`, and `KeyboardKeyValue` instead of a second action language. The resolver combines preset, user overrides, field policy, `cornerModeEnabled`, and `specialKeyCornersEnabled` at layout snapshot time.
- Keyboard theme authoring lives in Flutter `KeyboardThemeStudioScreen` and is pushed to native with `getKeyboardThemeConfig`, `setKeyboardThemeConfig`, and `resetKeyboardThemeConfig` on `winflowz_app/keyboard`. The studio ships the v1 preset catalog (`System`, `WinFlowz Light`, `WinFlowz Dark`, `Neon Terminal`, `Glass Mint`, `Sunset Gradient`, `Midnight Aurora`, `Paper Ink`, `Pixel Candy`, `Minimal Contrast`), collapsible editing sections, and JSON import/export without image bytes.
- Native IME `onThemeSettings()` opens Flutter route `/keyboard/theme` through `MainActivity` intent extra `openRoute`.
- Theme saves are blocked in Flutter when key/status contrast falls below the readable threshold or when image mode has no imported local image. Heavy shadows, thick borders, high effect intensity, and long particle effects produce warnings.
- Native rendering supports solid, linear gradient, radial gradient, app-private image backgrounds, key border/radius/shadow values, custom key/status/corner text colors, and bounded press effects. Private fields suppress custom image/gradient/effect surfaces.
- Native press effects are handled by `KeyboardPressEffects`: `scale`, `pulse`, `shake`, `ripple`, `glow`, `confettiLite`, and `fireworksLite` are short-lived, queue-capped, and disabled for private fields or system animation scale `0`.
- Theme image import uses a system image picker, decodes/downsamples to a bounded PNG in app-private storage, and rejects non-image or oversized output; no broad storage permission is required and the IME renders only the private path.
- Replacing or resetting a theme cleans up superseded app-private theme images under `filesDir/keyboard_themes` to avoid orphaned files.
- Keyboard diagnostics now expose `themePresetId`, `themePressEffect`, `themeBackgroundSource`, `themeConfigSize`, and `themeFallbackStatus` without exposing private image paths.
- The built-in corner preset preserves the legacy French accents for `a/e/i/o/u/c/n/s`. Additional presets are punctuation, French accents plus punctuation, developer symbols, and no corners.
- Corner shortcut values may dispatch text, key events, actions, modifiers, and macros. Private fields suppress sensitive actions such as clipboard, snippets, voice, and sensitive macros while keeping normal text accents available.
- IME clipboard sync events must not call Supabase or any backend directly; Flutter drains them into the backend-agnostic clipboard API.
- The native clipboard event queue is process-memory only until a durable local storage decision is made.
- Text keys carry a `KeyboardKeyValue` model in addition to display glyphs. `KeyboardKeyValueParser`, `KeyboardKeyModifier`, and `KeyboardModMap` are the local foundation for parsed layouts, macros, Ctrl/Alt/Fn/Shift behavior and user modmaps; the live layout dispatches parsed text keys, key events, action values and macros through existing callbacks.
- Ctrl, Alt and Fn are exposed as modifier keys in the control row. They latch for the next key-value dispatch, then clear; Fn currently ships with a conservative built-in navigation modmap for `h/j/k/l`.
- Touch handling tracks the active pointer id, ignores secondary pointers without dispatching duplicate keys, supports long-press repeat for destructive/navigation actions, and uses horizontal spacebar sliding for cursor movement. It still does not implement full multi-finger modifier chords or selection sliders.
- Protected gestures keep priority over corners: space slider, horizontal scroll rows, long press/repeat, and return-to-center cancellation must not dispatch a configured corner.

## Failure Modes

- IME not enabled: Settings must open Android input method settings.
- InputConnection unavailable or host app blocks access: show recoverable keyboard feedback.
- Microphone permission unavailable: do not start recording.
- No media consumer: play/pause action may be ignored by Android; show best-effort feedback.
- Android unit tests that require resource bundling can be blocked on ARM64 hosts when AAPT2 is unavailable; `:app:compileDebugKotlin` is the local native compile proof, while full test/package proof belongs on x86_64 CI or device.

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

- Manifest or `res/xml` changed -> verify WinFlowz appears in Android keyboard settings.
- `KeyboardSecurityPolicy` changed -> recheck password/OTP/no-personalized-learning behavior.
- Clipboard controller changed -> recheck sensitive clipboard flags and no background clipboard capture.
- Clipboard event queue changed -> recheck no provider credentials/imports in native code and that sensitive clips are not enqueued.
- Media controller changed -> recheck no metadata permission is introduced silently.
- `KeyboardCornerShortcuts.kt`, `KeyboardLayoutModels.kt`, `WinFlowzKeyboardView.kt`, or `KeyboardStateStore.kt` changed -> recheck default accents, override precedence, private-field suppression, special-key toggle, space slider priority, scroll row priority, and corrupt JSON fallback.
- `KeyboardPressEffects.kt` or theme validation changed -> recheck fast typing, private/password fields, system reduce-motion, and unreadable theme rejection.

## Maintenance Rule

Update this doc when Android service declarations, IME lifecycle, platform
channel contracts, permissions, or security invariants change.
