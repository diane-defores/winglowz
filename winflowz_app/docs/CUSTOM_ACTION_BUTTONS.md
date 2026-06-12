---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "WinFlowz"
created: "2026-06-12"
updated: "2026-06-12"
status: "reviewed"
source_skill: "sf-docs"
scope: "custom_action_buttons"
owner: "Diane"
confidence: "high"
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "Flutter app"
  - "Windows desktop bridge"
  - "macOS desktop bridge"
  - "Linux desktop bridge"
---

# Boutons personnalisés et actions WinFlowz

## Vue d’ensemble

Cette fonctionnalité permet d’avoir une barre d’action personnalisable avec une ou plusieurs rangées de boutons.
Un **bouton personnalisé** est un objet UI : titre, icône, rangée, ordre et action liée.
Un **snippet** reste une entrée texte (trigger + contenu) réutilisable, pas un conteneur UI.

## Où créer une barre de boutons

- Ouvrir `Snippets`.
- Basculer sur l’onglet `Boutons`.
- Utiliser le formulaire `Nouveau bouton` pour définir titre, icône, rangée, type d’action et valeur.
- La section `Barre d’action` prévisualise les rangées configurées.
- La liste `Boutons personnalisés` permet d’éditer, supprimer et exécuter un bouton existant.

## Où se place le stockage et l’exécution

- Les boutons sont stockés dans le domaine `custom_action_buttons`.
- L’exécution passe par `CustomActionButtonRunner` et un runner de livraison desktop borné.
- Le support d’exécution dépend du host actif : `text`, `séquence clavier` et certaines commandes intégrées sont disponibles sur desktop compatibles, sinon un message clair indique la limite.

## Différence avec les actions de corners

- Les corners de clavier et la bibliothèque de boutons partagent le même but produit (accéder rapidement à des actions), mais ils sont aujourd’hui deux surfaces distinctes.
- `Bouton` ≠ `corner` :
  - un corner est configuré dans `Settings > Keyboard > Corner shortcuts`;
  - un bouton est configuré dans `Snippets > Boutons`.
- L’état de compatibilité par surface reste explicite : si un host ne supporte pas une action, on affiche une limite plutôt qu’un succès fictif.

## Modèles d’action supportés en V1

- `insert text`
- `keyboard expression` (langage WinFlowz)
- `desktop key sequence`
- `clipboard command`
- `media command`
- `macro` (stockage prévu, exécution dépendante du host)

## Bonnes limites à rappeler

- Aucune commande système/shell libre n’est autorisée.
- Aucune chaîne sensible n’est loguée en clair.
- Les actions non supportées sur la surface courante doivent rester non bloquantes et clairement expliquées.

