# Formation: Coder sur mobile

Formation complète pour développer efficacement depuis un terminal mobile (Termux + SSH/Mosh).

## Modules

1. **[Setup terminal](modules/01-setup-terminal.md)** - Installation Termux et outils de base
2. **[Connexions SSH/Mosh](modules/02-connections.md)** - Accès au serveur avec les avantages de chaque protocole
3. **[Éditeurs](modules/03-editors.md)** - Neovim, nano, outils mobilité
4. **[Workflow](modules/04-workflow.md)** - tmux, git, développement quotidien

## Points clés

- **Outils IA sur serveur uniquement** (OpenCode, KiloCode, Claude, Codex)
- **Mosh ne permet pas le scroll** dans les TUI (OpenCode, KiloCode, htop)
- **SSH obligatoire** pour coder avec les outils IA en mode TUI
- Configuration tmux optimisée pour mobile
- Workflow avec tmux panes et sessions persistantes

## Architecture

```
[Votre téléphone]           [Votre serveur Hetzner]
┌─────────────────┐        ┌──────────────────────┐
│  Termux (app)   │        │  Serveur Linux       │
│                 │        │                      │
│  ┌───────────┐  │   SSH  │  ┌────────────────┐  │
│  │ Terminal  │─────────→│  │ SSH daemon     │  │
│  │           │  │       │  └────────────────┘  │
│  └───────────┘  │        │          │           │
│                 │        │          ↓           │
│  ┌───────────┐  │        │  ┌────────────────┐  │
│  │   Mosh    │─────────→│  │ Mosh daemon    │  │
│  │ (optionel)│  │       │  └────────────────┘  │
│  └───────────┘  │        └──────────────────────┘
└─────────────────┘
```

**Workflow**:
1. Termux → SSH/Mosh → Hetzner
2. Dedans: `opencode`, `kilocode`, `claude`, `codex`, `nvim`, `tmux`
3. Mosh = pas de scroll dans les TUI (opencode/kilocode)
4. SSH = scroll OK mais déconnexion si mauvaise connexion
```

## Démarrage rapide

```bash
# SSH (pour TUI)
ssh user@yourserver

# tmux dans SSH
tmux new-session -s mobile-dev

# Mosh (pour navigation)
mosh user@yourserver
```