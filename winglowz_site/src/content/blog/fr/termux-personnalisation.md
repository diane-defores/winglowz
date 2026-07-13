---
title: "Personnaliser Termux : le guide complet pour transformer votre terminal Android"
description: "Apprenez à personnaliser entièrement Termux : couleurs, thèmes, extra keys, plein écran, curseur, polices et gestion via dotfiles. Le guide de référence pour les développeurs mobiles."
contents: [
  "Toutes les propriétés de termux.properties expliquées",
  "Comment changer les couleurs du terminal avec colors.properties",
  "Installer des Nerd Fonts pour les icônes",
  "Gérer sa configuration avec des dotfiles et symlinks"
]
author: "Diane"
authorImage: "/images/WinGlowz.png"
authorImageAlt: "Avatar de Diane"
pubDate: 2026-03-23
cardImage: "/images/WinGlowz.png"
cardImageAlt: "Personnalisation de Termux sur Android"
readTime: 15
tags: ["termux", "android", "terminal", "personnalisation", "productivité", "développement mobile"]
---

Termux est l'émulateur de terminal le plus puissant sur Android. Mais par défaut, son apparence est... basique. La bonne nouvelle ? Tout est personnalisable. Ce guide couvre **chaque option de configuration** disponible.

## Où se trouve la configuration ?

Termux utilise deux fichiers dans `~/.termux/` :

| Fichier | Rôle |
|---------|------|
| `termux.properties` | Comportement du terminal (clavier, apparence, raccourcis) |
| `colors.properties` | Couleurs du terminal (palette 16 couleurs + fond + texte) |
| `font.ttf` | Police personnalisée |

Après chaque modification, appliquez les changements :

```bash
termux-reload-settings
```

Ou redémarrez complètement l'app Termux.

---

## termux.properties : toutes les options

### Apparence

| Propriété | Valeurs | Défaut | Description |
|-----------|---------|--------|-------------|
| `fullscreen` | `true`/`false` | `false` | Masque les barres de statut et navigation Android |
| `use-fullscreen-workaround` | `true`/`false` | `false` | Corrige les bugs d'affichage en plein écran |
| `use-black-ui` | `true`/`false` | `false` | Force le thème sombre pour le drawer et les dialogues |
| `night-mode` | `true`/`false`/`system` | `system` | Suit le mode sombre d'Android |
| `terminal-margin-horizontal` | 0–100 dp | `3` | Marge gauche/droite |
| `terminal-margin-vertical` | 0–100 dp | `0` | Marge haut/bas |
| `terminal-toolbar-height` | 0.4–3.0 | `1.0` | Échelle de la barre d'outils |
| `terminal-cursor-style` | `block`/`underline`/`bar` | `block` | Style du curseur |
| `terminal-cursor-blink-rate` | 0+ ms | `0` | Vitesse de clignotement (0 = pas de clignotement) |
| `terminal-transcript-rows` | entier | auto | Nombre de lignes dans l'historique de défilement |

**Exemple** — terminal immersif :
```properties
fullscreen = true
use-fullscreen-workaround = true
use-black-ui = true
terminal-cursor-style = underline
```

### Clavier et Extra Keys

La **barre de touches supplémentaires** (extra keys) est cette double rangée au-dessus du clavier qui affiche ESC, CTRL, ALT, flèches, etc.

| Propriété | Valeurs | Défaut | Description |
|-----------|---------|--------|-------------|
| `extra-keys` | JSON array | 2 rangées | Définit les touches affichées |
| `extra-keys-style` | `default` | `default` | Style des touches |
| `extra-keys-text-all-caps` | `true`/`false` | `true` | Majuscules automatiques sur les touches |
| `hide-soft-keyboard-on-startup` | `true`/`false` | `false` | Cache le clavier au démarrage |
| `soft-keyboard-toggle-behaviour` | `show/hide`/`enable/disable` | `show/hide` | Comportement du toggle clavier |
| `enforce-char-based-input` | `true`/`false` | `false` | Force le mode caractère par caractère |
| `ctrl-space-workaround` | `true`/`false` | `false` | Corrige Ctrl+Espace sur certains appareils |

**Masquer complètement la barre** (si vous avez un clavier physique) :
```properties
extra-keys = [[]]
```

**Barre minimaliste à une seule rangée** :
```properties
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP']]
```

**Barre personnalisée à deux rangées** :
```properties
extra-keys = [['ESC','|','/','-','HOME','UP','END'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','ENTER']]
```

**Astuce** : Vous pouvez aussi basculer la barre avec **Volume Haut + K**.

### Raccourcis de session

Les sessions Termux sont comme des onglets de terminal. Vous pouvez les gérer avec le drawer (swipe depuis la gauche) ou ces raccourcis **clavier physique** :

| Propriété | Défaut | Description |
|-----------|--------|-------------|
| `shortcut.create-session` | `ctrl + t` | Nouvelle session |
| `shortcut.next-session` | `ctrl + 2` | Session suivante |
| `shortcut.previous-session` | `ctrl + 1` | Session précédente |
| `shortcut.rename-session` | `ctrl + n` | Renommer la session |
| `disable-hardware-keyboard-shortcuts` | `false` | Désactive tous les raccourcis clavier physique |

### Comportement

| Propriété | Valeurs | Défaut | Description |
|-----------|---------|--------|-------------|
| `back-key` | `back`/`escape` | `back` | Bouton retour Android = retour app ou touche Escape |
| `volume-keys` | `virtual`/`volume` | `virtual` | Touches volume = volume système ou raccourcis terminal |
| `bell-character` | `vibrate`/`beep`/`ignore` | `vibrate` | Comportement de la cloche terminal |
| `terminal-onclick-url-open` | `true`/`false` | `false` | Ouvrir les URLs en cliquant dessus |
| `disable-terminal-session-change-toast` | `true`/`false` | `false` | Désactiver la notification de changement de session |

