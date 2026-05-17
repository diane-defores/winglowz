---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "WinFlowz Suite"
created: "2026-05-17"
created_at: "2026-05-17 08:05:27 UTC"
updated: "2026-05-17"
updated_at: "2026-05-17 13:13:31 UTC"
status: reviewed
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "unified-suite-authentication"
owner: "Diane"
user_story: "En tant que builder de la suite WinFlowz, je veux une identité client unique avec des droits séparés par produit, afin qu'un utilisateur puisse réutiliser le même compte partout sans recevoir automatiquement accès à tous les produits."
confidence: medium
risk_level: high
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "winflows.com / WinFlowz Formation"
  - "WinFlowz Flutter app"
  - "TubeFlow / YouTube product"
  - "VoiceFlowz historical tracker, now legacy naming for WinFlowz app"
  - "Firebase Auth"
  - "Google Cloud Identity Platform"
  - "Firestore Security Rules"
  - "Clerk"
  - "Convex"
  - "Polar"
  - "Google Play / App Store future purchases"
depends_on:
  - artifact: "docs/explorations/2026-05-16-unified-suite-auth.md"
    artifact_version: "1.0.0"
    required_status: "draft"
  - artifact: "docs/DECISIONS.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/technical/architecture.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/technical/guidelines.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/workflow/specs/firebase-backend-agnostic-migration.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "/home/claude/shipflow_data/specs/master-auth-playbook.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "User request 2026-05-17: one account across winflows.com, WinFlowz app, and YouTube product, with access or no access per product."
  - "docs/explorations/2026-05-16-unified-suite-auth.md found no binding decision requiring separate auth per product."
  - "docs/explorations/2026-05-16-unified-suite-auth.md found VoiceFlowz historical task 'Configure Clerk for auth (shared with WinFlowz)'. User later clarified VoiceFlowz / VoiceFlows is the old name of the WinFlowz app, not a separate product."
  - "docs/DECISIONS.md targets Firebase Auth + Firestore as first hosted adapter for the WinFlowz Android app, not as a suite-wide identity decision."
  - "shipflow_data/technical/architecture.md requires user ownership from backend auth context, not client-provided ids."
  - "firestore.rules currently scopes WinFlowz app data under users/{uid} and denies cross-user access."
  - "Official Firebase, Google Identity Platform, Auth0, and Clerk docs checked 2026-05-17 for shared app resources, custom claims limits, tenant boundaries, SSO, and cross-origin session token behavior."
  - "Canonical decision documented 2026-05-17 in /home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md: Clerk central identity, Firebase Android bridge, server-owned entitlements."
next_step: "/sf-spec unified-suite-authentication readiness fixes"
---

# Title

Unified WinFlowz Suite Authentication

# Status

Reviewed, but not ready for `/sf-start` after the 2026-05-17 13:13 UTC readiness gate. The product direction and provider gate are explicit: Clerk is the long-term suite identity provider, Firebase Auth remains the WinFlowz Android app adapter for now, and a server-owned bridge maps Firebase users to `global_user_id`. The first proof pair is WinFlowz Formation plus the WinFlowz Android app, but the WinFlowz Formation implementation repository/backend path was not available in the local workspace during readiness review, and active local docs still contain Clerk-as-legacy wording that must be reconciled before implementation starts.

# User Story

En tant que builder de la suite WinFlowz, je veux une identité client unique avec des droits séparés par produit, afin qu'un utilisateur puisse réutiliser le même compte partout sans recevoir automatiquement accès à tous les produits.

Acteur principal: builder WinFlowz Suite.

Acteurs secondaires:

- utilisateur qui s'inscrit sur un produit puis essaie un autre produit;
- utilisateur existant sur le site WinFlowz Formation;
- utilisateur existant ou futur de l'app WinFlowz Android;
- utilisateur existant ou futur de TubeFlow;
- opérateur support;
- systèmes de paiement et d'entitlement: Polar, stores mobiles, grants manuels;
- backends produit: Firebase/Firestore, Clerk/Convex, futurs backends.

Déclencheurs:

- un utilisateur crée ou utilise un compte dans un produit de la suite;
- ce même utilisateur essaie de se connecter à un autre produit;
- un paiement, remboursement, grant manuel ou achat store mobile modifie un droit produit;
- un backend produit doit autoriser une lecture ou écriture user-scoped;
- un compte existant apparaît dans plusieurs providers avec la même adresse email.

Résultat observable attendu: l'utilisateur peut se reconnaître avec le même compte sur les produits WinFlowz, mais chaque produit vérifie ses propres droits avant d'afficher ou de muter des données. Un compte sans entitlement voit un état professionnel "même compte, accès non actif" au lieu d'un faux accès, d'un crash ou d'une inscription dupliquée.

