---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "WinFlowz"
created: "2026-06-11"
created_at: "2026-06-11 19:07:18 UTC"
updated: "2026-06-11"
updated_at: "2026-06-11 19:20:34 UTC"
status: draft
source_skill: 100-sf-spec
source_model: "GPT-5 Codex"
scope: "android-lifetime-deal-launch"
owner: "Diane"
confidence: medium
user_story: "En tant que propriétaire de WinFlowz, je veux vendre l'application Android WinFlowz en Lifetime Deal Early Bird avec une page dédiée, des mentions cohérentes sur le site et un plan de lancement vérifiable, afin de commencer les ventes sans promesse produit, paiement ou accès non prouvée."
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "winflowz_site"
  - "winflowz_app Android"
  - "Astro public sales pages"
  - "Product content collection"
  - "Commerce checkout"
  - "Lemon Squeezy provider"
  - "Convex suite bridge"
  - "Public editorial governance"
  - "Launch planning"
  - "Pricing research"
  - "Competitor analysis"
depends_on:
  - artifact: "shipflow_data/business/winflowz_app/product.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/business/winflowz_app/branding.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/business/winflowz_app/gtm.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/editorial/content-map.md"
    artifact_version: "1.0.1"
    required_status: "reviewed"
  - artifact: "shipflow_data/editorial/public-surface-map.md"
    artifact_version: "1.0.1"
    required_status: "reviewed"
  - artifact: "shipflow_data/editorial/claim-register.md"
    artifact_version: "1.0.1"
    required_status: "reviewed"
  - artifact: "shipflow_data/technical/design-system-authority.md"
    artifact_version: "1.0.0"
    required_status: "draft"
  - artifact: "shipflow_data/technical/platforms/lemonsqueezy.md"
    artifact_version: "unknown"
    required_status: "reviewed"
supersedes: []
evidence:
  - "User request 2026-06-11: commencer à vendre l'application Android WinFlowz en Lifetime Deal Early Bird."
  - "User request 2026-06-11: créer une page de vente pour le Lifetime Deal."
  - "User request 2026-06-11: vérifier les mentions cohérentes du produit et les liens sur le site."
  - "User request 2026-06-11: planifier un lancement."
  - "User decision context 2026-06-11: pricing must not be guessed because cloud sync and future cloud-dependent features can create material cost and bankruptcy risk."
  - "User request 2026-06-11: run competitor/pricing analysis before deciding the Early Bird price."
  - "shipflow_data/business/winflowz_app/product.md states Android is the first advanced native surface and the Android keyboard is Android-only."
  - "shipflow_data/business/winflowz_app/gtm.md allows LTD/AppSumo messaging but warns against unverified billing, quotas, universal offline voice, and universal platform parity claims."
  - "shipflow_data/editorial/claim-register.md marks Lifetime access and priority support as sensitive/unverified claims unless offer policy proof exists."
  - "winflowz_site/src/content/products/{fr,en}/winflowz.md currently presents WinFlowz as Windows training, not the Android voice-first app."
  - "winflowz_site/src/lib/commerce/offers.ts currently contains only socialglowz/lifetime_deal as a generic commerce offer."
  - "winflowz_site/src/pages/api/commerce/checkout.ts defaults to socialglowz/lifetime_deal when offerId is omitted."
  - "winflowz_site/src/pages/api/polar/checkout.ts is tied to gated course lessons, not a general app LTD checkout."
next_step: "/204-sf-market-study WinFlowz Android LTD pricing audit"
---

# Spec: WinFlowz Android Lifetime Deal Launch

## Title

WinFlowz Android Lifetime Deal Launch

## Status

Draft created on 2026-06-11 from Diane's launch request and a repository scan of the WinFlowz app business docs, editorial governance, product pages, navigation, and checkout code. Diane confirmed on 2026-06-11 that this launch must use Lemon Squeezy because Polar is not currently available. Diane also clarified that price must not be decided by instinct: cloud sync and future cloud-dependent features can create material cost and bankruptcy risk, so an explicit pricing/competitor audit is required before setting the Early Bird price. The chantier is intentionally high-risk because it touches public claims, payment routing, access promises, pricing sustainability, and launch planning. It is not ready for implementation until the Early Bird offer policy is explicit enough for public copy and checkout validation.

## User Story

En tant que propriétaire de WinFlowz, je veux vendre l'application Android WinFlowz en Lifetime Deal Early Bird avec une page dédiée, des mentions cohérentes sur le site et un plan de lancement vérifiable, afin de commencer les ventes sans promesse produit, paiement ou accès non prouvée.

## Minimal Behavior Contract

