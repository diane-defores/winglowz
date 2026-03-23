# WinFlowz

Optimize your Windows workflow. Tools, training, and guides for professionals who use Windows daily.

https://winflowz.com

---

## Tech Stack

- **Framework**: Astro 5.x (SSR mode, deployed on Vercel)
- **Documentation**: Astro Starlight
- **Styling**: Tailwind CSS 3.x + Preline UI
- **Authentication**: Clerk
- **Payments**: Polar.sh
- **Backend**: Convex (real-time)
- **Newsletter**: Resend
- **Analytics**: PostHog + Vercel Analytics
- **Interactive Islands**: React
- **Smooth Scroll**: Lenis
- **View Transitions**: Astro native + astro-vtbot
- **i18n**: English (default) + French
- **Testing**: Vitest (unit) + Playwright (E2E)
- **Package Manager**: pnpm (required)

## Getting Started

```bash
git clone https://github.com/dianedef/winflowz.git
cd winflowz
pnpm install
pnpm dev
```

The dev server runs on port 3011.

## Commands

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start development server |
| `pnpm build` | Production build |
| `pnpm preview` | Preview production build locally |
| `pnpm test:unit` | Run unit tests (Vitest) |
| `pnpm test:e2e` | Run E2E tests (Playwright) |
| `pnpm test:coverage` | Generate coverage report |

## Project Structure

```
winflowz/
├── src/
│   ├── assets/           # Styles (global.css, starlight.css, lenis.css), scripts, images
│   ├── components/       # Astro & React components
│   │   ├── sections/     # Page sections (landing, navbar, footer, pricing)
│   │   ├── ui/           # Reusable UI (buttons, icons, TextLogo)
│   │   ├── overrides/    # Starlight component overrides
│   │   └── react/        # React interactive components
│   ├── content/          # Markdown/MDX content
│   │   ├── blog/         # Blog posts (en/, fr/)
│   │   └── docs/         # Starlight documentation
│   ├── data_files/       # Constants, JSON data
│   ├── i18n/             # Translations (en/, fr/)
│   ├── layouts/          # Layout templates
│   ├── lib/              # Core libraries (Convex, utils)
│   ├── middleware/        # CORS, i18n, rate-limit
│   ├── pages/            # Routes & API endpoints
│   │   └── api/          # API (clerk/, newsletter/)
│   ├── types/            # TypeScript definitions
│   └── utils/            # Utilities (navigation, i18n helpers)
├── convex/               # Convex backend (schema, functions, webhooks)
├── public/               # Static assets (fonts, images, OG images)
├── tests/                # Test setup & mocks
└── docs/                 # Design specs, component classes
```

## Documentation

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Claude Code instructions |
| `BUSINESS.md` | Business model and strategy |
| `BRANDING.md` | Brand identity specification |
| `SPEC-gtm.md` | GTM implementation history |
| `docs/DESIGN_SPECIFICATION.md` | Design system reference |
| `docs/COMPONENT_CLASSES.md` | CSS component class documentation |

## Deployment

The site is deployed to Vercel in server mode. To build for production:

```bash
pnpm build
```