# Minimal Behavior Contract

La suite accepte une identité client globale et associe cette identité à des entitlements par produit. Une authentification réussie prouve qui est la personne; elle ne donne accès qu'aux produits dont l'entitlement est actif. Quand l'utilisateur arrive sur un produit sans droit actif, le produit reconnaît son compte, explique que l'accès n'est pas activé et propose le chemin approprié sans créer un second compte. En cas d'échec provider, token, paiement, migration ou backend, aucun droit n'est élargi, aucune donnée produit n'est exposée, et le diagnostic reste redigé. L'edge case facile à rater est le doublon email: deux comptes historiques avec la même adresse ne doivent jamais être fusionnés silencieusement.

# Success Behavior

- Given un utilisateur crée un compte sur un produit, when il tente de se connecter à un autre produit de la suite avec le même identifiant, then le système reconnaît la même identité globale ou propose un linking explicite sans duplicat silencieux.
- Given un utilisateur a un compte global mais aucun droit TubeFlow, when il ouvre TubeFlow, then il voit un état connecté sans accès produit, avec un CTA achat/waitlist/support selon le produit, et aucune donnée TubeFlow privée n'est lue.
- Given un utilisateur a un entitlement actif `winflowz_app`, when il se connecte à l'app WinFlowz, then l'app peut utiliser son identité globale et ses données restent sous un namespace produit protégé.
- Given un webhook Polar ou store mobile confirme un achat, when l'événement est vérifié, then une ligne entitlement idempotente est créée ou mise à jour pour le bon `global_user_id`, le bon `product_id`, le bon plan et le bon statut.
- Given un remboursement, expiration ou révocation arrive, when le backend entitlements le traite, then l'accès produit est retiré sans supprimer l'identité globale ni les données conservées selon la policy produit.
- Given un backend reçoit une requête produit, when il valide le token de session, then il vérifie aussi l'entitlement et le namespace produit côté serveur avant toute donnée sensible.
- Preuve de succès attendue: matrice provider décidée, contrat `Global Identity / Entitlements / Product Data` documenté, règles ou checks backend écrits, tests d'accès autorisé/refusé, test webhook idempotent, smoke inter-produit sur au moins deux produits.

# Error Behavior

- Provider indisponible ou mal configuré: le produit affiche une erreur récupérable et journalise provider, environnement et code redigés; il ne bascule pas vers un accès produit implicite.
- Compte non reconnu dans le provider central: le produit propose création de compte ou migration/linking explicite selon le statut historique; il ne crée pas automatiquement plusieurs identités pour le même utilisateur.
- Doublon email historique: le système bloque la fusion automatique et crée un dossier de linking explicite avec preuve de possession des deux sessions ou intervention support.
- Entitlement absent: le produit affiche "compte reconnu, accès non actif" et refuse les lectures/mutations produit côté backend.
- Entitlement expiré, remboursé ou révoqué: le produit garde l'identité globale, désactive les capacités premium et expose un état clair; il ne supprime pas brutalement les données sans policy écrite.
- Token valide mais audience/issuer/app incorrect: le backend refuse avec 401/403 et ne tente pas de faire confiance à un email, user id client ou header non signé.
- Webhook paiement invalide, rejoué ou partiel: l'événement est rejeté ou gardé en état `pending_review`, sans grant produit.
- Cross-origin session manquante: l'app web/API demande un bearer token ou redirige vers l'auth centrale; elle ne dépend pas d'un cookie tiers implicite.
- Ce qui ne doit jamais arriver: accès produit accordé par simple existence d'un compte, fusion silencieuse sur email seul, stockage durable d'entitlements seulement dans des custom claims, user id fourni par le client utilisé pour l'autorisation, token/session secret loggué, cross-product data leak, tenant produit traité comme identité commune alors qu'il isole des utilisateurs.

# Problem

Les produits WinFlowz ont grandi avec des stacks d'auth différentes: WinFlowz app cible Firebase Auth/Firestore, le site WinFlowz Formation a des traces Clerk/Convex/Polar, TubeFlow a des traces Clerk/Convex/YouTube OAuth, et le playbook auth workspace recommande surtout un propriétaire de session par runtime. Rien dans les documents locaux ne justifie une séparation durable des comptes par produit. À l'inverse, une séparation produit créerait des doublons de comptes, plus de support, plus de reset password, plus de surface de configuration auth et une expérience moins professionnelle.

