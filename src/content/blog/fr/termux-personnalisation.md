---
title: "Personnaliser Termux : le guide complet pour transformer votre terminal Android"
description: "Apprenez \u00e0 personnaliser enti\u00e8rement Termux : couleurs, th\u00e8mes, extra keys, plein \u00e9cran, curseur, polices et gestion via dotfiles. Le guide de r\u00e9f\u00e9rence pour les d\u00e9veloppeurs mobiles."
contents: [
  "Toutes les propri\u00e9t\u00e9s de termux.properties expliqu\u00e9es",
  "Comment changer les couleurs du terminal avec colors.properties",
  "Installer des Nerd Fonts pour les ic\u00f4nes",
  "G\u00e9rer sa configuration avec des dotfiles et symlinks"
]
author: "Diane"
authorImage: "/images/WinFlowz.png"
authorImageAlt: "Avatar de Diane"
pubDate: 2026-03-23
cardImage: "/images/WinFlowz.png"
cardImageAlt: "Personnalisation de Termux sur Android"
readTime: 15
tags: ["termux", "android", "terminal", "personnalisation", "productivit\u00e9", "d\u00e9veloppement mobile"]
---

Termux est l'\u00e9mulateur de terminal le plus puissant sur Android. Mais par d\u00e9faut, son apparence est... basique. La bonne nouvelle ? Tout est personnalisable. Ce guide couvre **chaque option de configuration** disponible.

## O\u00f9 se trouve la configuration ?

Termux utilise deux fichiers dans `~/.termux/` :

| Fichier | R\u00f4le |
|---------|------|
| `termux.properties` | Comportement du terminal (clavier, apparence, raccourcis) |
| `colors.properties` | Couleurs du terminal (palette 16 couleurs + fond + texte) |
| `font.ttf` | Police personnalis\u00e9e |

Apr\u00e8s chaque modification, appliquez les changements :

```bash
termux-reload-settings
```

Ou red\u00e9marrez compl\u00e8tement l'app Termux.

---

## termux.properties : toutes les options

### Apparence

| Propri\u00e9t\u00e9 | Valeurs | D\u00e9faut | Description |
|-----------|---------|--------|-------------|
| `fullscreen` | `true`/`false` | `false` | Masque les barres de statut et navigation Android |
| `use-fullscreen-workaround` | `true`/`false` | `false` | Corrige les bugs d'affichage en plein \u00e9cran |
| `use-black-ui` | `true`/`false` | `false` | Force le th\u00e8me sombre pour le drawer et les dialogues |
| `night-mode` | `true`/`false`/`system` | `system` | Suit le mode sombre d'Android |
| `terminal-margin-horizontal` | 0\u2013100 dp | `3` | Marge gauche/droite |
| `terminal-margin-vertical` | 0\u2013100 dp | `0` | Marge haut/bas |
| `terminal-toolbar-height` | 0.4\u20133.0 | `1.0` | \u00c9chelle de la barre d'outils |
| `terminal-cursor-style` | `block`/`underline`/`bar` | `block` | Style du curseur |
| `terminal-cursor-blink-rate` | 0+ ms | `0` | Vitesse de clignotement (0 = pas de clignotement) |
| `terminal-transcript-rows` | entier | auto | Nombre de lignes dans l'historique de d\u00e9filement |

**Exemple** \u2014 terminal immersif :
```properties
fullscreen = true
use-fullscreen-workaround = true
use-black-ui = true
terminal-cursor-style = underline
```

### Clavier et Extra Keys

La **barre de touches suppl\u00e9mentaires** (extra keys) est cette double rang\u00e9e au-dessus du clavier qui affiche ESC, CTRL, ALT, fl\u00e8ches, etc.

| Propri\u00e9t\u00e9 | Valeurs | D\u00e9faut | Description |
|-----------|---------|--------|-------------|
| `extra-keys` | JSON array | 2 rang\u00e9es | D\u00e9finit les touches affich\u00e9es |
| `extra-keys-style` | `default` | `default` | Style des touches |
| `extra-keys-text-all-caps` | `true`/`false` | `true` | Majuscules automatiques sur les touches |
| `hide-soft-keyboard-on-startup` | `true`/`false` | `false` | Cache le clavier au d\u00e9marrage |
| `soft-keyboard-toggle-behaviour` | `show/hide`/`enable/disable` | `show/hide` | Comportement du toggle clavier |
| `enforce-char-based-input` | `true`/`false` | `false` | Force le mode caract\u00e8re par caract\u00e8re |
| `ctrl-space-workaround` | `true`/`false` | `false` | Corrige Ctrl+Espace sur certains appareils |

