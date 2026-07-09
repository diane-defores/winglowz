export const prerender = true;

import type { APIRoute } from 'astro';

const installer = `#!/usr/bin/env sh
# Bootstrap ShipGlowz without a manual git clone.

set -eu

REPO_URL="\${SHIPGLOWZ_REPO_URL:-https://github.com/dianedef/shipglowz.git}"
BRANCH="\${SHIPGLOWZ_BRANCH:-main}"

if [ -n "\${SUDO_USER:-}" ] && [ "\${SUDO_USER:-}" != "root" ]; then
    INSTALL_USER="$SUDO_USER"
    INSTALL_HOME="\$(getent passwd "$INSTALL_USER" 2>/dev/null | cut -d: -f6 || true)"
    INSTALL_HOME="\${INSTALL_HOME:-/home/$INSTALL_USER}"
else
    INSTALL_USER="root"
    INSTALL_HOME="\${HOME:-/root}"
fi

SHIPGLOWZ_DIR="\${SHIPGLOWZ_DIR:-$INSTALL_HOME/shipglowz}"
BOOTSTRAP_LOG="\${SHIPGLOWZ_BOOTSTRAP_LOG:-$INSTALL_HOME/shipglowz-bootstrap.log}"

log() {
    printf '%s\\n' "$*"
}

prepare_log() {
    mkdir -p "\$(dirname "$BOOTSTRAP_LOG")" 2>/dev/null || true
    : > "$BOOTSTRAP_LOG" 2>/dev/null || true
    if [ "$INSTALL_USER" != "root" ]; then
        chown "$INSTALL_USER":"$INSTALL_USER" "$BOOTSTRAP_LOG" 2>/dev/null || true
    fi
}

run_or_explain() {
    label=$1
    shift

    if "$@" </dev/null >>"$BOOTSTRAP_LOG" 2>&1; then
        return 0
    fi

    log "Échec: $label."
    log "Détails: $BOOTSTRAP_LOG"
    log "Dernières lignes:"
    tail -n 8 "$BOOTSTRAP_LOG" 2>/dev/null || true
    return 1
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

as_install_user() {
    if [ "$INSTALL_USER" != "root" ] && has_cmd sudo; then
        sudo -H -u "$INSTALL_USER" "$@"
    else
        "$@"
    fi
}

install_bootstrap_deps() {
    if has_cmd git && has_cmd curl && has_cmd bash; then
        return 0
    fi

    log "Installation des dépendances de bootstrap..."

    if has_cmd apt-get; then
        run_or_explain "mise à jour apt" apt-get update -qq
        run_or_explain "installation de git/curl/bash" apt-get install -y -qq git curl bash ca-certificates
    else
        log "Impossible d'installer automatiquement git/curl/bash sur ce système."
        log "Installez ces dépendances puis relancez la commande."
        return 1
    fi
}

stash_shipglowz_changes() {
    if [ -z "\$(git -C "$SHIPGLOWZ_DIR" status --porcelain 2>/dev/null)" ]; then
        return 0
    fi

    log "Modifications locales détectées dans $SHIPGLOWZ_DIR; sauvegarde temporaire..."
    run_or_explain "sauvegarde des modifications locales ShipGlowz" as_install_user env \\
        GIT_AUTHOR_NAME="ShipGlowz Bootstrap" \\
        GIT_AUTHOR_EMAIL="shipglowz-bootstrap@example.invalid" \\
        GIT_COMMITTER_NAME="ShipGlowz Bootstrap" \\
        GIT_COMMITTER_EMAIL="shipglowz-bootstrap@example.invalid" \\
        git -C "$SHIPGLOWZ_DIR" stash push -u -m "shipglowz-bootstrap backup \$(date -u +%Y%m%dT%H%M%SZ)"
}

if [ "\$(id -u)" -ne 0 ]; then
    log "ShipGlowz installe des dépendances système et doit être lancé en root."
    log "Commande recommandée:"
    log "  curl -fsSL https://www.winglowz.com/shipglowz-script | sudo sh"
    exit 1
fi

prepare_log
log "Préparation de l'installation ShipGlowz..."
install_bootstrap_deps

if [ -d "$SHIPGLOWZ_DIR/.git" ]; then
    log "Mise à jour du dépôt ShipGlowz..."
    stash_shipglowz_changes
    run_or_explain "récupération de la dernière version ShipGlowz" as_install_user git -C "$SHIPGLOWZ_DIR" fetch origin "$BRANCH"
    run_or_explain "sélection de la branche $BRANCH" as_install_user git -C "$SHIPGLOWZ_DIR" checkout "$BRANCH"
    run_or_explain "mise à jour du dépôt ShipGlowz" as_install_user git -C "$SHIPGLOWZ_DIR" pull --ff-only origin "$BRANCH"
elif [ -e "$SHIPGLOWZ_DIR" ]; then
    log "$SHIPGLOWZ_DIR existe déjà mais ce n'est pas un dépôt git."
    log "Déplacez-le ou définissez SHIPGLOWZ_DIR vers un autre chemin, puis relancez."
    exit 1
else
    log "Téléchargement de ShipGlowz..."
    mkdir -p "\$(dirname "$SHIPGLOWZ_DIR")"
    run_or_explain "téléchargement de ShipGlowz" as_install_user git clone --quiet --branch "$BRANCH" "$REPO_URL" "$SHIPGLOWZ_DIR"
fi

exec bash "$SHIPGLOWZ_DIR/install.sh" "$@"
`;

export const GET: APIRoute = () => {
  return new Response(installer, {
    headers: {
      'Cache-Control': 'public, max-age=300, s-maxage=300',
      'Content-Type': 'text/plain; charset=utf-8',
    },
  });
};
