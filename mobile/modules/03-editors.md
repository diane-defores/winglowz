# Éditeurs mobiles

Choisir et configurer les bons éditeurs pour le développement sur mobile.

## Neovim (recommandé)

```bash
pkg install neovim

# Configuration mobile-friendly
# ~/.config/nvim/init.lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

# Touche Esc qui marche sur mobile
vim.keymap.set('i', ';j', '<Esc>', { noremap = true })
vim.keymap.set('i', ';k', '<Esc>', { noremap = true })
```

### Plugins mobilité

```lua
-- LazyVim ou Packer
return {
  "kylechadwick/vim-curse-words",  -- Navigation mot à mot tactile
  "tpope/vim-sensible",
  "junegunn/fzf",  -- Recherche rapide
}
```

## Nano - Alternative légère

```bash
pkg install nano

# ~/.nanorc
set autoindent
set backup 2
set tabsize 2
set linenumbers
```

## Édition à distance

### vim-over-ssh

```bash
ssh user@server
vim /path/to/file
```

### Mounting avec SSHFS

```bash
pkg install sshfs

# Monter le serveur
mkdir -p ~/mnt/server
sshfs user@server:/ ~/mnt/server
```

## Terminal multiplexer

### tmux mobile config

```tmux
# ~/.tmux.conf
set -g prefix C-w
setw -g mode-keys vi
set -g history-limit 100000
set -g mouse on

# Status bar compact
set -g status-right "#{H:#{?window_zoomed_flag,#[bg=colour226#,fg=#000] Z ,}(#{=20:pane_title}) %d/%m %H:%M"

# Zoom tactile
bind z resize-pane -Z
```

## Workflow édition mobile

1. Utiliser tmux pour garder la session active
2. Naviguer avec `Ctrl-w h/j/k/l`
3. Zoomer avec `Ctrl-w z` pour voir le code
4. Split vertical avec `Ctrl-w |` pour docs/code côte à côte