**Masquer compl\u00e8tement la barre** (si vous avez un clavier physique) :
```properties
extra-keys = [[]]
```

**Barre minimaliste \u00e0 une seule rang\u00e9e** :
```properties
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP']]
```

**Barre personnalis\u00e9e \u00e0 deux rang\u00e9es** :
```properties
extra-keys = [['ESC','|','/','-','HOME','UP','END'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','ENTER']]
```

**Astuce** : Vous pouvez aussi basculer la barre avec **Volume Haut + K**.

### Raccourcis de session

Les sessions Termux sont comme des onglets de terminal. Vous pouvez les g\u00e9rer avec le drawer (swipe depuis la gauche) ou ces raccourcis **clavier physique** :

| Propri\u00e9t\u00e9 | D\u00e9faut | Description |
|-----------|--------|-------------|
| `shortcut.create-session` | `ctrl + t` | Nouvelle session |
| `shortcut.next-session` | `ctrl + 2` | Session suivante |
| `shortcut.previous-session` | `ctrl + 1` | Session pr\u00e9c\u00e9dente |
| `shortcut.rename-session` | `ctrl + n` | Renommer la session |
| `disable-hardware-keyboard-shortcuts` | `false` | D\u00e9sactive tous les raccourcis clavier physique |

### Comportement

| Propri\u00e9t\u00e9 | Valeurs | D\u00e9faut | Description |
|-----------|---------|--------|-------------|
| `back-key` | `back`/`escape` | `back` | Bouton retour Android = retour app ou touche Escape |
| `volume-keys` | `virtual`/`volume` | `virtual` | Touches volume = volume syst\u00e8me ou raccourcis terminal |
| `bell-character` | `vibrate`/`beep`/`ignore` | `vibrate` | Comportement de la cloche terminal |
| `terminal-onclick-url-open` | `true`/`false` | `false` | Ouvrir les URLs en cliquant dessus |
| `disable-terminal-session-change-toast` | `true`/`false` | `false` | D\u00e9sactiver la notification de changement de session |

### Syst\u00e8me

| Propri\u00e9t\u00e9 | Valeurs | D\u00e9faut | Description |
|-----------|---------|--------|-------------|
| `allow-external-apps` | `true`/`false` | `true` | Permet \u00e0 Termux de lancer des apps Android |
| `default-working-directory` | chemin | `~` | R\u00e9pertoire de d\u00e9marrage |
| `delete-tmpdir-files-older-than-x-days-on-exit` | -1 \u00e0 100000 | `3` | Nettoyage auto des fichiers temporaires |
| `run-termux-am-socket-server` | `true`/`false` | `true` | Serveur de communication avec Android |
| `disable-file-share-receiver` | `true`/`false` | `false` | D\u00e9sactive la r\u00e9ception de fichiers partag\u00e9s |
| `disable-file-view-receiver` | `true`/`false` | `false` | D\u00e9sactive l'ouverture de fichiers |

---

## colors.properties : les couleurs du terminal

C'est ici que \u00e7a devient int\u00e9ressant. Le fichier `~/.termux/colors.properties` contr\u00f4le **toute la palette de couleurs** de votre terminal.

### Comment \u00e7a marche

Votre terminal utilise **16 couleurs ANSI** standard. Quand un programme (git, npm, Claude Code, vim...) veut afficher du texte color\u00e9, il utilise un code ANSI qui r\u00e9f\u00e9rence l'une de ces 16 couleurs :

| Couleur | Propri\u00e9t\u00e9 | Utilis\u00e9e pour |
|---------|-----------|-------------|
| Noir | `color0` / `color8` (bright) | Fond secondaire, texte discret |
| Rouge | `color1` / `color9` | Erreurs, suppressions git, \u00e9checs |
| Vert | `color2` / `color10` | Succ\u00e8s, ajouts git, confirmation |
| Jaune | `color3` / `color11` | Warnings, fichiers modifi\u00e9s |
| Bleu | `color4` / `color12` | Titres, r\u00e9pertoires, liens |
| Magenta | `color5` / `color13` | Mots-cl\u00e9s, accents |
| Cyan | `color6` / `color14` | Info, param\u00e8tres, cha\u00eenes |
| Blanc | `color7` / `color15` | Texte principal clair |

