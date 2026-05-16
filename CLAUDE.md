---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: "WinFlowz"
created: "2026-03-18"
updated: "2026-05-04"
status: "reviewed"
source_skill: "sf-docs"
scope: "runtime-baseline"
owner: "Diane"
confidence: "medium"
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "Flutter"
  - "Supabase Auth"
  - "Supabase Postgres + RLS"
  - "Android Overlay Bridge"
evidence: []
depends_on:
  - "shipflow_data/business/business.md@0.1.0"
  - "shipflow_data/business/product.md@0.1.0"
  - "shipflow_data/technical/architecture.md@0.1.0"
  - "shipflow_data/technical/guidelines.md@0.1.0"
supersedes:
  - "CLAUDE.md@1.0.0"
next_review: "2026-05-26"
next_step: "$sf-docs update"
---

# CLAUDE.md — WinFlowz

## Project Overview

WinFlowz is now a Flutter application using Supabase for authentication and data persistence.
The app targets multi-platform delivery with Android-specific overlay capabilities exposed through a Flutter method channel.

Current migration baseline includes:
- Supabase auth gate and email/password login flow
- User-scoped RLS tables for transcriptions, clipboard, snippets, dictionary, and settings
- Flutter UI with CRUD foundations for transcriptions, clipboard, snippets, and dictionary
- Android overlay permission bridge (permission status + toggle + settings deep-link)

## Stack

- Framework: Flutter 3.x / Dart 3.x
- State management: flutter_riverpod
- Navigation: go_router
- Backend: Supabase (Auth + Postgres + RLS)
- Secure storage: flutter_secure_storage
- Audio/voice primitives: record + speech_to_text
- Android native: Kotlin `MethodChannel` bridge for overlay permission and bridge state

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d android
flutter run -d ios
```

For Supabase:

```bash
supabase db push
```

## ShipFlow Development Mode

- development_mode: hybrid
- validation_surface: mixed
- ship_before_preview_test: conditional
- post_ship_verification: sf-prod for web; manual Android QA by Diane for APK/IME behavior
- deployment_provider: vercel for web; GitHub Actions/Blacksmith for Android builds
- preview_source: https://winflowz-app.vercel.app/
- production_url: https://winflowz-app.vercel.app/
- notes: Agents can access and validate the Flutter web app on Vercel at `https://winflowz-app.vercel.app/`. Android keyboard/overlay/APK behavior must be validated manually by Diane on a physical phone; agents should provide clear QA steps and use copied diagnostics/logs from the device as evidence.
- last_reviewed: 2026-05-16

## ARM64 Android Release Guardrail

On Linux ARM64 (`aarch64`/`arm64`), do not run Android release builds locally: no `flutter build apk --release`, `flutter build appbundle --release`, `./gradlew assembleRelease`, or `./gradlew bundleRelease`. Route APK/AAB release builds to Blacksmith or another Linux x64 CI runner. Local Flutter work is limited to `flutter analyze`, `flutter test`, and `flutter build web --release`.

## Architecture

```text
lib/
├── core/
│   ├── bootstrap/supabase_bootstrap.dart
│   ├── platform/android_overlay_bridge.dart
│   └── router/app_router.dart
├── data/supabase/
│   ├── supabase_client_provider.dart
│   ├── transcription_repository.dart
│   ├── clipboard_repository.dart
│   ├── snippet_repository.dart
│   └── dictionary_repository.dart
├── features/
│   ├── auth/presentation/
│   ├── shell/presentation/app_shell_screen.dart
│   ├── voice/presentation/voice_screen.dart
│   ├── clipboard/presentation/clipboard_screen.dart
│   ├── snippets/presentation/snippets_screen.dart
│   ├── dictionary/presentation/dictionary_screen.dart
│   └── settings/presentation/settings_screen.dart
└── main.dart

android/
└── app/src/main/kotlin/com/winflowz_app/winflowz_app/MainActivity.kt

supabase/
├── migrations/
└── tests/
```

## Runtime Rules

- Supabase URL and publishable key must be injected via `--dart-define`.
- No service-role key is allowed in Flutter client code.
- Data access is controlled by Supabase RLS policies; client code must never bypass tenant/user filters.
- Clipboard, snippets, dictionary, and transcriptions are user-scoped CRUD resources.
- Android overlay features are Android-only and must remain disabled on non-Android platforms.

## Known Gaps

- Full Android overlay foreground-service flow and accessibility injection are not yet ported.
- Voice recording and AI cleanup pipelines are not fully wired end-to-end.
- Legacy JS/TS artifacts may remain in non-Flutter directories until final purge is completed.

## Related Docs

- `docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md`
- `docs/ARCHITECTURE_FLUTTER.md`
- `docs/API_SUPABASE.md`
- `docs/OVERLAY_ANDROID.md`
- `docs/VERIFICATION.md`
