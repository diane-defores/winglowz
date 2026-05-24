---
artifact: gtm_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "WinFlowz"
created: "2026-04-26"
updated: "2026-05-14"
status: "reviewed"
source_skill: "sf-docs"
scope: "gtm"
owner: "Diane"
confidence: "medium"
risk_level: "medium"
docs_impact: "yes"
security_impact: "none"
evidence:
  - "shipflow_data/business/business.md"
  - "shipflow_data/business/product.md"
  - "lib/features/settings/presentation/settings_screen.dart"
target_segment:
  - "Mobile professionals dictating notes and messages"
  - "Android power users needing overlay-driven text capture"
offer: "A voice-first mobile workflow with downloadable local voice packs for supported languages and optional advanced AI cleanup via user-provided keys"
channels:
  - "Internal APK distribution and direct demos"
  - "Cross-promotion to adjacent WinFlowz users"
  - "Workflow-led product content and demos"
proof_points:
  - "Flutter multi-platform shell exists"
  - "Supabase Auth/Postgres/RLS baseline exists"
  - "Android overlay bridge baseline exists"
depends_on:
  - "shipflow_data/business/business.md@0.1.0"
  - "shipflow_data/business/branding.md@0.1.0"
  - "shipflow_data/business/product.md@0.1.0"
supersedes: []
next_review: "2026-05-26"
next_step: "$sf-docs update"
---

# GTM — WinFlowz

## Positionnement

WinFlowz est un produit sibling de WinFlowz dans le même écosystème. WinFlowz porte l'axe voice-first (dictée, transcription, nettoyage, clipboard), tandis que WinFlowz porte d'autres workflows de productivité.

## Segment prioritaire

Utilisateurs mobiles orientés productivité, en priorité :

- professionnels indépendants et power users qui dictent des notes/messages ;
- utilisateurs Android qui veulent capturer du texte hors application via overlay ;
- early adopters capables de configurer des clés BYO pour les modes IA avancés.

## Promesse publique sûre

"WinFlowz transforme la voix en texte depuis le clavier Android et l'overlay, avec des packs vocaux locaux gratuits pour les langues supportées et des fallbacks explicites quand un pack local n'est pas disponible."

## Promesses à éviter

- "Synchronisation sécurisée par compte" tant que Supabase Auth/RLS n'a pas été validé end-to-end sur un vrai environnement.
- "Freemium avec quotas" tant que les droits et le billing n'existent pas.
- "Premium illimité" sans infrastructure de quota.
- "Données vocales jamais stockées" sans audit complet du flux audio, des caches natifs et des fournisseurs externes.
- "Prêt entreprise" sans auth, politiques de rétention et garanties sécurité.
- "Dictée offline dans toutes les langues" tant que chaque pack local n'a pas été vérifié en qualité, licence et intégration Android.
- "Support vocal universel inclus" sans distinguer packs locaux, reconnaissance Android et fallback cloud/BYO.

## LTD / AppSumo Messaging

Le lifetime deal attire des utilisateurs globaux. Le message doit donc vendre une architecture extensible par packs de langue, pas une promesse implicite français/anglais.

Formulation sûre:

- "Local voice packs for supported languages."
- "Install only the language packs you need."
- "Fallback transcription when a local pack is unavailable."

Formulation à éviter:

- "Unlimited local voice in every language."
- "All languages offline."
- "No cloud ever" tant que les fallbacks existent.

## Canaux de distribution pragmatiques

- Cross-promotion vers la base utilisateur WinFlowz.
- Distribution interne Android APK pour premiers tests.
- Contenu orienté workflow (notes de reunion, email rapide, pensee captee en deplacement).
- Demos produit courtes centrees sur le gain de vitesse de saisie.

## Objections usuelles et reponses factuelles

| Objection | Réponse actuelle |
|---|---|
| "Mes données vocales sont-elles privées ?" | Le stockage des clés est local. Les flux audio/IA avancés doivent encore être validés avant promesse publique. |
| "Est-ce synchronisé entre mes appareils ?" | Le schéma Supabase et les écrans CRUD existent, mais la validation end-to-end avec vrais comptes reste à faire. |
| "Faut-il payer ?" | Pas de billing implémenté. Les modes cloud utilisent les clés API de l'utilisateur. |
| "Est-ce utilisable dans d'autres apps ?" | Oui sur Android via overlay si les permissions système sont accordées. |

## Preconditions avant lancement public large

- Test end-to-end Supabase avec vraie URL de déploiement et RLS smoke automatisé.
- Validation Supabase Auth réelle et absence de raccourci `TEMP_USER_ID` / `local-user`.
- Politique claire de données et fournisseurs.
- Mesures de latence et fiabilité sur appareils Android réels.
- Positionnement `LTD + abonnement` implémente avec droits/quotas.
- Catalogue initial de packs vocaux documenté avec langue, moteur, taille, licence, niveau qualité et fallback.
