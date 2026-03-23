# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed
- Clean up unused docs and legacy files (AUTH_ANALYSIS, BRANDING_SPECIFICATION, copilot-instructions)
- Remove Dependabot configuration
- Simplify README
- Update BRANDING.md wording

### Removed
- Remove GUIDELINES.md
- Remove legacy TASKS.md content

## [0.9.0] — 2026-03-17

### Added
- CLAUDE.md project instructions for Claude Code
- BRANDING.md comprehensive brand guidelines
- BUSINESS.md business model documentation
- GUIDELINES.md development guidelines
- Starlight documentation: 8 training modules (productivity, Windows config, time management, actions, content consumption, knowledge management, social tools, keyboard shortcuts)
- Privacy policy page with bilingual support (EN/FR)
- ShipFlow inspector and Eruda debug tools for development

### Changed
- Restructure CONTENU/ course content with metadata headers
- Update astro.config.mjs with new integrations
- Update landing layout with additional scripts

## [0.8.0] — 2026-03-09

### Added
- Draft field for blog content schema
- Future pubDate filtering (posts with future dates hidden from listings)

## [0.7.0] — 2026-02-24

### Added
- Bilingual /bio link-in-bio page (EN + FR)

## [0.6.0] — 2026-02-23

### Added
- Astro-native landing page components replacing React versions (Hero, BentoGrid, Pricing, Footer, Navbar, LogoMarquee, FinalCTA)
- LeadMagnet component for email capture
- Polar.sh payment integration (Convex function)
- Resend newsletter integration (Convex function + Clerk webhook HTTP router)
- Newsletter subscribe/unsubscribe API endpoints
- CGV (Terms of Service) page with bilingual translations (EN/FR)
- 5 English blog posts (blog-1, post-1 through post-4)
- SVG illustrations for service pages (Chrome extensions, Obsidian plugins, productivity suite, Windows mastery)
- CookieConsent banner component
- TestimonialCarousel React component
- KeyboardShortcutAnim, PluginActivityTicker, SmartOrgAnim interactive React components
- MobileMenu React component
- SPEC-gtm.md go-to-market specification

### Changed
- Rewrite landing page from React/Framer Motion to Astro components with targeted React islands
- Update navigation structure with expanded menu items
- Improve ContactSection layout
- Refine FAQ content
- Update global CSS with new design tokens

### Removed
- React landing page components (hero, bento-grid, footer, navbar, pricing, logo-marquee, final-cta, smooth-scroll)

## [0.5.0] — 2026-02-13

### Added
- Convex backend schema (users, apiKeys, features) with Clerk webhook integration
- React landing page with Framer Motion animations (Hero, BentoGrid, Testimonials carousel, Pricing with billing toggle)
- Brand color system from animated logo gradient
- v0.md listing deleted v0 projects for regeneration
- CONTENU/ directory with Windows productivity course content

### Changed
- Replace Supabase with Convex + Clerk for authentication and backend
- Archive old landing page at /landing route

### Removed
- All Supabase auth, API keys, payment, and OAuth code
- OAuth button components (Facebook, Github, Google)
- AuthenticationIsland component
- Unused NewsletterSection component

## [0.4.0] — 2026-01-25

### Added
- Squashed history initial commit with full application structure
- Roadmap page with Kanban board, feature cards, project navigation, and voting
- Starlight documentation setup with custom theme, hero, and site title components
- i18n system (EN/FR) with translation files for all pages
- FAQ component
- PricingSection with PricingCard blocks
- Service pages with content collections
- Blog system with French posts (blog-1, post-1 through post-3)
- Dashboard pages (main, settings, tasks)
- Authentication pages (signin, register, recover)
- Legal pages: copyright, disclaimer, legal notices, privacy policy
- API routes for auth, features, payments, API key management
- LanguagePicker component
- TestimonialFolio and testimonial components
- BrandLogo with TextLogo CSS component
- Contact section with form
- Products section with scroll bar
- PrimaryCTA and SecondaryCTA button components
- Supabase integration for auth and data
- BMAD project management framework

## [0.3.0] — 2025-12-01

### Added
- Comprehensive branding specification document
- Code comments across core modules for maintainability
- Copilot instructions for repository onboarding

### Fixed
- Light mode navbar: add subtle shadow and border
- Typography progression in pricing section
- Mobile spacing and typography for better readability

### Changed
- Replace PNG logo with CSS TextLogo in FooterSection, NavbarMegaMenu, and SiteTitle

## [0.2.0] — 2025-11-29

### Added
- French 404 page and About Us pages with translations

### Fixed
- Hamburger menu not working after Astro View Transitions (HSCollapse initialization)
- Build error with lazy initialization for Supabase client and fallback env vars
- Vercel deployment by removing invalid routes config
- JSON syntax error in en/home.json

### Changed
- Update Astro and Starlight packages with breaking changes fix
- Update dependencies: vitest 4.x, nanoid 5.x, sharp 0.34.x, postcss 8.5.x, jsdom 27.x, prettier-plugin-tailwindcss 0.7.x
- Disable edge middleware

## [0.1.0] — 2025-01-10

### Added
- i18n internationalization system (EN/FR)
- Blog system with working post pages
- Language picker component
- Prerendering configuration
- ScrewFast branding replaced with WinFlowz branding

### Changed
- Replace ScrewFast template references with WinFlowz

## [0.0.2] — 2024-12-20

### Added
- Roadmap page with per-project views
- Dark mode improvements
- Product descriptions with scroll bar
- Legal pages (mentions legales)
- Supabase registration (register via Supabase)
- Dashboard page
- OAuth authentication
- Supabase API integration

### Fixed
- Registration modal
- Button styling
- TypeScript errors

### Changed
- Improve dark mode across roadmap and other pages

## [0.0.1] — 2024-10-27

### Added
- Initial project setup from ScrewFast Astro template (via Vercel)
- Custom logo and brand link colors
- Base component library (FeaturesGeneral, FeaturesNavs, FeaturesStats, Navbar, Footer, Hero)
- Starlight documentation integration
- Tailwind CSS configuration
- Lenis smooth scroll
