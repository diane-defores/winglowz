# AGENTS.md — WinFlowz

## Local Command Guardrails

- Allowed local checks: `flutter analyze`, `flutter test`, and targeted `flutter test ...`.
- Do not run Android builds, installs, packaging, or Gradle tasks on this VM.
- Forbidden locally: `flutter build apk`, `flutter build appbundle`, `flutter run -d android`, `./gradlew ...`, `assemble*`, `bundle*`, `compile*`, and `testDebugUnitTest`.
- Android APK/IME validation must go through GitHub Actions/Blacksmith and Diane's physical-device QA.
- Vercel is the validation/deployment surface for the Flutter web app.
- Sentry can provide runtime crash/error evidence from installed app sessions, but it does not replace Blacksmith CI for Android build validation.

See `CLAUDE.md` for the broader project baseline.