Quand un visiteur arrive sur les surfaces publiques WinFlowz, le site doit présenter clairement l'application Android WinFlowz comme l'offre Early Bird disponible maintenant, expliquer ce qui est inclus dans le Lifetime Deal, orienter les liens pertinents vers une page de vente dédiée haut de gamme, puis envoyer l'acheteur vers un checkout Lemon Squeezy configuré pour l'offre WinFlowz Android sans réutiliser par erreur une offre SocialGlowz ou formation Windows. La page de vente doit être suffisamment belle, crédible et persuasive pour servir de surface de lancement principale: direction visuelle forte, hiérarchie nette, assets produit réels ou mockups Android soignés, argumentaire commercial complet, CTA répétés sans agressivité, et limites honnêtes. Si le checkout, le prix, l'accès après achat, ou une preuve produit manque, le site doit afficher une attente honnête ou bloquer la mise en vente plutôt que publier un CTA trompeur. L'edge case facile à rater est la confusion de marque: le site contient encore des mentions de WinFlowz comme formation Windows, alors que cette vente vise l'application Android voice-first.

## Success Behavior

- La page de vente dédiée existe en français et en anglais, avec des routes stables, par exemple `/fr/winflowz-android-lifetime-deal` et `/winflowz-android-lifetime-deal`, ou une alternative documentée dans la spec avant implémentation.
- Le prix Early Bird est fondé sur un audit pricing/concurrents et sur une hypothèse de coût soutenable, pas sur une intuition ou un prix bas par peur de vendre.
- La première vue annonce l'offre littérale: WinFlowz Android, Lifetime Deal, Early Bird, disponibilité Android uniquement pour l'instant, avec un rendu visuel premium immédiatement identifiable.
- La page n'utilise pas un template produit générique: elle a une composition de landing/sales page dédiée, une proposition de valeur forte, des sections de persuasion, une lecture mobile excellente et des assets produit visibles.
- Les visuels montrent le produit ou un état produit inspectable: captures réelles de l'app Android, mockups téléphone construits à partir de captures, ou assets bitmap générés puis validés visuellement. Les visuels purement abstraits, flous, décoratifs ou sans lien produit ne suffisent pas.
- La page décrit les bénéfices prouvables: dictée, transcription, nettoyage/copie, clipboard, snippets, dictionnaire, overlay/quick actions Android, clavier Android si confirmé par l'app actuelle.
- La page distingue les capacités vérifiées, les prérequis et les limites: Android first, clés BYO locales pour modes avancés, packs vocaux locaux seulement pour langues supportées, pas de promesse de parité toutes plateformes.
- Les CTA de vente utilisent un `offerId` WinFlowz Android dédié, par exemple `winflowz_android/lifetime_deal`, ou un lien externe explicitement choisi par Diane et documenté.
- Le produit WinFlowz dans `src/content/products/{fr,en}/winflowz.md` est réaligné avec l'application Android ou scindé pour éviter de confondre formation Windows et app Android.
- La navigation, le footer, la homepage, le catalogue produits, les pages pertinentes et les articles Android existants créent un chemin cohérent vers l'offre.
- Le plan de lancement existe dans un artefact durable et couvre le pré-lancement, la publication, les preuves checkout, les contenus de promotion, les objections, et le suivi post-lancement.
- Les claims sensibles sont reflétés dans `shipflow_data/editorial/claim-register.md` avec preuve, downgrade ou blocage.
- Les tests et preuves de build confirment que le site compile, que les liens internes existent, que l'offre checkout est reconnue, et que les anciennes surfaces ne renvoient pas vers la mauvaise offre.

## Error Behavior

- Si le prix Early Bird n'est pas décidé ou disponible depuis le fournisseur de paiement, la page ne doit pas inventer de prix public; elle doit soit utiliser une source de vérité configurée, soit rester non publiée, soit afficher une liste d'attente non payante selon décision explicite.
- Si le checkout WinFlowz Android n'est pas configuré, les CTA de paiement ne doivent pas rediriger vers `socialglowz/lifetime_deal`, `/api/polar/checkout` formation, ou un produit fournisseur ambigu.
- Si le webhook ou la création d'accès après achat n'est pas prouvé, la copie ne doit pas promettre "accès instantané" ou "activation automatique" sans mécanisme vérifié.
- Si un visiteur non Android lit la page, le contenu doit expliquer honnêtement que la vente actuelle concerne Android et ne doit pas promettre clavier système, overlay ou parité native hors Android.
- Si une surface publique reste incohérente après migration, la vérification doit échouer avec la surface et la mention fautive.
- Si des secrets, IDs fournisseurs réels ou payloads clients apparaissent dans docs, tests, captures ou logs, le chantier doit être bloqué et redirigé vers nettoyage sécurité.

## Problem

WinFlowz veut commencer à vendre l'application Android, mais le site et les contrats commerce ne sont pas encore alignés avec cette vente. Le contenu produit `winflowz.md` décrit actuellement une formation Windows, la homepage et le pricing parlent de plans génériques, et le checkout générique Lemon Squeezy est centré sur SocialGlowz. Polar existe dans le monorepo mais n'est pas disponible pour ce lancement et le checkout Polar actuel est lié aux cours. Une page de vente isolée risquerait donc de créer une promesse publique sans paiement fiable, sans cohérence produit, et sans plan de lancement.

## Solution

