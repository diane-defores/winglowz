---
artifact: gtm_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "VoiceFlowz"
created: "2026-04-26"
updated: "2026-04-27"
status: "reviewed"
source_skill: "sf-docs"
scope: "gtm"
owner: "Diane"
confidence: "medium"
risk_level: "medium"
docs_impact: "yes"
security_impact: "none"
evidence:
  - "BUSINESS.md"
  - "PRODUCT.md"
  - "lib/features/settings/presentation/settings_screen.dart"
target_segment:
  - "Mobile professionals dictating notes and messages"
  - "Android power users needing overlay-driven text capture"
offer: "A voice-first mobile workflow with free local dictation and optional advanced AI cleanup via user-provided keys"
channels:
  - "Internal APK distribution and direct demos"
  - "Cross-promotion to adjacent WinFlowz users"
  - "Workflow-led product content and demos"
proof_points:
  - "Flutter multi-platform shell exists"
  - "Supabase Auth/Postgres/RLS baseline exists"
  - "Android overlay bridge baseline exists"
depends_on:
  - "BUSINESS.md@0.1.0"
  - "BRANDING.md@0.1.0"
  - "PRODUCT.md@0.1.0"
supersedes: []
next_review: "2026-05-26"
next_step: "$sf-docs update"
---

# GTM — VoiceFlowz

## Positionnement

VoiceFlowz est un produit sibling de WinFlowz dans le même écosystème. VoiceFlowz porte l'axe voice-first (dictée, transcription, nettoyage, clipboard), tandis que WinFlowz porte d'autres workflows de productivité.

## Segment prioritaire

Utilisateurs mobiles orientés productivité, en priorité :

- professionnels indépendants et power users qui dictent des notes/messages ;
- utilisateurs Android qui veulent capturer du texte hors application via overlay ;
- early adopters capables de configurer des clés BYO pour les modes IA avancés.

## Promesse publique sûre

"VoiceFlowz transforme la voix en texte copiable sur mobile, avec un mode local gratuit et un mode avancé via vos clés API."

## Promesses à éviter

- "Synchronisation sécurisée par compte" tant que Supabase Auth/RLS n'a pas été validé end-to-end sur un vrai environnement.
- "Freemium avec quotas" tant que les droits et le billing n'existent pas.
- "Premium illimité" sans infrastructure de quota.
- "Données vocales jamais stockées" sans audit complet du flux audio, des caches natifs et des fournisseurs externes.
- "Prêt entreprise" sans auth, politiques de rétention et garanties sécurité.

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
