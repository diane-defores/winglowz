# WinFlowz — Tasks

## Completed (GTM Improvement Plan — 2026-02-14)

### Phase 1: Foundation
- [x] **Activate Clerk authentication** — uncommented in `astro.config.mjs` + `middleware/index.ts`, built sign-in page with `<SignIn />`, dashboard with auth guard, settings with `<UserProfile />`, tasks page, purchase success page
- [x] **Integrate Polar.sh payments** — installed `@polar-sh/sdk` + `@polar-sh/astro`, added subscription fields to Convex schema, created `convex/http.ts` webhook handler + `convex/polar.ts` mutations, wired pricing CTAs with `data-polar-checkout`, added embed script to LandingLayout
- [x] **Integrate Resend newsletter** — installed `resend`, created `/api/newsletter/subscribe` + `/api/newsletter/unsubscribe` API routes, created `convex/resend.ts` action, rewired `EmailFooterInput.astro` from `mailto:` to fetch API

### Phase 2: Conversion Optimization
- [x] **Create CGV page** — added `src/i18n/en/cgv.json` + `fr/cgv.json` (10 sections), `[cgv].astro` page, route in `i18n/config.ts`, links in both footer components + navigation JSONs
- [x] **Create English blog posts** — 5 posts in `src/content/blog/en/`: TTY explainer, shell comparison, security & reliability, mobile DevOps setup, **NEW** neurodivergent creator story
- [x] **Populate roadmap** — 12 hardcoded features across TubeFlowz/MediaFlowz/WinFlowz covering all 4 statuses

### Phase 3: Trust & Conversion Rate
- [x] **Refine 70k+ stat** — changed "equipped clients" → "lessons completed" in `Hero.astro` + both `home.json` i18n files
- [x] **Add CTA tracking** — `data-track` attributes + global `sendBeacon`/Vercel Analytics listener on Hero, Pricing, FinalCTA, PricingSection, EmailFooterInput
- [x] **Replace placeholder service images** — 4 descriptive SVGs (`chrome-extensions`, `obsidian-plugins`, `windows-mastery`, `productivity-suite`) in `src/assets/images/services/`, services page updated to use distinct images
- [x] **Add lead magnet** — `LeadMagnet.astro` ("Top 10 Windows Productivity Hacks" PDF offer, EN/FR), wired to Resend subscribe API, inserted between BentoGrid and Pricing on landing page

### Bug Fixes
- [x] **Fix mdi icon in FeatureCard** — replaced missing `mdi:thumb-up-outline` icon set reference with inline SVG in `src/components/roadmap/FeatureCard.astro`

---

## User Action Required

> These tasks require account setup and real credentials. The code is ready — just needs real keys.

### Clerk Authentication
- [ ] Create Clerk application at [clerk.com](https://clerk.com)
- [ ] Replace `PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_PLACEHOLDER` in `.env` with real publishable key
- [ ] Replace `CLERK_SECRET_KEY=sk_test_PLACEHOLDER` in `.env` with real secret key
- [ ] Verify sign-in flow works at `/signin`

### Convex Backend
- [ ] Create Convex project at [convex.dev](https://convex.dev)
- [ ] Replace `PUBLIC_CONVEX_URL=https://PLACEHOLDER.convex.cloud` in `.env` with real URL
- [ ] Run `npx convex dev` to push schema and deploy functions
- [ ] Set `RESEND_API_KEY` and `RESEND_AUDIENCE_ID` in Convex dashboard (for `convex/resend.ts` action)
- [ ] Set `POLAR_WEBHOOK_SECRET` in Convex dashboard (for `convex/http.ts` handler)

### Polar.sh Payments
- [ ] Create Polar.sh organization at [polar.sh](https://polar.sh)
- [ ] Create products: Free tier, Pro subscription ($9.99/mo or $7.99/yr), Enterprise (contact)
- [ ] Generate organization token → set `POLAR_ORGANIZATION_TOKEN` in `.env`
- [ ] Configure webhook endpoint: `https://your-convex-url.convex.cloud/polar/events`
- [ ] Update `data-polar-checkout-product-id` values in `Pricing.astro` with real Polar product IDs

### Resend Email
- [ ] Create Resend account at [resend.com](https://resend.com)
- [ ] Verify sending domain `winflowz.com` (DNS records)
- [ ] Replace `RESEND_API_KEY=re_PLACEHOLDER` in `.env` with real API key
- [ ] Create audience → set `RESEND_AUDIENCE_ID` in `.env`
- [ ] Test newsletter subscribe at footer form and lead magnet form

### Content & Assets
- [ ] Confirm what "70k+" actually refers to (downloads? views? lessons? enrollments?) and update if needed
- [ ] Replace SVG placeholder images on services page with actual screenshots/mockups when available
- [ ] Create or source the "Top 10 Windows Productivity Hacks" PDF for lead magnet delivery
- [ ] Review and personalize the 5 English blog posts (especially `post-4.md` founder story)

---

## Todo

- [ ] **Commit GTM changes** — all Phase 1-3 work is uncommitted (~35 modified + ~16 new files)
- [ ] **Verify mobile responsiveness** — test new/modified components (LeadMagnet, CGV, dashboard, roadmap with features) on mobile
- [ ] **Test i18n completeness** — visit all new pages in both `/en` and `/fr` routes
- [ ] **Wire roadmap to Convex** — replace hardcoded features array with live Convex queries once backend is running
- [ ] **Add Polar product IDs** — once Polar products are created, update `data-polar-checkout-product-id` attributes with real IDs
- [ ] **Create `/api/track` endpoint** — the CTA tracking `sendBeacon` posts to `/api/track` which doesn't exist yet (Vercel Analytics handles the primary tracking, but server-side beacon endpoint is missing)
- [ ] **Add newsletter form to landing Footer** — the landing `Footer.astro` has newsletter title/description but no actual form input (unlike the main `FooterSection.astro`)
- [ ] **E2E test auth flow** — once Clerk keys are live, run `pnpm test:e2e` to validate sign-in → dashboard → settings flow

## Notes

- Build passes cleanly (`pnpm build` succeeds)
- All `.env` values are PLACEHOLDERs — nothing works end-to-end until real keys are provided
- The Polar embed checkout script (`checkout.polar.sh/embed.js`) auto-opens checkout overlays for links with `data-polar-checkout` attribute
- Lead magnet and newsletter subscribe both POST to the same `/api/newsletter/subscribe` endpoint with different `source` values (`"footer"` vs `"lead-magnet"`)
- CGV page is at `/cgv` (EN) and `/fr/cgv` (FR) — same slug in both languages