Créer un chantier de lancement en trois blocs: une page de vente Android LTD Early Bird, un réalignement transverse des mentions et liens publics, et un plan de lancement vérifiable. L'implémentation doit d'abord établir une source de vérité d'offre et de checkout pour WinFlowz Android, puis construire la page et les liens autour de cette source, avec des claims limités aux preuves disponibles.

## Scope In

- Créer une page de vente dédiée bilingue pour l'offre WinFlowz Android Lifetime Deal Early Bird.
- Créer une vraie direction de page de vente premium: hero, preuve visuelle produit, storytelling problème-solution, sections bénéfices, offre LTD, limites honnêtes, FAQ, CTA et réassurance.
- Produire ou intégrer des assets visuels adaptés: captures app Android existantes, mockups téléphone, visuels hero ou images générées si les captures disponibles ne suffisent pas.
- Définir ou intégrer un identifiant d'offre commerce dédié à l'app Android, distinct de SocialGlowz et de la formation Windows.
- Réaliser un audit pricing/concurrents avant de fixer le prix public Early Bird.
- Mettre à jour les CTA pour utiliser le checkout correct ou une route d'attente explicitement non payante si la vente immédiate est bloquée.
- Réaligner `winflowz_site/src/content/products/fr/winflowz.md` et `winflowz_site/src/content/products/en/winflowz.md` pour supprimer la confusion formation Windows vs app Android.
- Auditer et corriger les mentions et liens sur homepage, landing, product catalog, product detail, navigation, footer, blog Android, docs publiques et pages de prix pertinentes.
- Mettre à jour les contrats éditoriaux touchés: `claim-register.md`, `public-surface-map.md`, `content-map.md`, et éventuellement `page-intent-map.md`.
- Créer un plan de lancement durable sous `shipflow_data/business/` ou `shipflow_data/workflow/launches/` avec calendrier, canaux, assets, checklist de preuves, risques et suivi post-lancement.
- Ajouter ou mettre à jour les tests unitaires commerce, route, contenu ou snapshot texte nécessaires.
- Valider la page en navigateur local avec desktop et mobile, console et liens CTA.

## Scope Out

- Déployer en production sans validation explicite.
- Encaisser un paiement réel ou manipuler des secrets fournisseur depuis la spec.
- Construire de nouvelles fonctionnalités Android dans l'app.
- Promettre une app iOS, desktop ou web avec parité native complète.
- Mettre en place AppSumo, affiliation, programme partenaire ou marketplace externe complet sauf si Diane le décide dans un chantier séparé.
- Refaire toute la marque WinFlowz ou toute la homepage au-delà des chemins nécessaires vers l'offre.
- Résoudre toutes les dettes SocialGlowz/commerce générique hors besoin WinFlowz Android LTD.

## Constraints

- Respecter la règle monorepo: governance dans `shipflow_data/` à la racine, site dans `winflowz_site/`, app dans `winflowz_app/`.
- Préserver le français naturel et accentué sur les surfaces publiques françaises.
- Ne pas ajouter de secrets, IDs fournisseurs réels, emails clients ou payloads checkout dans le repo.
- Ne pas publier de prix, quota, durée de promo, nombre de places, "support prioritaire", "lifetime updates", ou "accès instantané" sans source d'offre ou politique documentée.
- Ne pas réutiliser `socialglowz/lifetime_deal` pour WinFlowz Android.
- Ne pas laisser `/api/commerce/checkout` tomber silencieusement sur l'offre SocialGlowz quand une page WinFlowz appelle un checkout sans `offerId`.
- Les changements UI du site doivent consommer les tokens déclarés dans `winflowz_site/src/assets/styles/global.css` et `winflowz_site/tailwind.config.mjs`.
- La page de vente ne doit pas être une page catalogue ou une section pricing générique recyclée. Elle doit être conçue comme une surface de lancement principale.
- La hero doit utiliser un visuel produit fort ou une scène bitmap pertinente; ne pas créer une hero fondée uniquement sur gradient/SVG décoratif ou texte seul.
- Les cartes peuvent encadrer des éléments répétés, mais la page ne doit pas devenir une pile de cartes imbriquées. Les sections principales doivent rester lisibles, amples et orientées conversion.
- La page doit rester professionnelle sur mobile: aucun texte tronqué, bouton débordant, CTA caché, ou visuel qui masque le contenu.
- Les nouvelles routes publiques doivent rester compatibles Astro static/prerender sauf besoin explicite de runtime.
- Le plan de lancement doit séparer "prêt à publier la page", "prêt à encaisser", "prêt à livrer accès", et "prêt à promouvoir largement".
- Aucun prix Early Bird ne doit être codé ou publié tant que l'audit pricing/concurrents n'a pas produit une recommandation soutenable et que Diane ne l'a pas validée.

## Test Contract