Le risque opposé est de confondre "un compte" et "accès à tout". Une identité globale mal modélisée peut élargir les permissions, mélanger des données produit, casser les paiements, ou fusionner des utilisateurs historiques à tort.

# Solution

Adopter un modèle suite en trois couches: identité globale, entitlements par produit, et données produit namespacées. La cible produit est un seul compte client réutilisable sur les produits first-party WinFlowz. L'accès reste contrôlé par des entitlements serveur, stockés dans une source de vérité durable, et vérifiés par chaque backend avant toute donnée produit.

L'implémentation doit être progressive. La première tranche ne migre pas tous les produits en une passe: elle applique la décision canonique `Clerk central + Firebase Android bridge`, écrit le contrat d'identité, crée le registre d'entitlements, puis prouve le flux sur WinFlowz Formation et l'app WinFlowz Android avant d'élargir.

# Scope In

- Décision d'architecture sur le modèle d'identité suite:
  - une identité globale;
  - entitlements séparés par produit;
  - données produit namespacées et gardées côté backend;
  - environnements local/preview/staging/prod séparés.
- Provider et bridge de première tranche:
  - Clerk est le provider central long terme de l'identité suite;
  - Firebase Auth reste l'adaptateur auth de l'app WinFlowz Android;
  - un bridge serveur mappe Firebase `uid` et Clerk user id vers `global_user_id`;
  - Auth0 reste un fallback enterprise futur, pas le choix de première tranche;
  - Firebase/Identity Platform tenants par produit restent rejetés pour l'identité consumer suite.
- Modèle de données:
  - `global_users`;
  - `identity_accounts`;
  - `product_entitlements`;
  - `product_access_events`;
  - namespaces produit.
- Canon initial `product_id`:
  - `winflowz_formation`;
  - `winflowz_app`;
  - `tubeflow`.
  - Legacy VoiceFlowz / VoiceFlows references map to `winflowz_app`, not to a separate product id.
- Contrats de token et backend:
  - issuer/audience/app id vérifiés;
  - user id global non fourni par le client;
  - entitlement vérifié serveur avant accès produit;
  - custom claims limitées aux flags courts/cache, pas source de vérité.
- Migration des comptes existants:
  - inventaire Clerk/Firebase/Convex/Polar;
  - linking explicite;
  - politique doublon email;
  - rollback par produit.
- UX produit:
  - connecté sans accès;
  - accès expiré/remboursé;
  - compte déjà existant;
  - linking requis;
  - support diagnostic redigé.
- Tests et vérification:
  - accès accordé/refusé;
  - webhook idempotent;
  - cross-product sign-in;
  - session restore;
  - sign-out;
  - data isolation.
- Documentation:
  - décision provider;
  - contrat d'identité suite;
  - setup env/provider;
  - runbook migration/support.

# Scope Out

- Pas de grant automatique à tous les produits parce qu'un compte existe.
- Pas de migration simultanée de tous les produits en une seule release.
- Pas de refonte pricing ou packaging produit hors entitlements nécessaires.
- Pas d'enterprise SSO/SAML, organisations/team admin ou multi-tenant B2B tant qu'un produit B2B ne l'exige pas.
- Pas de suppression de Firebase Auth dans l'app WinFlowz avant qu'un bridge ou provider central prouvé existe.
- Pas de suppression de Clerk/Convex/Polar côté site sans spec de migration propre.
- Pas d'Auth0, SAML, enterprise orgs ou provider alternatif dans la première tranche.
- Pas de merge automatique de comptes historiques sur email seul.
- Pas de stockage de secrets, tokens, payload OAuth ou clés provider dans docs, logs, analytics, Firestore client-readable ou support copy.

# Constraints

- Authentification et autorisation sont séparées: identité globale ne vaut pas entitlement.
- Chaque runtime garde un seul propriétaire de session documenté.
- Les environnements local, preview, staging et production restent séparés dans les providers, callbacks et secrets.
- Les données produit restent namespacées par `product_id` et `global_user_id` ou par chemins équivalents protégés.
- Les backends valident issuer, audience, expiration, signature et subject avant de mapper une session.
- Les produits ne font jamais confiance à un `user_id`, `global_user_id`, `product_id` ou `entitlement` fourni par le client.
- Les custom claims peuvent accélérer l'UI ou porter un rôle court, mais la source de vérité des entitlements est serveur.
- Les tenants Identity Platform ne sont pas le modèle par défaut des produits: un tenant isole des utilisateurs, ce qui contredit l'objectif d'un compte unique.
- Toute migration de compte historique doit être réversible ou au minimum auditable.
- Le premier proof doit couvrir WinFlowz Formation et l'app WinFlowz Android, sinon on n'a pas prouvé la promesse suite.
- Les `product_id` internes sont une allowlist stable. Les IDs externes Polar, Clerk Billing, Google Play, App Store ou Stripe restent des références de source (`source_ref`) et ne remplacent pas `product_id`.

