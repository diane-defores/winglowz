# Workflow développement mobile

Workflow complet pour développer efficacement depuis mobile.

## Architecture tmux

```
Session mobile-dev
├── Window 1: code (split vertical)
│   ├── Pane 1: nvim (édition)
│   └── Pane 2: opencode/kilocode (en SSH seulement!)
├── Window 2: navigation
│   └── Pane: fzf, grep, fichiers
└── Window 3: monitoring
    └── Pane: logs serveur (pm2, caddy)
```

## Outils d'IA sur serveur

Les outils IA tournent **sur votre serveur Hetzner**, pas dans Termux:

```bash
# SSH obligatoire pour TUI
ssh user@hetzner

# Puis utiliser les outils du serveur
opencode    # Interface complète (en SSH)
kilocode    # Interface complète (en SSH)
claude      # Chat CLI (fonctionne partout)
codex       # Chat CLI (fonctionne partout)
```

**Important**: OpenCode/KiloCode utilisent l'alternate screen buffer. En Mosh, le scroll est bloqué.

## Commandes essentielles

```bash
# Attach ou créer session
tmux attach -t mobile || tmux new -s mobile

# Navigation fenêtres
Ctrl-w 1    # Window 1
Ctrl-w 2    # Window 2
Ctrl-w w    # Menu fenêtres

# Split et navigation
Ctrl-w |    # Split vertical
Ctrl-w -    # Split horizontal
Ctrl-w h/j/k/l  # Navigation panes
Ctrl-w z    # Zoom current pane

# Scroll dans le pane
Ctrl-w [    # Mode copy
Ctrl-u/d    # Page up/down
q           # Quitter mode copy
```

## Git workflow mobile

```bash
# Synchroniser avant de commencer
git pull

# Créer branche
git checkout -b feature/mobile-fix

# Commit rapide
git add . && git commit -m "fix: mobile"

# Push
git push -u origin feature/mobile-fix
```

## SSH + tmux persistant

```bash
# Script: ~/bin/mobile-dev.sh
#!/bin/bash
tmux new-session -d -s mobile \; \
  send-keys -t mobile "nvim" Enter \; \
  split-window -h -t mobile \; \
  send-keys -t mobile "npm run dev" Enter \; \
  attach-session -t mobile
```

## Aliases mobilité

```bash
# ~/.bashrc
alias md='tmux attach -t mobile'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline -10'
alias gp='git push'
alias dev='ssh -t dev "tmux attach -t code || tmux new -s code"'
```

## Astuces mobilité

- Utiliser `Ctrl-.` comme préfixe tmux (facile à tapoter)
- Configurer `mouse_shift_escape` dans le terminal
- Zoomer pour l'édition (`Ctrl-w z`)
- Utiliser `fzf` pour la navigation fichiers rapide

## Monitoring serveur

```bash
# Voir les processus
pm2 list

# Logs en temps réel
pm2 logs myapp

# Status serveur
htop  # (en SSH seulement!)
```