- Surface: Astro pages publiques, content collections, navigation/footer, commerce offer registry, checkout route, editorial governance docs, launch plan.
- Proof profile: automated site checks + commerce unit tests + browser proof + manual operator review before production launch.
- Proof order:
  1. Static/content proof: scans de mentions produit, liens et claims sensibles.
  2. Automated local proof: `pnpm build:check`, `pnpm test:unit`, targeted commerce tests.
  3. Design/token proof: `python3 /home/claude/shipflow/tools/design_system_drift_check.py --changed --format markdown`.
  4. Browser proof: local or preview desktop and mobile screenshots for the sales page, homepage/product links, and checkout CTA behavior.
  5. Commerce proof: provider test-mode checkout or explicitly documented "checkout not launched" block.
  6. Manual launch review: Diane confirms price, offer wording, support/access policy, and launch calendar before paid promotion.
- Required scenario IDs:
  - `WFZ-LTD-001`: French sales page explains Android-only Early Bird LTD and has a valid CTA state.
  - `WFZ-LTD-002`: English sales page matches the French offer without adding unsupported claims.
  - `WFZ-LTD-003`: product catalog and detail pages route visitors to the Android offer without describing WinFlowz only as Windows training.
  - `WFZ-LTD-004`: checkout route recognizes the WinFlowz Android offer and never defaults a WinFlowz CTA to SocialGlowz.
  - `WFZ-LTD-005`: claims scan finds no unsupported universal offline, all-platform, quota, billing, or instant-access promises.
  - `WFZ-LTD-006`: launch plan contains pre-launch, launch-day, and post-launch tasks with proof owners.
  - `WFZ-LTD-007`: mobile viewport renders CTA, offer summary, limits, FAQ, and proof sections without overlap or clipped text.
  - `WFZ-LTD-008`: page quality review confirms the route feels like a premium sales page, not a generic product detail page.
  - `WFZ-LTD-009`: hero and product visuals render nonblank, product-relevant, and correctly framed on mobile and desktop.
  - `WFZ-LTD-010`: pricing recommendation cites competitor prices, LTD precedents where available, cloud-cost risk, and a clear no-bankruptcy floor.
- Required viewports:
  - Mobile: `390x844`.
  - Desktop: `1440x900`.
- Required visual evidence:
  - Screenshot of the hero/first viewport on mobile and desktop.
  - Screenshot of the offer/CTA section on mobile and desktop.
  - Browser console check with no runtime errors.
  - Link/CTA inspection proving Lemon Squeezy offer routing.
- Exception with proof: no Android APK build is required for the site launch page unless the copy introduces a product capability not already documented in the app business/product specs.
- Exception without proof: no real payment transaction is required locally; test-mode provider proof or explicit blocked launch status is acceptable before production credentials are used.

## Dependencies

- `winflowz_site/src/pages/[...lang]/index.astro`: homepage route and landing composition.
- `winflowz_site/src/pages/[...lang]/[products].astro`: product catalog route.
- `winflowz_site/src/pages/[...lang]/[products_slug].astro`: current product detail template.
- `winflowz_site/src/content/products/fr/winflowz.md` and `winflowz_site/src/content/products/en/winflowz.md`: current product content to realign.
- `winflowz_site/src/components/shared/site/Navbar.astro`: navigation CTA and language path mapping.
- `winflowz_site/src/components/shared/site/Footer.astro`: footer links and product promise copy.
- `winflowz_site/src/components/astro/landing/Pricing.astro`: generic pricing section that may need downgrade or offer-specific routing.
- `winflowz_site/src/lib/commerce/offers.ts`: commerce offer source of truth.
- `winflowz_site/src/pages/api/commerce/checkout.ts`: checkout entrypoint.
- `winflowz_site/src/lib/commerce/providers/lemonsqueezy.ts`: direct checkout provider.
- `winflowz_site/src/lib/commerce/providers/polar.ts`: Polar checkout provider behavior, explicitly out of scope for this launch except regression safety.
- `winflowz_site/tests/commerce/*.test.ts`: commerce validation surface.
- `shipflow_data/business/winflowz_app/product.md`, `branding.md`, `gtm.md`: app offer and claim boundaries.
- `shipflow_data/editorial/claim-register.md`: sensitive public claim registry.
- `shipflow_data/technical/platforms/lemonsqueezy.md`: current provider contract for LTD checkout, currently SocialGlowz-specific.

## Invariants

- WinFlowz Android LTD is a separate offer from SocialGlowz LTD and from Windows Mastery training.
- Public copy must make Android availability clear before the first paid CTA.
- Claims must stay inside the app target-reviewed truth: Android-native entrypoints first, BYO keys local, supported language packs only, no universal offline promise, no all-platform parity promise.
- A buyer must not be able to click a WinFlowz Android CTA and land in a SocialGlowz or Windows training checkout by default.
- Checkout metadata must preserve `offer_id`, `product_id`, `plan`, and source attribution for fulfillment and support.
- Launch content can be ambitious in positioning, but exact access/support/payment promises require proof.
- Bilingual pages must stay semantically aligned; English cannot strengthen claims that French avoids.

## Links & Consequences

