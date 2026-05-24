---
artifact: brand_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "WinFlowz"
created: "2026-03-18"
updated: "2026-05-04"
status: "reviewed"
source_skill: "sf-docs"
scope: "branding"
owner: "Diane"
confidence: "medium"
risk_level: "low"
docs_impact: "yes"
security_impact: "none"
evidence:
  - "docs/SPEC_FLUTTER_SUPABASE_MIGRATION.md"
  - "shipflow_data/business/business.md"
  - "shipflow_data/business/product.md"
brand_voice: "Direct, productive, and honest about prerequisites"
trust_posture: "Do not overpromise auth, billing, privacy, or AI quality beyond verified code paths"
depends_on:
  - "shipflow_data/business/business.md@0.1.0"
supersedes: []
next_review: "2026-05-26"
next_step: "$sf-docs update"
---

# Branding — WinFlowz

## Cadre

Ce document cadre la marque pour la cible `target-reviewed` Flutter + Supabase. Les mentions Expo/Convex/Clerk appartiennent uniquement au contexte `legacy-current` pré-migration et ne doivent pas être utilisées comme promesse produit.

## Nom et identité

- **Nom** : WinFlowz — contraction de Voice + Flow + z, cohérente avec l'écosystème WinFlowz.
- **Promesse courte** : parler, nettoyer, copier.
- **Tagline actuelle dans l'app** : "Speak. Transcribe. Ship."
- **Tagline française utilisable** : "Parle. C'est écrit."

## Identité visuelle

### Cohérence écosystème

WinFlowz peut rester visuellement relié à WinFlowz, avec une identité orientée produit utilitaire: rapide, lisible, orientée action. La documentation ne doit pas promettre un design system partagé complet tant que les tokens communs ne sont pas versionnés.

### Couleurs

- **Fond sombre** : `#0f172a`
- **Surface** : `#1e293b`
- **Primaire** : `#6366f1`
- **Accent audio** : `#22d3ee`
- **Texte principal** : `#f8fafc`

### Accent audio

- Onde sonore animée pendant l'enregistrement.
- États visuels clairs : repos, enregistrement, traitement, résultat, erreur.
- Les animations servent le feedback fonctionnel.

## Typographie

- Polices système Flutter par plateforme (Android, iOS, desktop, web).
- Hiérarchie simple : titre, sous-titre, résultat, historique.
- Le texte transcrit doit rester lisible et facile à copier ou modifier.

## Ton de voix

- Direct, productif, sans jargon.
- Orienté action : enregistrer, transcrire, copier, synchroniser.
- Les messages de configuration doivent rester honnêtes sur les prérequis : compte Supabase, clé OpenAI BYO locale, clé Anthropic locale optionnelle, activation clavier Android, permissions Android overlay/accessibilité.
- Les plateformes non Android ne doivent pas recevoir de promesse d'overlay système ou de clavier système WinFlowz.

## Valeurs de marque

| Valeur | Signification |
|---|---|
| Rapidité | L'utilisateur obtient vite un texte exploitable. |
| Discrétion | L'application doit rester légère dans le workflow mobile. |
| Précision | Le nettoyage IA améliore le texte sans changer l'intention. |
| Contrôle | Les clés API restent sur l'appareil et les permissions sont explicites. |

## Claims autorisés / interdits

### Claims autorisés (target-reviewed)

- "Application Flutter multi-plateforme."
- "Connexion et synchronisation de données via Supabase."
- "Clés OpenAI/Anthropic BYO conservées localement."
- "Overlay disponible uniquement sur Android."
- "Clavier WinFlowz disponible uniquement sur Android."
- "Snippets et dictionnaire personnel synchronisés par compte."

### Claims interdits tant que non implémentés

- "Billing premium actif", "quotas appliqués", "entitlements en production".
- "Chiffrement bout-en-bout".
- "Overlay système sur iOS/macOS/Windows/Linux/web".

### Claims legacy-current à ne pas utiliser comme cible

- "Backend Convex", "auth Clerk en cours", "application Expo/React Native" comme direction produit.
