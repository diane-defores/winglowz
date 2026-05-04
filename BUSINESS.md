---
artifact: business_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-03-18"
updated: "2026-05-04"
status: "reviewed"
source_skill: "sf-docs"
scope: "business"
owner: "Diane"
confidence: "medium"
risk_level: "medium"
docs_impact: "yes"
security_impact: "high"
evidence:
  - "docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md"
  - "docs/MIGRATION_FLUTTER.md"
  - "docs/DECISIONS.md"
  - "ARCHITECTURE.md"
  - "docs/API.md"
  - "README.md"
business_model: "Freemium voice productivity app with bring-your-own-key advanced features"
market: "Cross-platform dictation, transcript cleanup, snippets, dictionary, and clipboard productivity tools"
target_audience: "Professionals and power users who produce text from speech across Android, iOS, desktop, and web"
value_proposition: "Capture speech quickly, clean it when needed, and reuse it across apps with account-based sync, Android keyboard entry, and Android overlay where available"
depends_on: []
supersedes: []
next_review: "2026-05-26"
next_step: "$sf-docs update"
---

# Business — VoiceFlowz

## Statut de preuve

Ce document sépare explicitement:

- `legacy-current`: état réel pré-migration (Expo/Convex/Clerk non branché).
- `target-reviewed`: cible validée pour la migration Flutter + Supabase.
- `out-of-scope`: hors migration actuelle.

## Mission

Libérer les mains des professionnels grâce à la dictée vocale intelligente, en transformant la parole en texte propre et exploitable rapidement.

## Proposition de valeur

VoiceFlowz cible une application Flutter multi-plateforme avec authentification Supabase et synchronisation Postgres/RLS/Realtime. Le produit combine dictée locale quand disponible, transcription avancée Whisper avec clé OpenAI locale BYO, nettoyage IA Claude optionnel avec clé Anthropic locale BYO, historique synchronisé, snippets, dictionnaire personnel, clavier Android natif, et overlay Android natif avec fallback clipboard.

## Capacités business de référence

| Capacité | Statut | Preuve |
|---|---|---|
| App Flutter Android/iOS/macOS/Windows/Linux/web | target-reviewed | `docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md` |
| Auth Supabase + Postgres + RLS + Realtime | target-reviewed | `docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md`, `docs/API.md` |
| Clés OpenAI/Anthropic BYO stockées localement | target-reviewed | `docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md` |
| Snippets + dictionnaire comme fonctionnalités produit | target-reviewed | `docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md` |
| Clavier Android natif VoiceFlowz | target-reviewed | `specs/android-ime-voiceflowz-keyboard.md` |
| Overlay Android natif uniquement | target-reviewed | `docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md` |
| Expo/Convex/Clerk comme implémentation cible | out-of-scope | explicitement exclu de la cible finale |
| Quotas gratuits / premium / billing | out-of-scope | non inclus dans le scope migration |

## Modèle commercial

Le modèle reste freemium BYO pour la migration. Les plans payants restent hors scope tant que quota, entitlement et billing ne sont pas spécifiés et implémentés.

### Offre target-reviewed (post-migration attendue)

- L'utilisateur se connecte avec Supabase Auth.
- Les données utilisateur sont isolées via RLS `auth.uid()` sur Postgres.
- Les clés OpenAI/Anthropic restent locales à l'appareil et ne sont pas stockées dans Supabase.
- L'utilisateur gère transcriptions, clipboard, snippets et dictionnaire depuis son compte.
- Le clavier Android VoiceFlowz reste disponible uniquement sur Android et sert de surface prioritaire dans les champs texte.
- L'overlay Android reste disponible uniquement sur Android avec fallback clipboard.

### État legacy-current (pré-migration, à ne pas présenter comme cible)

- Application Expo/React Native.
- Backend Convex avec `local-user`.
- Auth Clerk non branchée.

## Impact sécurité et mitigations

`security_impact: high` parce que le produit manipule voix, texte potentiellement sensible, clipboard, clés API BYO et synchronisation cloud.

Mitigations obligatoires pour readiness migration:

1. Supabase Auth obligatoire avant usage multi-utilisateur; suppression du pattern `TEMP_USER_ID`.
2. RLS activé sur toutes les tables utilisateur (`transcriptions`, `clipboard_items`, `snippets`, `dictionary`, `user_settings`).
3. Clés OpenAI/Anthropic en stockage local sécurisé seulement; interdiction de sync Supabase et de logs en clair.
4. Redaction systématique des secrets dans logs/erreurs/analytics.
5. Interdiction de sauvegarder des textes vides; fallback texte brut si nettoyage IA échoue.
6. Clavier Android et overlay derrière actions utilisateur explicites, avec private mode pour champs sensibles.

## Persona principal

**Le Multitâche**

- Professionnel en mobilité et sur poste fixe: commercial, consultant, manager ou indépendant.
- Rédige des emails, notes de réunion et comptes-rendus en déplacement.
- Enchaîne les contextes de travail et veut capturer l'information sans taper.
- Valorise la vitesse, la précision et la disponibilité immédiate du texte.

## Marché cible

- **Segment** : productivité voice-to-text cross-platform.
- **Usage prioritaire** : transformer une pensée ou note vocale en texte exploitable sur mobile et desktop.
- **Contrainte produit** : aucune promesse sécurité/compliance/quota hors comportements vérifiés.

## Avantage concurrentiel

1. **Pipeline hybride BYO**: local + Whisper + nettoyage IA optionnel.
2. **Entrées Android natives**: clavier IME pour écrire dans les champs, overlay pour capture flottante avec fallback robuste.
3. **Données structurées utiles**: transcriptions + clipboard + snippets + dictionnaire synchronisés par compte.

## Stratégie Go-to-Market

- Lancement initial auprès d'utilisateurs techniques capables de configurer leurs clés API BYO.
- Positionnement migration: outil de productivité voice-first multi-plateforme avec sécurité de base robuste (Auth + RLS).
- Les extensions premium restent post-migration et non promises à ce stade.

## Métriques clés

| Métrique | Statut | Description |
|---|---|---|
| Minutes transcrites | target-reviewed | Instrumentation à implémenter côté Flutter/Supabase |
| Nombre de transcriptions | target-reviewed | Mesurable par compte Supabase |
| Utilisation clipboard | target-reviewed | Mesurable sur table clipboard et événements UI |
| Utilisation snippets/dictionnaire | target-reviewed | Mesurable sur CRUD dédiés |
| Conversion premium | out-of-scope | Nécessite billing non inclus dans la migration |