- Commerce code may need to move from SocialGlowz-specific helpers toward multi-product offer helpers, or deliberately add a bounded WinFlowz Android path without broad abstraction drift.
- If fulfillment remains manual for Early Bird, the page must state the delivery expectation plainly and the launch plan must include manual grant/reconciliation steps.
- If automatic entitlement is required before launch, this chantier may need a focused `601-sf-product-entitlements` sub-route before `102-sf-start`.
- Lemon Squeezy is the selected provider for this launch; provider docs and env examples must add WinFlowz Android-specific keys and tests.
- Polar is not available for this launch; the existing course-specific route must not be stretched into an app LTD route.
- Homepage and product catalog SEO may shift from Windows training first to Android app first; update page intent docs if this is intentional.
- The existing Windows Mastery page can keep selling training, but must not be the primary CTA for the Android LTD.

## Documentation Coherence

- Update `shipflow_data/editorial/claim-register.md` for Lifetime Deal, Early Bird, Android-only availability, support, access, language packs, and checkout claims.
- Update `shipflow_data/editorial/content-map.md` and `public-surface-map.md` if new route families or launch surfaces are added.
- Update `shipflow_data/technical/platforms/lemonsqueezy.md` because Lemon Squeezy handles WinFlowz Android offers for this launch.
- Update `winflowz_site/README.md` and `.env.example` if new checkout environment variables are introduced.
- Create a launch plan artifact, recommended path: `shipflow_data/business/winflowz-android-lifetime-deal-launch-plan.md`.
- Add a changelog entry only at closure/ship, after implementation is verified.

## Edge Cases

- Visitor arrives from a blog article about Android keyboard and expects immediate app download.
- Visitor is on iOS/desktop and sees Android-only purchase offer.
- Checkout provider is configured for one product but env vars point to another provider product.
- `offerId` is omitted in a CTA URL and defaults to SocialGlowz.
- Provider checkout succeeds but entitlement/access is manual or pending review.
- Early Bird price changes after launch assets are published.
- Lifetime Deal includes future updates but not every future platform or premium AI cost.
- Support promise is operationally weaker than "priority support" copy.
- Product page and training page both use the name WinFlowz and compete in search/navigation.
- French and English pages diverge in legal/commercial meaning.
- A static page is cached after the offer closes.

## Implementation Tasks

- [ ] Task 1: Run the WinFlowz Android LTD pricing audit.
  - File: `shipflow_data/business/winflowz-android-ltd-pricing-audit.md`
  - Action: Research direct and adjacent competitors, current pricing, LTD/AppSumo history where public, pricing tiers, cloud-cost exposure, support burden, and sustainable Early Bird price bands.
  - User story link: prevents underpricing an offer with cloud-dependent costs.
  - Depends on: competitor seed list and Diane's target market assumptions.
  - Validate with: cited sources, dated pricing evidence, and a recommended no-bankruptcy floor.
  - Notes: Use current web sources for pricing and acquisition/history claims; do not infer private revenue or company outcomes without sources.

- [ ] Task 2: Decide and encode the WinFlowz Android offer contract.
  - File: `winflowz_site/src/lib/commerce/offers.ts`
  - Action: Add a dedicated Lemon Squeezy-backed offer id, product id, plan, sources, provider candidates, and helper tests for WinFlowz Android LTD.
  - User story link: prevents the app offer from using SocialGlowz or training checkout by mistake.
  - Depends on: Task 1 and Diane price/access decision.
  - Validate with: `pnpm test tests/commerce/offers.test.ts`.
  - Notes: Use `offerId=winflowz_android/lifetime_deal`, `productId=winflowz_android`, `plan=lifetime_deal`, `providers=["lemonsqueezy"]`.

- [ ] Task 3: Add provider configuration for WinFlowz Android checkout.
  - File: `winflowz_site/src/lib/commerce/offers.ts`, `winflowz_site/src/lib/commerce/providers/lemonsqueezy.ts`, `winflowz_site/.env.example`
  - Action: Add Lemon Squeezy env var names and provider mapping for the Android LTD without reusing SocialGlowz variant IDs.
  - User story link: enables a real paid CTA.
  - Depends on: Task 2.
  - Validate with: `pnpm test tests/commerce/offers.test.ts tests/commerce/checkoutRoute.test.ts tests/commerce/lemonsqueezy.test.ts`.
  - Notes: Expected env names should be product-specific, for example `LEMONSQUEEZY_WINFLOWZ_ANDROID_PRODUCT_ID` and `LEMONSQUEEZY_WINFLOWZ_ANDROID_LIFETIME_DEAL_VARIANT_ID`.

- [ ] Task 4: Harden checkout defaults.
  - File: `winflowz_site/src/pages/api/commerce/checkout.ts`
  - Action: Remove or constrain silent fallback to `socialglowz/lifetime_deal`; require explicit offerId for paid product CTAs unless the route is intentionally SocialGlowz-specific.
  - User story link: prevents wrong-product checkout.
  - Depends on: Task 2.
  - Validate with: `pnpm test tests/commerce/checkoutRoute.test.ts`.
  - Notes: Existing SocialGlowz tests must remain explicit.