Plus trois propri\u00e9t\u00e9s sp\u00e9ciales :
- **`foreground`** \u2014 couleur du texte par d\u00e9faut
- **`background`** \u2014 couleur de fond
- **`cursor`** \u2014 couleur du curseur

### Exemple : th\u00e8me Nord

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

### Choisir un th\u00e8me

Vous pouvez parcourir et pr\u00e9visualiser les **114 th\u00e8mes** disponibles dans notre outil interactif \u2192 [Pr\u00e9visualisateur de th\u00e8mes Termux](/fr/blog/termux-themes/)

Trois m\u00e9thodes pour installer un th\u00e8me :

1. **Manuellement** \u2014 copier le contenu dans `~/.termux/colors.properties`
2. **Termux:Styling** \u2014 app F-Droid avec s\u00e9lecteur int\u00e9gr\u00e9 (mais sans pr\u00e9visualisation)
3. **Dotfiles** \u2014 fichier versionn\u00e9 + symlink (recommand\u00e9 pour les d\u00e9veloppeurs)

---

## Polices personnalis\u00e9es

Termux utilise un seul fichier de police : `~/.termux/font.ttf`. Pour changer la police :

```bash
# T\u00e9l\u00e9charger JetBrainsMono Nerd Font (avec ic\u00f4nes)
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" -o font.zip
unzip -q font.zip "JetBrainsMonoNerdFont-Regular.ttf"
cp JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf
termux-reload-settings
```

Les **Nerd Fonts** ajoutent des ic\u00f4nes dans votre terminal (dossiers, git, langages...), essentielles pour des outils comme Starship, Neovim ou Yazi.

Alternative : installez **Termux:Styling** depuis F-Droid pour un s\u00e9lecteur de polices visuel.

---

## G\u00e9rer sa config avec des dotfiles

La meilleure approche pour les d\u00e9veloppeurs : versionner votre configuration Termux dans un repo de dotfiles et la symlinker.

### Structure recommand\u00e9e

```
dotfiles/
\u251c\u2500\u2500 termux/
\u2502   \u251c\u2500\u2500 termux.properties    # Configuration du terminal
\u2502   \u2514\u2500\u2500 colors.properties    # Th\u00e8me de couleurs
\u251c\u2500\u2500 termux.sh                # Script d'installation
\u2514\u2500\u2500 ...
```

### Dans votre script d'installation

```bash
# Cr\u00e9er le r\u00e9pertoire si n\u00e9cessaire
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
- Partageable avec votre \u00e9quipe

---

## Configuration compl\u00e8te recommand\u00e9e

Voici notre configuration optimis\u00e9e pour le d\u00e9veloppement mobile :

```properties
# ~/.termux/termux.properties

# Apparence immersive
fullscreen = true
use-fullscreen-workaround = true
use-black-ui = true
terminal-cursor-style = underline

# D\u00e9sactiver la barre extra keys (clavier physique)
extra-keys = [[]]

# Comportement
terminal-onclick-url-open = true
disable-terminal-session-change-toast = true
back-key = escape
```

---

## Nos dotfiles Termux (open source)

On utilise exactement cette configuration au quotidien. Notre repo de dotfiles inclut :
- `termux.properties` optimis\u00e9 pour le d\u00e9veloppement mobile
- Script d'installation automatique avec symlinks
- Neovim, Starship, Zoxide, Nerd Fonts — tout pr\u00e9configur\u00e9
- Configuration des AI coding agents (LLM CLI, Shell-GPT)

**[github.com/dianedef/dotfiles](https://github.com/dianedef/dotfiles)** — clonez, lancez `bash termux.sh`, c'est pr\u00eat.

---

## ShipFlow — votre environnement de dev serveur

Si vous d\u00e9veloppez sur un serveur (VPS, Codespace), ShipFlow automatise tout : isolation avec Flox, gestion des processus avec PM2, HTTPS avec Caddy, tunnels SSH et URLs publiques via DuckDNS.

**[github.com/dianedef/ShipFlow](https://github.com/dianedef/ShipFlow)** — un CLI interactif pour d\u00e9ployer et g\u00e9rer vos environnements de dev.

---

Envie d'aller plus loin dans votre productivit\u00e9 sur mobile ? D\u00e9couvrez notre formation compl\u00e8te sur l'optimisation de votre environnement de d\u00e9veloppement.
