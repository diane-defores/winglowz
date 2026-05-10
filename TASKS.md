# Tasks — VoiceFlowz

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Migration Verification

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Replace Supabase target coupling with backend-agnostic contracts and Firebase first-adapter spec | ✅ done — `specs/firebase-backend-agnostic-migration.md` created |
| 🔴 | Create Firebase CLI workflow for project config, Auth/Firestore setup, rules, indexes, emulator/dev validation and GitHub Secrets/Blacksmith integration | 🔄 in progress — rules/indexes/docs, FlutterFire conditional init, Auth/Firestore adapters added; Firebase CLI demo emulator starts; real Firebase deploy, Android SDK and Blacksmith proof still required |
| ✅ | Run the verification gate end-to-end: `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`, `flutter build web` | ✅ done |
| ⚪ | Retire or archive Supabase schema/tests after Firebase adapter parity is specified | 💤 deferred |
| ⚪ | Validate auth, transcriptions, snippets, dictionary, clipboard sync, and settings against a real Firebase environment | 💤 deferred — after Firebase adapter setup |
| 🟠 | Build Android IME VoiceFlowz Keyboard progressively: base native keyboard, Settings bridge, privacy gate, clipboard, media, docs, Android device QA | 🔄 in progress — foundation implemented; Android x64/device proof and backend-agnostic sync adapter still required |
| 🟠 | Repair Flutter Android overlay parity with native floating bubble, event bridge, accessibility delivery, and appearance settings | 🔄 in progress — native bridge and Settings controls implemented; Blacksmith compile proof exists for prior overlay fix, but device QA for bubble behavior and size/opacity remains required |
| 🟠 | Run the required manual platform pass for Android overlay, iOS microphone/speech, desktop launch, and web permission limits | 📋 todo |

---

## Quality

| Pri | Task | Status |
|-----|------|--------|
| 🟡 | Expand automated coverage beyond the template test for auth gate, repositories, and sync/error flows | 📋 todo |
| 🟡 | Revisit README/docs wording after verification so they reflect shipped behavior rather than migration intent | 📋 todo |

---

## Historical completed work

> Imported from repo state so the local tracker starts with the already-shipped baseline, not an empty backlog.

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Flutter multi-platform baseline and Supabase-first repository structure | ✅ done |
| ✅ | Initial Supabase migration and RLS smoke test scaffold | ✅ done |
| ✅ | Supabase migration lint in CI | ✅ done |
| ✅ | Flox Flutter environment repaired and pinned to an executable `flutter` SDK variant | ✅ done |
| ✅ | RLS smoke converted to a pgTAP-style test and wired into CI | ✅ done |
| ✅ | Added first-run onboarding, Android back-tab navigation, permission explanations and non-blocking backend diagnostic copy in Settings | ✅ done |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Use GitHub Secrets, not Doppler, for Android build configuration on Blacksmith | ✅ done |
| 🟢 | Review product/runtime scope after the verification gate before adding billing or release-surface work | 💤 deferred |

---

## Audit Findings
<!-- Populated by /sf-audit — dated sections with Fixed: / Remaining: -->

### Audit: Design

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Adopt ContentFlow family palette, spacing, radius, motion names, and component defaults in the Flutter theme source of truth | ✅ done |
| ✅ | Add a user-facing Appearance control for System / Light / Dark theme mode | ✅ done |
| 🟠 | Persist the Appearance preference locally and sync it through backend-agnostic settings once Firebase adapter is finalized | ✅ done — local SettingsStore and FirebaseSettingsStore are wired behind backend-agnostic provider |
| 🟠 | Migrate feature screens from literal `EdgeInsets`, `SizedBox`, and ad hoc text weights to shared theme tokens/components | ✅ done — feature/app presentation scan has no inline spacing, color, text style or numeric size literals |
| 🟡 | Add a Flutter design playground/storybook screen for token inspection across light/dark modes | 📋 todo |
| 🟡 | Add widget/golden coverage for theme mode selection and key responsive layouts | 📋 todo |
| 🟡 | Review contrast and state styling on Android overlay/keyboard status cards on real devices | 📋 todo |