- [ ] Task 5: Define the premium sales-page creative direction.
  - File: `shipflow_data/business/winflowz-android-lifetime-deal-launch-plan.md` or a page-local implementation note inside the spec before code.
  - Action: Specify visual direction, page narrative, section order, CTA rhythm, asset plan, and claim boundaries before writing the page.
  - User story link: ensures the page is magnificent and commercially coherent, not merely present.
  - Depends on: Tasks 1-4 and offer-policy decisions.
  - Validate with: operator review or explicit acceptance inside readiness.
  - Notes: Keep direction compatible with site tokens and Android-first product truth.

- [ ] Task 6: Create or collect product visuals for the sales page.
  - File: `winflowz_site/public/images/**` or `winflowz_site/src/assets/images/**`
  - Action: Add screenshots, phone mockups, or generated bitmap hero/product assets that show the Android app clearly and support the sales argument.
  - User story link: gives the page the visual quality needed for launch.
  - Depends on: Task 5.
  - Validate with: browser screenshot proof at required viewports.
  - Notes: Prefer real app screenshots when available; generated assets are acceptable only if they do not misrepresent product state.

- [ ] Task 7: Create the bilingual Android LTD sales page.
  - File: `winflowz_site/src/pages/[...lang]/winflowz-android-lifetime-deal.astro` or agreed localized route files.
  - Action: Implement offer sections: hero, Android-only availability, problem, app workflows, included features, Early Bird offer, limits, FAQ, support/access policy, CTA, and risk-reducing proof.
  - User story link: creates the main conversion surface.
  - Depends on: Tasks 1-6 or explicit non-payment CTA decision.
  - Validate with: `pnpm build:check` and browser proof at `390x844` and `1440x900`.
  - Notes: Use site tokens from `global.css`/Tailwind; no one-off visual literals.

- [ ] Task 8: Realign product content entries.
  - File: `winflowz_site/src/content/products/fr/winflowz.md`, `winflowz_site/src/content/products/en/winflowz.md`
  - Action: Change product narrative from Windows training to the Android app, or split training and app into distinct product entries if both need catalog presence.
  - User story link: removes brand/offer confusion.
  - Depends on: Task 7 route decision.
  - Validate with: `pnpm build:check` and content scan.
  - Notes: Windows Mastery should remain the training offer, not the app product page.

- [ ] Task 9: Audit and update public links and mentions.
  - File: `winflowz_site/src/pages/[...lang]/index.astro`, `winflowz_site/src/components/shared/site/Navbar.astro`, `winflowz_site/src/components/shared/site/Footer.astro`, `winflowz_site/src/components/astro/landing/Pricing.astro`, `winflowz_site/src/content/blog/**`
  - Action: Add or adjust links to the Android LTD page where relevant; remove or downgrade incoherent generic pricing and wrong-product CTAs.
  - User story link: makes the launch discoverable.
  - Depends on: Tasks 7-8.
  - Validate with: `rg -n "WinFlowz|Lifetime|Early Bird|Android|maitrise-windows|windows-mastery|socialglowz/lifetime_deal" winflowz_site/src` plus browser proof.
  - Notes: Do not over-link from unrelated utility pages unless contextually useful.

- [ ] Task 10: Update editorial and technical governance.
  - File: `shipflow_data/editorial/claim-register.md`, `shipflow_data/editorial/content-map.md`, `shipflow_data/editorial/public-surface-map.md`, `shipflow_data/technical/platforms/lemonsqueezy.md`, `winflowz_site/README.md`
  - Action: Document new route, claim boundaries, provider env vars, and checkout proof requirements.
  - User story link: keeps future launches and edits from reintroducing unsafe claims.
  - Depends on: Tasks 1-9.
  - Validate with: `/home/claude/shipflow/tools/shipflow_metadata_lint.py AGENT.md shipflow_data`.
  - Notes: Only update Lemon Squeezy docs if that provider is actually used.

- [ ] Task 11: Create the launch plan.
  - File: `shipflow_data/business/winflowz-android-lifetime-deal-launch-plan.md`
  - Action: Document pre-launch checklist, launch-day sequence, channels, content assets, launch copy angles, objection handling, proof gates, support workflow, refund/revoke/manual access handling, and post-launch metrics.
  - User story link: turns the page into an executable launch, not just a landing page.
  - Depends on: offer/access policy decision.
  - Validate with: metadata lint and operator review.
  - Notes: Include separate statuses for page-ready, checkout-ready, access-ready, and broad-promotion-ready.

- [ ] Task 12: Add tests and scans for launch safety.
  - File: `winflowz_site/tests/commerce/*.test.ts`, optional new `winflowz_site/tests/content/*.test.ts`
  - Action: Cover WinFlowz Android offer recognition, checkout route behavior, explicit offer IDs, and absence of wrong-product CTA defaults.
  - User story link: prevents regressions that would send buyers to the wrong product.
  - Depends on: Tasks 1-9.
  - Validate with: `pnpm test:unit`.
  - Notes: Prefer deterministic local tests over provider network calls.