# Dependencies

## Local Dependencies

- `docs/explorations/2026-05-16-unified-suite-auth.md`: exploration source, aucune décision solide trouvée contre l'identité partagée.
- `docs/DECISIONS.md`: WinFlowz app cible Firebase Auth + Firestore comme premier adaptateur Android.
- `shipflow_data/technical/architecture.md`: l'identité distante vient du backend auth context, pas du client.
- `shipflow_data/technical/guidelines.md`: ne pas ajouter de nouveau couplage Convex/Clerk/Supabase dans l'app WinFlowz cible.
- `firestore.rules`: isolation actuelle sous `users/{uid}` pour l'app WinFlowz.
- `/home/claude/shipflow_data/specs/master-auth-playbook.md`: standard transverse d'un propriétaire de session par runtime.
- `/home/claude/shipflow_data/projects/VoiceFlowz/TASKS.md`: legacy tracker for the app now known as WinFlowz app; trace historique "Configure Clerk for auth (shared with WinFlowz)".
- `/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md`: décision canonique du projet principal WinFlowz.

## Fresh External Docs Checked

- Firebase project docs, checked 2026-05-17: apps in the same Firebase project share backends including Authentication and Firestore. Source: https://firebase.google.com/docs/projects/learn-more
- Firebase custom claims docs, checked 2026-05-17: custom claims are for access-control data, are included in ID tokens, and are limited to 1000 bytes. Source: https://firebase.google.com/docs/auth/admin/custom-claims
- Google Cloud Identity Platform multi-tenancy docs, checked 2026-05-17: tenants create user/configuration silos and are most common for B2B isolation. Source: https://cloud.google.com/identity-platform/docs/multi-tenancy
- Auth0 SSO docs, checked 2026-05-17: SSO centralizes authentication across applications and domains through a central auth domain/session model. Source: https://auth0.com/docs/authenticate/single-sign-on
- Auth0 B2B auth guidance, checked 2026-05-17: with more than one application, best practice is a centralized authentication location; native apps should use system browser/OIDC-style flows. Source: https://auth0.com/docs/get-started/architecture-scenarios/business-to-business/authentication
- Clerk authenticated requests docs, checked 2026-05-17: same-origin requests can include session automatically; cross-origin requests require bearer token forwarding. Source: https://clerk.com/docs/guides/development/making-requests

Fresh-docs verdict: `fresh-docs checked`. The docs support the architecture direction, and the provider direction is now documented canonically as Clerk central identity plus a Firebase Android bridge.

# Invariants

- One person can have one global suite identity.
- One global identity can have zero, one, or many product entitlements.
- Product access is denied by default.
- Entitlement state is server-owned and auditable.
- Product data is private by default and scoped to product plus user.
- Product sites can remain separate websites while sharing identity.
- A shared identity does not require shared product database tables for all data.
- Existing users are not silently merged.
- Support diagnostics identify provider/environment/failure layer without exposing secrets.
- The suite auth layer must make future MFA/passkeys possible without rewriting every product.

# Links & Consequences

- `docs/DECISIONS.md`: needs a local pointer clarifying that Firebase remains the app's current adapter while Clerk is the suite identity target.
- `shipflow_data/technical/architecture.md`: needs a "Suite Identity" section or linked doc separating global identity from product data.
- `shipflow_data/technical/guidelines.md`: must allow a provider bridge or central provider decision without violating the app's backend-agnostic rule.
- `firestore.rules`: may need product namespace and entitlement checks if WinFlowz app begins using shared suite IDs or shared entitlement docs.
- `lib/features/auth/domain/auth_session_store.dart`: may need `globalUserId`, `suiteAccountStatus`, and provider metadata separate from Firebase `uid`.
- `lib/features/auth/application/auth_session_provider.dart`: may need a `SuiteIdentitySession` adapter or bridge.
- `lib/features/*/application/*_store_provider.dart`: must continue selecting stores from auth state without trusting client-provided IDs.
- WinFlowz Formation site: Clerk/Convex/Polar user and entitlement model must be audited before linking to suite identity.
- TubeFlow: Clerk/Convex/YouTube OAuth must remain separate from suite login; YouTube OAuth grants product permissions, not suite identity.
- Support/docs: account help must explain "same account, access depends on product" without advertising unrelated products prematurely.

# Documentation Coherence

Update or create:

