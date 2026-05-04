# Tasks — VoiceFlowz

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Migration Verification

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Run the verification gate end-to-end: `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`, `flutter build web` | ✅ done |
| 🔴 | Apply the Supabase schema on a dev/test project and execute `supabase/tests/rls_smoke.sql` against real auth users | ⛔ blocked — Docker/CI or linked Supabase project required |
| 🟠 | Validate auth, transcriptions, snippets, dictionary, clipboard sync, and settings against a real Supabase environment (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) | 📋 todo |
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

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | Review product/runtime scope after the verification gate before adding billing or release-surface work | 💤 deferred |

---

## Audit Findings
<!-- Populated by /sf-audit — dated sections with Fixed: / Remaining: -->