- [ ] Task 13: Run final local and browser proof.
  - File: `winflowz_site` and proof artifacts under `shipflow_data/workflow/verification/` if screenshots/logs are recorded.
  - Action: Run build/test/drift checks, then inspect pages in browser for desktop/mobile layout, console errors, broken internal links, and CTA behavior.
  - User story link: proves the launch surface is usable before release.
  - Depends on: Tasks 1-12.
  - Validate with: `pnpm build:check`, `pnpm test:unit`, design drift check, browser proof.
  - Notes: Production deploy proof is a separate `004-sf-deploy`/`405-sf-prod` step.

## Acceptance Criteria

- [ ] CA 1: Given a visitor opens the French LTD route, when the page loads, then it clearly presents WinFlowz Android Lifetime Deal Early Bird and Android-only current availability before the first paid CTA.
- [ ] CA 2: Given a visitor opens the English LTD route, when the page loads, then it mirrors the French offer without stronger unsupported claims.
- [ ] CA 3: Given a paid CTA is rendered, when its href or request payload is inspected, then it targets a WinFlowz Android offer id or an explicitly approved external checkout, never SocialGlowz or Windows training.
- [ ] CA 4: Given checkout provider env vars are absent, when the checkout route is called for WinFlowz Android, then it returns an honest unavailable error and does not fallback to another offer.
- [ ] CA 5: Given the product catalog renders WinFlowz, when a buyer reads it, then the catalog does not describe only Windows training while pointing to an Android app sale.
- [ ] CA 6: Given site-wide scan runs after implementation, when mentions of Lifetime Deal, Early Bird, Android, checkout, and support are reviewed, then unsupported claims are either removed, downgraded, or backed by documented proof.
- [ ] CA 7: Given the homepage and navigation are loaded in French and English, when a high-intent visitor looks for the app offer, then a coherent route to the LTD page exists without breaking existing core navigation.
- [ ] CA 8: Given the mobile viewport is `390x844`, when the sales page is viewed, then CTA, offer summary, limits, FAQ, and checkout note do not overlap, clip, or require horizontal scroll.
- [ ] CA 9: Given the sales page first viewport is viewed on desktop and mobile, when Diane reviews it, then it feels like a premium launch page with product-relevant visuals, not a generic catalog page.
- [ ] CA 10: Given product visuals are loaded, when browser proof captures the page, then the assets are nonblank, framed correctly, and do not misrepresent unsupported product capabilities.
- [ ] CA 11: Given the pricing audit is complete, when Diane reviews the Early Bird recommendation, then it includes a competitor-backed price band, cloud-cost risk, support burden, and a minimum viable price floor.
- [ ] CA 12: Given the launch plan is opened, when Diane prepares launch day, then she can see the exact proof gates and tasks before sending traffic.
- [ ] CA 13: Given claim-register is updated, when a future agent edits copy, then it can identify which Lifetime Deal, support, access, language-pack, and platform claims are safe.

## Test Strategy

- Run `pnpm -C winflowz_site build:check`.
- Run `pnpm -C winflowz_site test:unit`.
- Run targeted commerce tests after offer/checkout edits: `pnpm -C winflowz_site test tests/commerce/offers.test.ts tests/commerce/checkoutRoute.test.ts tests/commerce/lemonsqueezy.test.ts`.
- Run ShipFlow metadata lint after governance edits: `/home/claude/shipflow/tools/shipflow_metadata_lint.py AGENT.md shipflow_data`.
- Run design drift check after UI edits: `python3 /home/claude/shipflow/tools/design_system_drift_check.py --changed --format markdown`.
- Use browser proof for the new page, homepage, product catalog, and CTA path on mobile and desktop.
- Use provider test mode or mocked provider tests for checkout. Do not use real customer/payment data in local proof.

## Risks

- Publicly promising a price, access, or support policy that is not operationally ready.
- Underpricing the LTD and creating an unsustainable obligation if cloud sync, storage, support, or future cloud features carry recurring cost.
- Sending buyers to the wrong product because commerce defaults still point to SocialGlowz.
- Confusing WinFlowz training and WinFlowz Android app under the same product slug.
- Treating "lifetime" as all future platforms, all future AI costs, all language packs, or unlimited support.
- Adding one-off visual code to a high-stakes sales page outside design tokens.
- Producing a page that is correct but commercially weak: generic layout, weak hero, no product visuals, no offer framing, or no reason to buy now.
- Using generated or decorative visuals that make the product look more mature, cross-platform, or polished than the current Android truth supports.
- Launching traffic before fulfillment, refund/revoke, and support handling are documented.
- Updating English and French copy unevenly, creating legal/commercial mismatch.

## Execution Notes