- `/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md`: canonical suite identity, entitlement, migration and support contract.
- `docs/technical/suite-authentication.md`: local app pointer to the canonical decision.
- `docs/DECISIONS.md`: reviewed pointer for shared suite identity principle and selected provider/bridge.
- `shipflow_data/technical/architecture.md`: linked suite identity architecture and data boundaries.
- `shipflow_data/technical/guidelines.md`: coding rules for global identity, entitlement checks, provider boundaries and redaction.
- Product docs for WinFlowz app, WinFlowz Formation and TubeFlow: login/access copy, setup env, smoke steps.
- `.env.example` or equivalent per product: auth domain, audience, issuer, callback, webhook secret names, without real secrets.
- Support runbook: duplicate email, account linking, entitlement missing, refund/revoke, provider outage.
- Changelog entry only after an implementation tranche is actually shipped.

# Edge Cases

- User has Firebase account in WinFlowz app and Clerk account on WinFlowz Formation with same email.
- User uses Google provider in one product and email/password in another.
- User changes email in the provider after buying a product.
- User signs in to a product where they have no entitlement.
- User buys while signed out, then signs in with an email that already exists in another provider.
- Payment webhook arrives before provider user creation finishes.
- Payment webhook is retried or arrives out of order after refund.
- User deletes account in one product but has entitlements/data in another product.
- User signs out from one product while another has an active central session.
- A cross-origin app fails to forward the bearer token.
- A mobile app cannot use browser SSO cookies and needs token/session exchange.
- Product id is misspelled or omitted in entitlement checks.
- Custom claims are stale after entitlement update.
- Firestore rules or Convex functions check identity but forget product entitlement.
- Support manually grants access to the wrong product or environment.

# Implementation Tasks

- [ ] Tâche 1 : Aligner les docs locales WinFlowz app sur la décision canonique
  - Fichiers : `docs/DECISIONS.md`, `shipflow_data/technical/architecture.md`, `shipflow_data/technical/guidelines.md`, `docs/technical/suite-authentication.md`
  - Action : préciser que Clerk est l'identité suite long terme, Firebase Auth reste l'adaptateur Android, et le bridge Firebase `uid` -> `global_user_id` est obligatoire avant accès suite.
  - User story link : évite que l'app Android recrée un domaine d'auth séparé ou migre prématurément vers Clerk Flutter/native.
  - Depends on : none.
  - Validate with : `rg -n "Clerk|Firebase Auth|global_user_id|suite identity|entitlement" docs/DECISIONS.md shipflow_data/technical docs/technical/suite-authentication.md`.
  - Notes : ne pas présenter Clerk Flutter/native comme chemin Android production tant qu'un smoke device dédié ne le prouve pas.

- [ ] Tâche 2 : Écrire le contrat canonique Global Identity / Entitlements / Product Data
  - Fichiers : `/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md`, `docs/technical/suite-authentication.md`, futurs docs API/backend du registre d'entitlements.
  - Action : définir ou confirmer `global_user_id`, `identity_accounts`, `product_entitlements`, `product_access_events`, `product_id`, `plan`, `status`, `source`, `source_ref`, `environment`, timestamps, idempotency keys et audit events.
  - User story link : permet même compte sans accès automatique.
  - Depends on : Tâche 1.
  - Validate with : contrat relu contre WinFlowz app et WinFlowz Formation; aucun champ `user_id`, `global_user_id`, `product_id` ou entitlement client-trusted.
  - Notes : les entitlements longs restent en DB; token claims seulement cache court ou flags non source de vérité.

- [ ] Tâche 3 : Ajouter les contrats domaine côté app pour identité suite et entitlement
  - Fichiers : `lib/features/auth/domain/suite_identity.dart`, `lib/features/auth/domain/product_entitlement.dart`, `lib/features/auth/domain/suite_identity_store.dart`, tests associés sous `test/`
  - Action : créer des modèles typés pour `globalUserId`, provider accounts, `productId`, plan/status/source, et une interface de lecture d'identité suite sans exposer de provider SDK à l'UI.
  - User story link : permet à l'app d'afficher "compte reconnu, accès produit actif/non actif" sans confondre auth Firebase et droit produit.
  - Depends on : Tâche 1, Tâche 2.
  - Validate with : `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test test/*suite* test/*entitlement*`.
  - Notes : utiliser `ProductId` allowlist, pas une string libre venue du client.

