## 2026-05-11 - Android real-device overlay + IME QA

- Scope: feature
- Environment: local Android real device
- Tester: user
- Source: sf-test
- Status: fail
- Confidence: high
- Result summary: Overlay does not appear; Settings overlay button does not trigger visible activation despite overlay and accessibility permissions granted.
- Bug pointer: BUG-2026-05-11-001 -> shipflow_data/workflow/bugs/BUG-2026-05-11-001.md
- Evidence pointer: user-provided redacted Settings diagnostic copied at 2026-05-11 10:23:41 UTC.
- Follow-up: /sf-fix BUG-2026-05-11-001

## 2026-05-16 - Keyboard crash recovery Android real-device QA

- Scope: spec keyboard-resilience-and-error-management
- Environment: Android real device
- Tester: user
- Source: sf-test
- Status: fail
- Confidence: high
- Result summary: Crash recovery passed for `#+=`, `Prefs`, long press `123`, compact functional behavior, Termux flows; failures remain for `123` long-press discoverability and compact mode overlapped by Android bottom bar.
- Bug pointer: BUG-2026-05-16-002 -> bugs/BUG-2026-05-16-002.md; BUG-2026-05-16-003 -> bugs/BUG-2026-05-16-003.md
- Evidence pointer: user report in sf-test reply at 2026-05-16 08:34:01 UTC; no private diagnostic pasted.
- Follow-up: /sf-fix BUG-2026-05-16-003 then /sf-fix BUG-2026-05-16-002

## 2026-05-16 - Backend Provider logs panel retest

- Scope: bug BUG-2026-05-16-004
- Environment: Android real device / web Settings
- Tester: user
- Source: sf-test manual confirmation
- Status: pass
- Confidence: high
- Result summary: Backend Provider Logs and Diagnostics opens without the red Flutter assertion panel; previous unbounded log panel crash is fixed.
- Bug pointer: BUG-2026-05-16-004 -> bugs/BUG-2026-05-16-004.md
- Evidence pointer: user confirmation in chat at 2026-05-16 09:27:41 UTC.
- Follow-up: closed