- Read first: `shipflow_data/business/winflowz_app/product.md`, `shipflow_data/business/winflowz_app/gtm.md`, `shipflow_data/editorial/claim-register.md`, `winflowz_site/src/lib/commerce/offers.ts`, and `winflowz_site/src/content/products/fr/winflowz.md`.
- Implementation should start with the offer/checkout source of truth, not the visual page, because public CTAs depend on correct payment behavior.
- Pricing must start with a market/pricing audit before any public price is hardcoded. The audit should compare direct voice/transcription/dictation tools, adjacent productivity tools, AppSumo/LTD precedents where public, and cloud-cost exposure.
- After the offer source is clear, implementation should treat page quality as a first-class deliverable: build the sales narrative and visual direction before coding the final route.
- Before finishing, run browser screenshot proof and inspect the page visually. A passing build is not enough for this chantier.
- If no real app screenshots are available, create a bounded asset plan: either capture screenshots from the app/web surface or generate honest bitmap visuals that clearly represent the Android offer without inventing unsupported UI.
- If Diane chooses manual fulfillment for Early Bird, the page may ship with a paid checkout only if copy and launch plan state the delivery expectation honestly.
- If automatic entitlement is required, route through `601-sf-product-entitlements` before implementing checkout fulfillment.
- Fresh external docs are required before changing provider API behavior for Lemon Squeezy. Current spec scan used local provider docs only; implementation must verify official Lemon Squeezy docs if provider integration code changes.
- Stop if exact Early Bird price, Lemon Squeezy product/variant, access delivery policy, or support promise remains undefined and the page would need to publish those claims.
- Stop if pricing is chosen without an evidence-backed no-bankruptcy floor.
- Stop if checkout proof is unavailable but the proposed launch status claims "ready to sell."

## Open Questions

- Pending pricing audit: what Early Bird price, currency, and tax/VAT display should be published?
- Resolved 2026-06-11: Lemon Squeezy owns the first paid launch; Polar is unavailable for now.
- What exactly does "Lifetime Deal" include: Android app only, future Android updates, cloud sync, local packs, BYO AI features, future desktop/iOS/web access, support tier?
- After purchase, is access automatic, manual, activation-code based, or "APK/download + email" for Early Bird?
- Is the first launch language French-first, English-first, or bilingual at the same time?
- Is there a hard Early Bird limit, deadline, seat count, or price increase date? If yes, what proof/source owns that policy?

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-11 19:20:34 UTC | 100-sf-spec | GPT-5 Codex | Added pricing audit as a prerequisite before setting the Early Bird price, including competitor pricing, LTD history where sourced, cloud-cost exposure, support burden, and no-bankruptcy floor. | partial | Run /204-sf-market-study WinFlowz Android LTD pricing audit. |
| 2026-06-11 19:15:06 UTC | 100-sf-spec | GPT-5 Codex | Strengthened the spec to require a premium, visually persuasive sales page with product visuals, dedicated creative direction, visual proof, and acceptance criteria against generic catalog-page output. | partial | Clarify remaining offer policy, then rerun readiness. |
| 2026-06-11 19:13:17 UTC | 100-sf-spec | GPT-5 Codex | Integrated Diane's provider decision: WinFlowz Android LTD launch uses Lemon Squeezy for now because Polar is unavailable. Updated scope, tasks, dependencies, and open questions accordingly. | partial | Clarify price, LTD inclusion, access delivery, launch language, and Early Bird limit/deadline; then rerun readiness. |
| 2026-06-11 19:09:56 UTC | 101-sf-ready | GPT-5 Codex | Reviewed the launch spec against readiness criteria. Structure, scope, risks, dependencies, acceptance criteria, and proof plan are strong enough, but implementation is blocked by material business/payment decisions: Early Bird price/currency, provider, exact Lifetime Deal inclusion, access delivery, launch languages, and any limit/deadline. | not ready | Clarify offer policy, then rerun readiness. |
| 2026-06-11 19:07:18 UTC | 100-sf-spec | GPT-5 Codex | Created the WinFlowz Android Lifetime Deal launch spec from user request plus local scan of app business docs, editorial claim governance, product pages, navigation, checkout routes, and commerce offer code. | draft | /101-sf-ready shipflow_data/workflow/specs/winflowz-android-lifetime-deal-launch.md |

## Current Chantier Flow

| Step | Status | Evidence | Next |
|------|--------|----------|------|
| 100-sf-spec | partial | Draft spec created on 2026-06-11, updated with Lemon Squeezy as selected provider, strengthened to require premium sales-page quality, and updated to require pricing audit before setting price. | Run pricing audit. |
| 101-sf-ready | not ready | Readiness review on 2026-06-11 found blocking offer-policy questions. Provider is resolved to Lemon Squeezy; price now depends on pricing audit. Remaining blockers are exact LTD inclusion, access delivery, launch languages, and limit/deadline. | Run pricing audit and clarify offer policy, then rerun readiness. |
| 102-sf-start | pending | Not started. | Wait for ready spec. |
| 103-sf-verify | pending | Not started. | After implementation. |
| 104-sf-end | pending | Not started. | After verification. |
| 005-sf-ship | pending | Not started. | After closure and explicit ship scope. |