- [ ] Tâche 4 : Auditer les comptes et IDs existants avant linking
  - Fichiers : `/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md`, docs d'audit redigées du repo WinFlowz Formation quand disponible.
  - Action : lister sources utilisateurs et paiements: Firebase Auth, Clerk users, Convex users/course entitlements, Polar customer/subscription/order ids, TubeFlow users et YouTube OAuth grants.
  - User story link : empêche merge silencieux et perte d'accès.
  - Depends on : Tâche 2.
  - Validate with : inventaire documenté par produit; cas doublon email catégorisés; aucun secret exporté dans le repo.
  - Notes : utiliser des comptes de test ou métriques agrégées; ne pas commit de PII.

- [ ] Tâche 5 : Implémenter ou spécifier le registre d'entitlements serveur
  - Fichiers : repo WinFlowz Formation/Convex quand disponible, `/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md`, docs API/backend du registre.
  - Action : créer ou spécifier la source de vérité `product_entitlements` avec writes idempotents depuis Polar/Clerk Billing futur/app stores/grants manuels et reads contrôlés côté serveur.
  - User story link : un compte peut exister sans accès produit.
  - Depends on : Tâche 2, Tâche 4.
  - Validate with : tests create/update/revoke/idempotency; cross-product deny; webhook replay deny.
  - Notes : les règles doivent refuser par défaut et ne jamais accorder depuis payload client.

- [ ] Tâche 6 : Adapter WinFlowz app au contrat suite sans casser Firebase local-first
  - Fichiers : `lib/features/auth/domain/auth_session_store.dart`, `lib/features/auth/application/auth_session_provider.dart`, `lib/features/auth/data/firebase_auth_session_store.dart`, `lib/features/settings/presentation/settings_screen.dart`, `firestore.rules`, nouveaux fichiers de la Tâche 3.
  - Action : exposer l'identité suite ou mapping bridge quand disponible, afficher accès `winflowz_app` selon entitlement, conserver fallback local explicite, et garder données app sous namespace protégé.
  - User story link : l'app WinFlowz participe au compte unique sans perdre sa sécurité Android/Firebase.
  - Depends on : Tâche 3, Tâche 5.
  - Validate with : `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`, smoke Android auth + entitlement.
  - Notes : ne pas remplacer Firebase Auth dans cette première tranche; adapter derrière contrat backend-agnostic.

- [ ] Tâche 7 : Adapter WinFlowz Formation checkout/account au contrat suite
  - Fichiers : repo/site WinFlowz concerné; docs site; endpoint Polar webhook.
  - Action : mapper Clerk/Convex/Polar ou provider choisi vers `global_user_id`, créer/mettre à jour entitlement formation, et afficher état compte/access.
  - User story link : un acheteur formation devient compte suite sans accès automatique aux apps.
  - Depends on : Tâche 5.
  - Validate with : test public lesson -> login -> checkout -> webhook -> lesson privée; refund/revoke; duplicate email.
  - Notes : Polar webhook signature et idempotency obligatoires.

- [ ] Tâche 8 : Adapter TubeFlow sans confondre YouTube OAuth et suite identity
  - Fichiers : repo TubeFlow concerné; auth/session docs; YouTube OAuth routes.
  - Action : connecter la session suite au produit TubeFlow, mais garder les tokens YouTube comme grants produit séparés et révocables.
  - User story link : même compte pour entrer dans TubeFlow, mais YouTube reste une permission externe spécifique.
  - Depends on : Tâche 5, Tâche 7.
  - Validate with : login suite; no entitlement deny; entitlement allow; YouTube connect/disconnect; sign-out.
  - Notes : ne jamais utiliser un refresh token YouTube comme identité suite; cette tâche peut attendre la preuve WinFlowz Formation + app Android.

- [ ] Tâche 9 : Écrire le flow UX/support "compte reconnu, accès non actif"
  - Fichiers : produits concernés; `/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md`; support runbook.
  - Action : standardiser messages pour accès absent, expiré, refund, linking requis, doublon email, provider outage.
  - User story link : facilite l'accès à tes produits sans forcer l'utilisateur à connaître toute la suite.
  - Depends on : Tâche 2, Tâche 5.
  - Validate with : snapshots/widget/browser checks selon produit; messages sans promesse d'accès automatique.
  - Notes : ne pas faire de cross-sell agressif dans les produits où l'utilisateur n'a rien demandé.

- [ ] Tâche 10 : Vérifier la première tranche inter-produit avant ship
  - Fichiers : `docs/VERIFICATION.md`, `shipflow_data/workflow/TEST_LOG.md`, docs produit concernées.
  - Action : consigner smoke réel WinFlowz Formation + WinFlowz Android app: signup/signin, entitlement allow, entitlement deny, session restore, sign-out, webhook grant/revoke, backend data deny.
  - User story link : prouve que le compte unique est vendable et sécurisé.
  - Depends on : Tâches 6 et 7.
  - Validate with : logs de test redigés; aucune PII/token; checks automatisés passés.
  - Notes : sans ce proof, ne pas annoncer l'auth suite comme shipped.

