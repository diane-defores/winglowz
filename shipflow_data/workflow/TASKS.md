# Tasks — WinFlowz

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Migration Verification

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Replace Supabase target coupling with backend-agnostic contracts and Firebase first-adapter spec | ✅ done — `shipflow_data/workflow/specs/firebase-backend-agnostic-migration.md` created |
| ✅ | Reorganize legacy product docs to `shipflow_data` canonical locations and replace root path references | ✅ done — root doctrine docs (`BRANDING.md`, `BUSINESS.md`, `ARCHITECTURE.md`, etc.) replaced by canonical files |
| ✅ | Finalize identity migration to WinFlowz across app packages, docs, specs, and trackers | ✅ done — commit `bd81825` |
| ✅ | Create Firebase CLI workflow for project config, Auth/Firestore setup, rules, indexes, emulator/dev validation and GitHub Secrets/Blacksmith integration | ✅ done — GitHub OIDC/WIF wired; Firestore rules/indexes deploy proven in hosted CI (`run 25636532417`, Firestore job `75249317806`) and re-validated after IAM hardening (`run 25636936089`, Firestore job `75250395805`) |
| ✅ | Run the verification gate end-to-end: `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`, `flutter build web` | ✅ done |
| 🟠 | Detach Supabase runtime target path (`task 7`) while preserving legacy compile compatibility until the final parity decision | ✅ done — Supabase removed from active bootstrap/providers/diagnostics; legacy adapters/tests remain in-place for compile compatibility |
| ⚪ | Retire or archive Supabase schema/tests after Firebase adapter parity is specified | 💤 deferred |
| ⚪ | Validate auth, transcriptions, snippets, dictionary, clipboard sync, and settings against a real Firebase environment | 💤 deferred — after Firebase adapter setup |
| 🟠 | Build Android IME WinFlowz keyboard progressively: base native keyboard, Settings bridge, privacy gate, clipboard, media, docs, Android device QA | 🔄 in progress — custom swipe-corner keyboard, Settings bridge, privacy gate, native panels, reference-keyboard foundation/editing parity roadmap, IME subtype/lifecycle/context slice, selection/InputConnection editor slice, advanced editing actions, auto-capitalization, current-word suggestions, Snippets/Dictionary text-expander sync, key-value/parser/modifier/modmap foundations now wired into live text/keyevent/action/macro dispatch with Ctrl/Alt/Fn keys and Fn navigation modmap, touch pointer/long-press/repeat/spacebar-slider foundations, FlutterWeb/Vercel keyboard preview, and local `:app:compileDebugKotlin` proof implemented; full Gradle packaging is blocked on this aarch64 runner by x86_64 AAPT2, and Android device QA/backend-agnostic sync adapter remain required |
| 🟠 | Repair Flutter Android overlay parity with native floating bubble, event bridge, accessibility delivery, and appearance settings | 🔄 in progress — native bridge and Settings controls implemented; overlay foreground-service type fix attempted for BUG-2026-05-11-001; CI APK and Android device retest still required |
| ✅ | Run the required Android-current manual platform pass and document non-Android limits | ✅ done — Android remains the only current runtime target; capability/permission limits documented; web local speech disabled; Android real-device QA remains tracked under overlay/IME tasks |

---

## Quality

| Pri | Task | Status |
|-----|------|--------|
| 🟡 | Expand automated coverage beyond the template test for auth gate, repositories, and sync/error flows | 📋 todo |
| ✅ | Rework core documentation path governance to remove compatibility doc files at repo root and use canonical `shipflow_data` paths | ✅ done |
| ✅ | Revisit README/docs wording after verification so they reflect shipped behavior rather than migration intent | ✅ done — Firebase OIDC CI playbook added and Supabase migration docs explicitly archived/legacy |

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
| ✅ | Align Flutter brand tokens, surface tokens, primary shadow, and Settings copy with the WinFlowz branding contract | ✅ done |
| ✅ | Add a user-facing Appearance control for System / Light / Dark theme mode | ✅ done |
| ✅ | Bootstrap Appearance from local settings before `runApp`, keep local cache writes, and route authenticated saves through the backend-agnostic settings store | ✅ done |
| ✅ | Constrain Firestore settings writes so `themeMode` accepts only `system`, `light`, or `dark` | ✅ done |
| ✅ | Add explicit delete confirmation dialogs across Voice, Clipboard, Snippets, and Dictionary history actions | ✅ done |
| ✅ | Block background semantics and expose route semantics for the onboarding overlay | ✅ done |
| 🟠 | Validate Appearance sync/status against Firebase with account switch and offline failure cases, then expose pending/error state in Settings | 📋 todo |
| 🟡 | Add a Flutter design playground/storybook screen for token inspection across light/dark modes | 📋 todo |
| 🟡 | Add widget/golden coverage for theme mode selection and key responsive layouts | 📋 todo |
| 🟡 | Resolve the typography contract mismatch: `branding.md` says platform system fonts, while the Flutter app ships Inter assets | 📋 todo |
| 🟡 | Review contrast and state styling on Android overlay/keyboard status cards on real devices | 📋 todo |

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Add route-level auth/flow guarding in `app_router.dart` so feature routes cannot be opened directly when auth and account state are required | 📋 todo |
| 🟡 | Add null-safety and error mapping around Google Sign-In credential construction in `lib/features/auth/data/firebase_auth_session_store.dart` | 📋 todo |
| 🟡 | Gate or contextualize diagnostic support export (`_backendDiagnosticText` in `settings_screen.dart`) outside explicit support/debug flows | 📋 todo |

### Audit: Components

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Treat the component audit `C` score as an active chantier under `settings-driven-design-system` until the component baseline reaches at least `B` | ✅ done — re-audit baseline raised to `B`; visual/manual review remains a design validation item, not a component-system blocker |
| 🟠 | Extract shared CRUD form/list primitives for Voice, Clipboard, Snippets, and Dictionary so repeated `Card` + `Padding` + fields + submit/refresh/list patterns do not keep drifting | ✅ done — `AppSectionCard`, `AppFormActions`, `AppEntityListHeader`, `AppEmptyStateCard`, and `AppEntityListTile` now cover the representative CRUD pages |
| 🟠 | Split `SettingsScreen` into composable settings sections for Appearance, backend diagnostics, keyboard, overlay, secrets, and platform capability rows | ✅ done — Settings rendering now uses dedicated private section widgets plus shared `AppSectionCard`/`AppStatusCard` primitives |
| 🟠 | Split keyboard editor/preview controls into smaller variant-driven widgets and replace the 16-prop `_PreviewControls` surface with grouped config objects or section components | ✅ done — `_PreviewControls` now takes grouped `value` and `actions` objects |
| 🟡 | Add explicit accessibility/focus contracts for custom keyboard corner targets and editor controls beyond basic `Semantics` labels | ✅ done — corner preview now has ordered focus traversal, semantic key/corner targets, Enter/Space activation, overlay slider semantic values, and widget-test coverage |
| 🟡 | Introduce reusable app primitives (`AppSectionCard`, `AppFormPanel`, `AppEntityListTile`, `AppStatusCard`) instead of assembling Material primitives inline on every page | ✅ done — first shared component set added under `lib/core/widgets/app_components.dart` |
| 🟡 | Move data mutation/load orchestration out of the large page state classes where practical, keeping screen widgets focused on rendering and interaction wiring | ✅ done — Settings keyboard/overlay bridge orchestration moved to `SettingsKeyboardController`/`SettingsOverlayController`, and keyboard preview/settings rendering split into dedicated part files |