### Système

| Propriété | Valeurs | Défaut | Description |
|-----------|---------|--------|-------------|
| `allow-external-apps` | `true`/`false` | `true` | Permet à Termux de lancer des apps Android |
| `default-working-directory` | chemin | `~` | Répertoire de démarrage |
| `delete-tmpdir-files-older-than-x-days-on-exit` | -1 à 100000 | `3` | Nettoyage auto des fichiers temporaires |
| `run-termux-am-socket-server` | `true`/`false` | `true` | Serveur de communication avec Android |
| `disable-file-share-receiver` | `true`/`false` | `false` | Désactive la réception de fichiers partagés |
| `disable-file-view-receiver` | `true`/`false` | `false` | Désactive l'ouverture de fichiers |

---

## colors.properties : les couleurs du terminal

C'est ici que ça devient intéressant. Le fichier `~/.termux/colors.properties` contrôle **toute la palette de couleurs** de votre terminal.

### Comment ça marche

Votre terminal utilise **16 couleurs ANSI** standard. Quand un programme (git, npm, Claude Code, vim...) veut afficher du texte coloré, il utilise un code ANSI qui référence l'une de ces 16 couleurs :

| Couleur | Propriété | Utilisée pour |
|---------|-----------|-------------|
| Noir | `color0` / `color8` (bright) | Fond secondaire, texte discret |
| Rouge | `color1` / `color9` | Erreurs, suppressions git, échecs |
| Vert | `color2` / `color10` | Succès, ajouts git, confirmation |
| Jaune | `color3` / `color11` | Warnings, fichiers modifiés |
| Bleu | `color4` / `color12` | Titres, répertoires, liens |
| Magenta | `color5` / `color13` | Mots-clés, accents |
| Cyan | `color6` / `color14` | Info, paramètres, chaînes |
| Blanc | `color7` / `color15` | Texte principal clair |

Plus trois propriétés spéciales :
- **`foreground`** — couleur du texte par défaut
- **`background`** — couleur de fond
- **`cursor`** — couleur du curseur

### Exemple : thème Nord

```properties
foreground=#d8dee9
background=#2e3440
cursor=#d8dee9

color0=#3b4252
color1=#bf616a
color2=#a3be8c
color3=#ebcb8b
color4=#81a1c1
color5=#b48ead
color6=#88c0d0
color7=#e5e8f0

color8=#4c566a
color9=#bf616a
color10=#a3be8c
color11=#ebcb8b
color12=#81a1c1
color13=#b48ead
color14=#8fbcbb
color15=#eceff4
```

### Choisir un thème

Vous pouvez parcourir et prévisualiser les **114 thèmes** disponibles dans notre outil interactif → [Prévisualisateur de thèmes Termux](/fr/blog/termux-themes/)

Trois méthodes pour installer un thème :

1. **Manuellement** — copier le contenu dans `~/.termux/colors.properties`
2. **Termux:Styling** — app F-Droid avec sélecteur intégré (mais sans prévisualisation)
3. **Dotfiles** — fichier versionné + symlink (recommandé pour les développeurs)

---

## Polices personnalisées

Termux utilise un seul fichier de police : `~/.termux/font.ttf`. Pour changer la police :

```bash
# Télécharger JetBrainsMono Nerd Font (avec icônes)
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" -o font.zip
unzip -q font.zip "JetBrainsMonoNerdFont-Regular.ttf"
cp JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf
termux-reload-settings
```

Les **Nerd Fonts** ajoutent des icônes dans votre terminal (dossiers, git, langages...), essentielles pour des outils comme Starship, Neovim ou Yazi.

Alternative : installez **Termux:Styling** depuis F-Droid pour un sélecteur de polices visuel.

---

## Gérer sa config avec des dotfiles

La meilleure approche pour les développeurs : versionner votre configuration Termux dans un repo de dotfiles et la symlinker.

### Structure recommandée

```
dotfiles/
├── termux/
│   ├── termux.properties    # Configuration du terminal
│   └── colors.properties    # Thème de couleurs
├── dotfiles/
│   └── termux.sh             # Script d'installation
└── ...
```

### Dans votre script d'installation

```bash
# Créer le répertoire si nécessaire
mkdir -p "$HOME/.termux"

# Symlinker la configuration
ln -sf "$HOME/dotfiles/termux/termux.properties" "$HOME/.termux/termux.properties"
ln -sf "$HOME/dotfiles/termux/colors.properties" "$HOME/.termux/colors.properties"

# Appliquer
termux-reload-settings
```

Avantages :
- Configuration versionnée dans git
- Reproductible sur tout nouvel appareil
- Partageable avec votre équipe

---

## Configuration complète recommandée

Voici notre configuration optimisée pour le développement mobile :

```properties
# ~/.termux/termux.properties

# Apparence immersive
fullscreen = true
use-fullscreen-workaround = true
use-black-ui = true
terminal-cursor-style = underline
```

---

## 🎯 Formation : Coder sur mobile

Tu veux aller plus loin ? [Module IX de la formation WinGlowz](/fr/formations/module-9-mobile-coder/) t'apprend à :

- Configurer Termux pour un accès serveur optimisé
- Comprendre pourquoi SSH ≠ Mosh pour coder avec les outils IA
- Utiliser OpenCode/KiloCode depuis ton téléphone
- Structurer ton workflow pour la mobilité

:::note[Le truc en plus]
Le premier module de la formation est offert — avec des templates de configuration prêts à l'emploi.
:::
