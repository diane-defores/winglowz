---
title: "Automatisation"
description: "Automatise tes taches repetitives sur Windows avec des macros, scripts et lanceurs"
sidebar:
  label: "Automatisation"
  order: 5
---

> Si tu fais la meme chose plus de trois fois, c'est le moment d'automatiser.

## Enregistreurs de macros

Le principe est simple : tu enregistres une sequence d'actions (clics, frappes clavier), puis tu la rejoues a volonte. Pas besoin de savoir coder.

### Outils recommandes

| Outil | Complexite | Points forts |
|-------|-----------|-------------|
| **TinyTask** | Tres simple | Fichier unique, pas d'installation, ideal pour des macros rapides |
| **Jitbit Macro Recorder** | Moyenne | Interface claire, edition des etapes apres enregistrement |
| **Pulover's Macro Creator** | Avancee | Genere du code AutoHotkey, pont vers l'automatisation avancee |

**Cas d'usage typiques** : remplir un formulaire recurrent, renommer des fichiers en serie, envoyer un message type, effectuer une routine de tests.

### Limites des enregistreurs

Les macros enregistrees sont fragiles. Si une fenetre change de position ou si un bouton est deplace, la macro echoue. Pour des automatisations robustes, il faut passer au scripting.

## AutoHotkey : l'automatisation sans limites

AutoHotkey (AHK) est un langage de scripting concu pour Windows. Il te permet de creer des raccourcis, remapper des touches, automatiser des taches et meme creer des interfaces graphiques.

### Exemples concrets

**Remapper une touche :**
```txt
; Transformer Caps Lock en touche Echap
CapsLock::Esc
```

**Creer un raccourci de texte :**
```txt
; Taper "@@" insere ton adresse mail
::@@::ton.email@exemple.com
```

**Lancer une app avec un raccourci :**
```txt
; Win + N ouvre le Bloc-notes
#n::Run, notepad.exe
```

**Raccourci pour un texte multiligne :**
```txt
; Ctrl + Shift + S insere une signature
^+s::
SendInput, Cordialement,{Enter}Ton Nom{Enter}Ton Poste
return
```

### Par ou commencer avec AHK

1. Installe AutoHotkey v2 depuis le site officiel
2. Cree un fichier `.ahk` avec le Bloc-notes
3. Ecris ton premier script (commence par un remapping simple)
4. Double-clique sur le fichier pour l'executer
5. Place tes scripts essentiels dans le dossier Demarrage pour qu'ils se lancent automatiquement

## Automatisation navigateur

### Automa

Automa est une extension navigateur qui te permet d'automatiser des workflows web via une interface visuelle par blocs. Pas de code necessaire.

**Ce que tu peux faire :**
- Remplir des formulaires automatiquement
- Extraire des donnees de pages web (scraping leger)
- Enchainer des actions sur plusieurs pages
- Planifier des executions recurrentes

### Browser Automation Studio (BAS)

BAS est plus puissant qu'Automa mais aussi plus complexe. Il gere les proxies, les profils multiples et les scenarios avances. A reserver aux cas ou Automa ne suffit plus.

## Lanceurs d'applications

Ouvrir une app en passant par le menu Demarrer, c'est lent. Un lanceur te permet de taper quelques lettres et de lancer n'importe quoi instantanement.

### Comparatif des lanceurs

| Lanceur | Vitesse | Fonctions extras | Open-source |
|---------|---------|-----------------|-------------|
| **Flow Launcher** | Rapide | Plugins, calculatrice, recherche web | Oui |
| **Listary** | Tres rapide | Integration Explorateur, recherche fichiers | Non (freemium) |
| **Wox** | Rapide | Plugins, themes | Oui |
| **PowerToys Run** | Rapide | Integre a PowerToys, pas d'installation separee | Oui |

**Notre recommandation** : Flow Launcher pour sa communaute active et ses plugins, ou PowerToys Run si tu utilises deja PowerToys.

### Raccourci universel

Configure ton lanceur sur `Alt + Espace`. C'est le standard de facto. Tu appuies, tu tapes, tu valides — trois gestes pour ouvrir n'importe quoi.

## Lancer des programmes au demarrage

Pour qu'un programme ou un script se lance automatiquement :

1. Appuie sur `Win + R`, tape `shell:startup`, valide
2. Colle un **raccourci** (pas le fichier original) de ton programme dans ce dossier
3. C'est tout. Au prochain demarrage, il sera lance automatiquement.

## Introduction au RPA

Le RPA (Robotic Process Automation) pousse l'automatisation au niveau professionnel. Au lieu d'automatiser une seule tache, tu automatises des processus entiers.

**OpenIAP** est une plateforme open-source de RPA qui permet de :
- Orchestrer des workflows entre plusieurs applications
- Gerer des files d'attente de taches
- Integrer des robots logiciels avec des APIs

C'est un sujet avance, mais si tu travailles avec des processus repetitifs a grande echelle, ca vaut le detour.
