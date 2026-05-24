# WinFlowz

Canonical monorepo for the WinFlowz site and application surfaces.

## Repository Layout

- `winflowz_site/` - Astro site for content, account, commerce, and bridge API surfaces.
- `winflowz_app/` - Flutter Android-first app.
- `shipflow_data/` - monorepo-level governance contracts, specs, bugs, reviews, and workflow artifacts.

## Deployment Model

- GitHub source of truth: `diane-defores/winflowz`
- Vercel site project uses `winflowz_site` as its Root Directory.
- Vercel app project uses `winflowz_app` as its Root Directory when the Flutter web surface is deployed.
- Firebase CLI files for the app live under `winflowz_app/`.

## Common Checks

Run checks from the affected subproject:

```bash
(cd winflowz_site && pnpm build:check)
(cd winflowz_site && pnpm test:unit)
(cd winflowz_app && flutter analyze)
(cd winflowz_app && flutter test)
```

## Working Rule

All active WinFlowz surfaces live in this single repository. The sibling `/home/claude/winflowz_app` checkout is a migration source and fallback until the monorepo migration is verified and shipped.
