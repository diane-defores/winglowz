# Connexions SSH vs Mosh

Comparaison détaillée pour choisir le bon protocole selon l'usage.

## SSH - Secure Shell

### Avantages
- Support complet du terminal (TUI, couleurs, scrolling)
- Compatible avec tous les émulateurs terminaux
- Séquences d'échappement terminfo préservées
- Pas de problèmes avec tmux/plugins souris

### Inconvénients
- Connexion interrompue si changement réseau
- Latence plus élevée sur mauvaise connexion

## Mosh - Mobile Shell

### Avantages
- Reconnexion automatique
- Pas d'interruption en changeant WiFi/mobiles
- Idéal pour navigation mobile/non-stable

### Inconvénients
- **Problème majeur: pas de support alternate screen**
- Incompatible avec OpenCode/KiloCode scroll
- Problèmes avec certains TUI (htop, btop)

#### Problème alternate screen (technical)

Mosh ne supporte pas le terminal **alternate screen buffer** correctement. Les applications TUI utilisent ce buffer pour leur interface dynamique. Mosh gère mal les séquences d'échappement DEC/CSI.

**Solution:** Utilisez SSH pour le codage intensif:

```bash
# SSH - fonctionne parfaitement
ssh user@server

# Mosh - limité pour TUI
mosh user@server

# Configuration tmux pour contourner:
# set -g @emulate-scroll-for-no-mouse-alternate-buffer "on"
```

Si le scroll ne marche toujours pas: entrez en mode copy (`Ctrl-w [`) puis utilisez `Ctrl-u`/`Ctrl-d` pour naviguer.

## When to use what

| Situation | Protocole | Reason |
|-----------|-----------|--------|
| Codage TUI (OpenCode/KiloCode) | SSH | Scrolling fonctionnel |
| Navigation fichiers | Mosh | Tolérance réseau |
| Session longue mobile | Mosh | Pas de disconnection |
| Débogage intensif | SSH | TUI complet |
| Mauvaise connexion | Mosh | Roaming automatique |

## Debug connexion

```bash
# Tester SSH
ssh -v user@server

# Tester Mosh
mosh --ssh="ssh -v" user@server

# Voir les variables d'environnement terminales
echo $TERM
```

## Workflow quotidien

```bash
# 1. Se connecter (SSH pour coder, Mosh pour naviguer)
ssh dev    # ou mosh dev

# 2. Attach tmux session persistante
tmux attach -t mobile 2>/dev/null || tmux new -s mobile

# 3. Lancer OpenCode/KiloCode (en SSH seulement!)
opencode    # Si Mosh: navigation uniquement, pas de codage TUI

# 4. Split le terminal
Ctrl-w |    # Split vertical
Ctrl-w -    # Split horizontal

# 5. Navigation panes
Ctrl-w h/j/k/l

# 6. Quitter proprement
exit    # ou Ctrl-w x pour tuer le pane
```

## Aliases recommandés

```bash
# Dans ~/.bashrc Termux
alias dev='ssh -t dev "tmux attach -t mobile || tmux new -s mobile"'
alias dev-tui='ssh -t dev "opencode"'  # SSH pur pour TUI
alias m='mosh dev'  # Navigation uniquement
```