# Acceptance Criteria

- [ ] CA 1 : Given la spec est relue, when on cherche la décision produit, then elle dit clairement "identité suite unique, entitlements séparés, accès refusé par défaut".
- [ ] CA 2 : Given un agent frais lit la spec et la décision canonique WinFlowz, when il cherche le provider de première tranche, then il voit Clerk central identity + Firebase Android bridge sans option concurrente active.
- [ ] CA 3 : Given un utilisateur possède un compte global sans entitlement produit, when il ouvre ce produit, then il est reconnu mais l'accès produit est refusé côté UI et backend.
- [ ] CA 4 : Given un utilisateur possède un entitlement actif, when il ouvre le produit correspondant, then le backend autorise seulement les données de ce produit et de cet utilisateur.
- [ ] CA 5 : Given un utilisateur possède des comptes historiques avec la même adresse email dans deux providers, when la migration détecte ce cas, then aucune fusion automatique n'a lieu sans linking explicite ou support review.
- [ ] CA 6 : Given un webhook paiement valide est reçu deux fois, when il est traité, then l'entitlement final est correct et aucun double grant incohérent n'est créé.
- [ ] CA 7 : Given un webhook invalide, expiré ou signé avec le mauvais secret est reçu, when il est traité, then aucun entitlement n'est créé ou élargi.
- [ ] CA 8 : Given un token session a le mauvais issuer/audience/environment, when un backend produit le reçoit, then la requête est refusée.
- [ ] CA 9 : Given custom claims existent, when un entitlement change, then le backend continue de lire la source de vérité serveur et ne dépend pas d'un token stale pour autoriser une mutation sensible.
- [ ] CA 10 : Given un utilisateur se déconnecte d'un produit, when il revient sur une route protégée, then la session locale produit et l'accès backend sont invalidés selon le provider choisi.
- [ ] CA 11 : Given un utilisateur TubeFlow connecte YouTube, when il se déconnecte de YouTube, then son identité suite reste intacte mais les permissions YouTube produit sont retirées.
- [ ] CA 12 : Given la première tranche est proposée au ship, when `sf-verify` relit les preuves, then WinFlowz Formation et WinFlowz Android app prouvent compte, entitlement allow/deny, backend deny et sign-out.

# Test Strategy

- Unit tests:
  - product id allowlist validation for `winflowz_formation`, `winflowz_app`, `tubeflow`;
  - legacy VoiceFlowz / VoiceFlows references map to `winflowz_app` and cannot create a separate entitlement namespace;
  - entitlement model validation;
  - duplicate email/linking policy;
  - token claims parsing without trusting client input;
  - webhook idempotency and invalid signature behavior;
  - provider mapping from Firebase/Clerk IDs to `global_user_id`.
- Backend/security tests:
  - unauthenticated deny;
  - authenticated no-entitlement deny;
  - wrong product deny;
  - wrong user deny;
  - expired/refunded entitlement deny;
  - valid entitlement allow.
- App/web tests:
  - connected without access state;
  - access active state;
  - route guard restore;
  - sign-out cleanup;
  - account already exists/linking required copy.
- Manual smoke:
  - create test user through WinFlowz Formation / Clerk;
  - open WinFlowz Android app with no `winflowz_app` entitlement;
  - grant `winflowz_app` entitlement via test webhook/manual admin;
  - retry WinFlowz Android app access;
  - revoke entitlement;
  - verify backend denies after revoke.
- Documentation checks:
  - `rg -n "global_user_id|product_entitlements|suite identity|entitlement|tenant|custom claims" docs shipflow_data`;
  - redaction review for logs and support examples.

# Risks

- High: the Clerk central + Firebase Android bridge can create account-linking complexity if mapping and duplicate-email rules are not server-owned and auditable.
- High: silent account merge by email can hand data or purchases to the wrong person.
- High: entitlement bugs can grant paid products incorrectly or deny paying users.
- High: storing too much authorization state in token custom claims creates stale access and size/performance problems.
- High: tenants per product would reintroduce separate user silos and defeat the user story.
- Medium: shared identity increases auth incident blast radius; MFA, rate limits, audit logs and provider monitoring become more important.
- Medium: product UX may accidentally advertise all products to users who only wanted one; copy must stay contextual.
- Medium: multiple providers during bridge phase add operational complexity and support burden.
- Medium: mobile app SSO differs from web SSO; native flows may need system browser/OIDC rather than cookie sharing.

