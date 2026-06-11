---
artifact: design_system_authority
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "WinFlowz"
created: "2026-06-11"
updated: "2026-06-11"
status: "draft"
source_skill: "300-sf-docs"
scope: "design-system-authority"
owner: "Diane"
confidence: "high"
risk_level: "high"
security_impact: "no"
docs_impact: "yes"
content_surfaces:
  - "winflowz_app"
  - "winflowz_site"
linked_systems:
  - "winflowz_app/lib/core/theme/winflowz_theme_tokens.dart"
  - "winflowz_app/lib/core/theme/app_theme.dart"
  - "winflowz_site/src/assets/styles/global.css"
  - "winflowz_site/tailwind.config.mjs"
depends_on:
  - artifact: "shipflow_data/technical/guidelines.md"
    artifact_version: "1.0.1"
    required_status: "reviewed"
  - artifact: "shipflow_data/technical/architecture.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Code scan: `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart` and `winflowz_app/lib/core/theme/app_theme.dart` are explicit theme token layers."
  - "Site scan: `winflowz_site/src/assets/styles/global.css` and `winflowz_site/tailwind.config.mjs` are the visual token entry points."
  - "Cross-project design token audit baseline: `python3 /home/claude/shipflow/tools/design_system_drift_check.py --format markdown --warn-only --max-findings 5000` from project root."
next_step: "run 503-sf-audit-design-tokens winflowz"
---

# WinFlowz Design-System Authority

## 1) Canonical token sources

### App (Flutter)
- **Primary source**: `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart`
- **Theme mapping**: `winflowz_app/lib/core/theme/app_theme.dart`

### Site (Astro + Tailwind)
- **Primary source**: `winflowz_site/src/assets/styles/global.css`
- **Theme adapter**: `winflowz_site/tailwind.config.mjs`

## 2) Authoritative rule

Any change introducing or modifying **colors, typography, spacing, radii, shadows, motion, or layout tokens** must go through one of the four files above first.

- App screens/components must prefer `WinFlowzThemeTokens`, then `ThemeData` extensions from `app_theme.dart`.
- Site components must prefer `var(--*)` tokens and Tailwind config aliases.
- New visual values in non-authoritative files are only valid when:
  1. the value is clearly non-visual (e.g. business logic), or
  2. there is an explicit, temporary exception approved in the linked spec.

## 3) Required token map

### App tokens
- Colors: `WinFlowzThemeTokens.*`
- Typography: `WinFlowzThemeTokens.typography*`, `AppTypography.*`
- Spacing: `WinFlowzThemeTokens.spacing*`, `AppSpacing.*`
- Motion: `WinFlowzThemeTokens.motion*`, `AppDuration*`
- Shadows: `WinFlowzThemeTokens.shadow*`

### Site tokens
- Palette: `--brand-*`, `--font-*`, `--radius` in `global.css`
- Mode tokens: `--border`, `--input`, `--ring`, `--background`, `--foreground` in `global.css`
- Tailwind aliases in `tailwind.config.mjs` (extended with the same variables)

## 4) Enforcement guardrails (mandatory)

1. No ad-hoc `Color(0x...)`, hex (`#rrggbb`), `rgb(...)`, `oklch(...)`, or literal px/rem/em in UI code.
2. No arbitrary Tailwind visual utilities (ex. `max-w-[85rem]`, `min-h-[60vh]`) for production UI.
3. No inline style objects for visual output in production components (`style=...`) unless tokenized via local variables.
4. Motion constants (`duration`, `cubic-bezier`, animation timing) must be tokenized.
5. No component-level `if (isDark)`, `if (isLight)` visual branches; switch only at token/theme layer.

## 5) Temporary exceptions

- `winflowz_app/lib/features/keyboard/presentation/keyboard_theme_studio_screen.dart` contains hard-coded palette preview fixtures and is excluded only until a follow-up migration task.
- `winflowz_site/.vercel/output/**` is generated output, non-authoritative, and must not drive design decisions.
- Legacy SVG source assets that hardcode brand colors are allowed only when wrapped under shared brand symbol components.

## 6) Change process

For every style-related commit:
1. Update token source first.
2. Consume token through a shared abstraction (`WinFlowzThemeTokens` or CSS variables/Tailwind alias).
3. Run token drift check with generated output excluded from the evidence set.

## 7) Acceptance criteria

- No new hard-coded visual literals are introduced in production component code.
- New UI changes are traceable to one of the canonical token files.
- Any direct visual exception is documented in this artifact before merge.

