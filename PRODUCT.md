---
artifact: product_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-26"
updated: "2026-05-04"
status: "reviewed"
source_skill: "sf-docs"
scope: "product"
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
  - "GUIDELINES.md"
  - "docs/API.md"
target_user: "Professionals and power users capturing text from speech across mobile, desktop, and web"
user_problem: "Typing is slow or disruptive in contexts where quick dictation, cleanup, and structured reuse matter"
desired_outcomes:
  - "Capture speech quickly in local or advanced modes"
  - "Reuse transcripts through copy, edit, shared clipboard, snippets, and dictionary workflows"
  - "Use a native Android keyboard entrypoint for typing, dictation, clipboard actions, snippets entry points, and play/pause media"
  - "Access Android overlay capture on Android while keeping parity workflows elsewhere"
non_goals:
  - "Not a billing-enabled premium product in migration scope"
  - "Not an iOS/desktop/web system overlay product"
  - "Not a JS/TS application codebase in final target repository"
depends_on:
  - "BUSINESS.md@0.1.0"
  - "BRANDING.md@0.1.0"
supersedes: []
next_review: "2026-05-26"
next_step: "$sf-docs update"
---

# Product — VoiceFlowz

## Cadre de référence

Ce document décrit la cible `target-reviewed` de la migration Flutter + Supabase. Les éléments Expo/Convex/Clerk sont conservés ici uniquement comme `legacy-current` pré-migration.

## Problème utilisateur

Les utilisateurs produisent souvent du texte dans des contextes où taper est lent, peu pratique ou interrompt le flux de travail. VoiceFlowz vise à transformer rapidement la parole en texte copiable, modifiable, synchronisé et réutilisable.

## Utilisateurs cibles

- Professionnels qui rédigent notes, emails ou comptes-rendus sur mobile et desktop.
- Power users qui acceptent de configurer leurs propres clés API pour obtenir une meilleure transcription.
- Utilisateurs Android qui veulent déclencher la dictée hors application via overlay.
- Utilisateurs Android qui veulent écrire et dicter depuis un clavier VoiceFlowz dans n'importe quel champ compatible.

## Workflows cœur

### Dictée rapide

1. L'utilisateur se connecte via Supabase Auth.
2. Il ouvre l'écran Voice et choisit mode local ou avancé.
3. Il enregistre sa voix.
4. VoiceFlowz affiche le texte brut puis le texte nettoyé si applicable.
5. L'utilisateur copie, modifie, sauvegarde, ou envoie le texte vers le clipboard.

### Mode avancé

1. L'utilisateur ajoute une clé OpenAI locale dans Settings.
2. Il active le mode Advanced.
3. L'application enregistre l'audio et l'envoie à Whisper.
4. Le texte est nettoyé localement ou via Claude si la clé Anthropic locale existe.
5. En cas d'échec Claude, le texte brut reste disponible et sauvegardable.

### Clipboard + snippets + dictionnaire

1. L'utilisateur peut envoyer une transcription vers le clipboard synchronisé.
2. Il peut copier, épingler ou supprimer des éléments clipboard.
3. Il gère des snippets (CRUD + recherche trigger).
4. Il gère un dictionnaire personnel (CRUD + application au nettoyage local).

### Overlay Android

1. L'utilisateur active les permissions overlay/accessibilité Android dans Settings.
2. Le bouton flottant déclenche l'enregistrement.
3. Le résultat est injecté si possible, sinon fallback clipboard.
4. Les plateformes non Android n'affichent pas de contrôle overlay trompeur.

### Clavier Android VoiceFlowz

1. L'utilisateur active VoiceFlowz Keyboard dans les réglages de méthode de saisie Android.
2. Il bascule sur ce clavier depuis un champ texte compatible.
3. Il peut taper, dicter localement, coller/copier explicitement, ouvrir les snippets, et envoyer play/pause au média courant.
4. Les champs password, OTP ou privés désactivent dictée, capture clipboard, snippets enrichis et sync.

## Surface target-reviewed

- Flutter app Android/iOS/macOS/Windows/Linux/web.
- Supabase Auth + Postgres + RLS + Realtime.
- Écran Voice: capture locale (si supportée), capture avancée Whisper, sauvegarde, édition, copie.
- Clipboard: liste, copy, pin, suppression, synchronisation.
- Snippets: liste, création, édition, suppression, recherche trigger.
- Dictionnaire: liste, création, édition, suppression, application nettoyage.
- Settings: clés BYO locales, permissions, langue, session auth.
- Clavier Android natif via `InputMethodService` et bridge Flutter/Kotlin.
- Overlay Android natif via bridge Flutter/Kotlin.

## Legacy-current (pré-migration, non cible)

- Expo/React Native + code applicatif TS.
- Backend Convex.
- Auth Clerk non branchée et `local-user`.

## Exigences sécurité produit et mitigations

`security_impact: high` car le flux produit manipule données vocales/texte, secrets BYO, clipboard et synchronisation cloud.

Mitigations obligatoires:

1. Auth Supabase active avant toute écriture de données utilisateur.
2. RLS obligatoire sur toutes les tables utilisateur, avec politiques testées.
3. Clés OpenAI/Anthropic locales uniquement; jamais synchronisées.
4. Redaction des secrets et payloads sensibles dans logs/erreurs.
5. Refus explicite des sauvegardes de texte vide.
6. États erreurs récupérables pour permissions, API IA, sync Supabase.
7. Overlay Android conditionné par permissions et fallback clipboard.
8. Clavier Android conditionné par activation utilisateur, private mode pour champs sensibles et sync clipboard opt-in.

## Non-goals actuels

- Pas de billing/entitlements dans la migration.
- Pas d'overlay système hors Android.
- Pas de clavier système VoiceFlowz hors Android dans cette phase.
- Pas de promesse de chiffrement bout-en-bout.
- Pas de code applicatif JS/TS dans le repo final.