# Execution Notes

- Read first:
  - `docs/explorations/2026-05-16-unified-suite-auth.md`;
  - `docs/DECISIONS.md`;
  - `shipflow_data/technical/architecture.md`;
  - `/home/claude/shipflow_data/specs/master-auth-playbook.md`;
  - `/home/claude/shipflow_data/projects/winflowz/docs/technical/suite-authentication.md`;
  - current Clerk, Firebase, Convex and billing docs relevant to the implementation slice.
- Start with docs/contract alignment, then code the smallest bridge/entitlement slice.
- Keep the first implementation slice narrow: WinFlowz Formation plus WinFlowz Android app.
- Prefer provider-neutral domain contracts in WinFlowz app; do not make Flutter UI depend directly on a new provider SDK unless Task 1 selects that provider.
- Treat product IDs as an allowlist, not free-form user input.
- Store entitlements in a server-controlled database with audit trail; custom claims can mirror compact status only after source-of-truth checks.
- Use separate dev/staging/prod providers, callbacks, webhook secrets and test users.
- Stop conditions:
  - provider verdict diverges from the canonical WinFlowz decision;
  - WinFlowz Formation repo or backend path is unavailable for the first proof pair;
  - account linking requires real user PII export without a redaction plan;
  - a backend can only enforce entitlements client-side;
  - webhook signature verification is unavailable;
  - a product would ship "same account" before deny/allow tests pass.

# Open Questions

None.

Resolved decisions:

- Provider gate: Clerk central identity + Firebase Android bridge.
- First proof pair: WinFlowz Formation + WinFlowz Android app.
- Product ID canon: internal allowlist `winflowz_formation`, `winflowz_app`, `tubeflow`; historical VoiceFlowz / VoiceFlows references map to `winflowz_app`; external billing IDs are stored as `source_ref`, not used as canonical `product_id`.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-17 08:05:27 UTC | sf-spec | GPT-5 Codex | Created unified suite authentication chantier spec from user request, local exploration, project docs, and fresh official auth docs | Draft spec created; provider gate explicitly blocks ready implementation | `/sf-ready shipflow_data/workflow/specs/unified-suite-authentication.md` after Task 1 decision context is accepted |
| 2026-05-17 08:14:57 UTC | sf-ready | GPT-5 Codex | Evaluated Definition of Ready, adversarial risks, security posture, language doctrine, and fresh-docs evidence | Not ready: provider gate, first proof pair, and product ID canon remain open and materially change architecture/security execution | `/sf-spec unified-suite-authentication provider decision` |
| 2026-05-17 09:20:15 UTC | sf-docs | GPT-5 Codex | Documented the canonical suite auth decision in the main WinFlowz project and added short project pointers | Decision captured: Clerk central identity, Firebase Android bridge, server-owned entitlements; spec still needs lifecycle update for readiness | `/sf-spec unified-suite-authentication provider decision` |
| 2026-05-17 11:52:48 UTC | sf-spec | GPT-5 Codex | Updated spec from canonical WinFlowz suite auth decision | Provider gate, first proof pair and product ID canon resolved; spec moved to reviewed for readiness gate | `/sf-ready shipflow_data/workflow/specs/unified-suite-authentication.md` |
| 2026-05-17 13:09:59 UTC | sf-docs | GPT-5 Codex | Corrected VoiceFlowz / VoiceFlows naming across suite auth docs | VoiceFlowz is now documented as legacy naming for WinFlowz app; separate `voiceflowz` product id removed from the auth spec | `/sf-ready shipflow_data/workflow/specs/unified-suite-authentication.md` |
| 2026-05-17 13:13:31 UTC | sf-ready | GPT-5 Codex | Re-evaluated readiness after provider and VoiceFlowz corrections | Not ready: WinFlowz Formation repo/backend path is unavailable locally, active app docs still conflict with Clerk suite identity, and dependency versions need refresh | `/sf-spec unified-suite-authentication readiness fixes` |
| 2026-05-17 21:14:55 UTC | sf-backlog | GPT-5 Codex | Recorded OpenAuth as a future identity-provider review item | Deferred to 2028; current Clerk central identity + Firebase Android bridge decision remains unchanged | `/sf-spec unified-suite-authentication readiness fixes` |

# Current Chantier Flow

- sf-spec: done, reviewed after provider-decision update.
- sf-ready: not ready; readiness fixes required before implementation.
- sf-start: not started.
- sf-verify: not started.
- sf-end: not started.
- sf-ship: not started.

Next command: `/sf-spec unified-suite-authentication readiness fixes`.
