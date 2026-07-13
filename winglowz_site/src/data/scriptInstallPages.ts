import type { Language } from '@/types'

export interface ScriptInstallPageContent {
	slug: 'termux' | 'dotfiles' | 'shipglowz'
	name: string
	kicker: string
	title: string
	description: string
	command: string
	rawScriptUrl: string
	githubUrl: string
	githubLabel: string
	accent: 'cyan' | 'magenta' | 'green'
	visualLabel: string
	terminalLines: string[]
	fitTitle: string
	fit: string[]
	installedTitle: string
	installed: string[]
	excludedTitle: string
	excluded: string[]
	linksTitle: string
	links: Array<{ label: string; href: string }>
	copyLabel: string
	copiedLabel: string
	rawScriptLabel: string
	installNote: string
}

type ScriptPageKey = ScriptInstallPageContent['slug']

const pages: Record<ScriptPageKey, Record<Language, ScriptInstallPageContent>> = {
	termux: {
		en: {
			slug: 'termux',
			name: 'Termux Script',
			kicker: 'Android terminal setup',
			title: 'A light Termux setup for Markdown, notes, and quick edits.',
			description:
				'Install the mobile dotfiles profile without cloning the repository. It keeps Termux focused on text work: Neovim for Markdown, Nerd Font icons, shell helpers, Mosh, tmux, Ranger, and local tunnel commands.',
			command: 'curl -fsSL https://winglowz.com/termux-script | sh',
			rawScriptUrl: '/termux-script',
			githubUrl: 'https://github.com/dianedef/dotfiles',
			githubLabel: 'Dotfiles repository',
			accent: 'cyan',
			visualLabel: 'mobile profile',
			terminalLines: [
				'Préparation de l’installation Termux...',
				'1/6 Installation des paquets Termux',
				'4/6 Installation des tunnels ShipGlowz',
				'Installation Termux terminée.',
			],
			fitTitle: 'Best for',
			fit: ['Markdown files on Android', 'quick terminal edits', 'SSH sessions that need Mosh', 'a readable mobile Neovim profile'],
			installedTitle: 'Installed',
			installed: ['MyNeovimTermux', 'JetBrainsMono Nerd Font', 'Starship, Zoxide, Ranger', 'Mosh, tmux, ShipGlowz local tunnels', 'termux-theme with the thermux command'],
			excludedTitle: 'Intentionally skipped',
			excluded: ['Node.js and web development stack', 'MCP and AI agents', 'Copilot, Claude, Codex, OpenCode', 'heavy LSP and auto-build tooling'],
			linksTitle: 'Useful links',
			links: [
				{ label: 'Termux theme previewer', href: '/termux-themes' },
				{ label: 'Termux customization guide', href: '/blog/termux-customization' },
			],
			copyLabel: 'Copy command',
			copiedLabel: 'Copied',
			rawScriptLabel: 'Open raw script',
			installNote: 'Run from inside Termux. After installation, close Termux fully and reopen it so the font and terminal properties reload.',
		},
		fr: {
			slug: 'termux',
			name: 'Script Termux',
			kicker: 'Configuration terminal Android',
			title: 'Une config Termux légère pour le Markdown, les notes et les petites éditions.',
			description:
				'Installe le profil mobile des dotfiles sans cloner le dépôt. Termux reste concentré sur le texte: Neovim pour Markdown, icônes Nerd Font, helpers shell, Mosh, tmux, Ranger et tunnels locaux.',
			command: 'curl -fsSL https://winglowz.com/termux-script | sh',
			rawScriptUrl: '/termux-script',
			githubUrl: 'https://github.com/dianedef/dotfiles',
			githubLabel: 'Dépôt dotfiles',
			accent: 'cyan',
			visualLabel: 'profil mobile',
			terminalLines: [
				'Préparation de l’installation Termux...',
				'1/6 Installation des paquets Termux',
				'4/6 Installation des tunnels ShipGlowz',
				'Installation Termux terminée.',
			],
			fitTitle: 'Idéal pour',
			fit: ['fichiers Markdown sur Android', 'petites éditions dans le terminal', 'sessions SSH avec Mosh', 'profil Neovim lisible sur mobile'],
			installedTitle: 'Installé',
			installed: ['MyNeovimTermux', 'JetBrainsMono Nerd Font', 'Starship, Zoxide, Ranger', 'Mosh, tmux, tunnels locaux ShipGlowz', 'termux-theme avec la commande thermux'],
			excludedTitle: 'Exclu volontairement',
			excluded: ['Node.js et stack web', 'MCP et agents IA', 'Copilot, Claude, Codex, OpenCode', 'LSP lourds et tooling de build automatique'],
			linksTitle: 'Liens utiles',
			links: [
				{ label: 'Prévisualisateur de thèmes Termux', href: '/fr/termux-themes' },
				{ label: 'Guide de personnalisation Termux', href: '/fr/blog/termux-personnalisation' },
			],
			copyLabel: 'Copier la commande',
			copiedLabel: 'Copié',
			rawScriptLabel: 'Ouvrir le script brut',
			installNote: 'À lancer dans Termux. Après installation, fermez complètement Termux puis rouvrez-le pour recharger la police et les propriétés du terminal.',
		},
	},
	dotfiles: {
		en: {
			slug: 'dotfiles',
			name: 'Dotfiles Script',
			kicker: 'Personal workstation setup',
			title: 'Install the dotfiles profile without cloning first.',
			description:
				'Bootstrap the main dotfiles repository, update it safely, and run the real installer. It targets the current user profile: editor config, shell helpers, terminal tooling, and user-local binaries when system rights are limited.',
			command: 'curl -fsSL https://winglowz.com/dotfiles-script | sh',
			rawScriptUrl: '/dotfiles-script',
			githubUrl: 'https://github.com/dianedef/dotfiles',
			githubLabel: 'Dotfiles repository',
			accent: 'magenta',
			visualLabel: 'user profile',
			terminalLines: [
				'Préparation de l’installation dotfiles...',
				'Mise à jour du dépôt dotfiles...',
				'Starting dotfiles installation...',
				'User-local paths configured',
			],
			fitTitle: 'Best for',
			fit: ['Linux workstations', 'Codespaces-style environments', 'user-level shell and editor setup', 'reproducible dotfiles updates'],
			installedTitle: 'Installed by the profile',
			installed: ['Neovim configuration', 'Starship, Zoxide, FZF, Ranger', 'shell aliases and PATH setup', 'optional user-local CLI tools', 'config symlinks with backups'],
			excludedTitle: 'Boundary',
			excluded: ['ShipGlowz system setup still uses its own root installer', 'system services are not silently enabled from user mode', 'private secrets are not created by the bootstrap'],
			linksTitle: 'Useful links',
			links: [
				{ label: 'Termux mobile profile', href: '/termux' },
				{ label: 'ShipGlowz installer', href: '/shipglowz' },
			],
			copyLabel: 'Copy command',
			copiedLabel: 'Copied',
			rawScriptLabel: 'Open raw script',
			installNote: 'The bootstrap clones or updates ~/dotfiles, stashes local dirty changes before updating, then runs dotfiles/install.sh.',
		},
		fr: {
			slug: 'dotfiles',
			name: 'Script Dotfiles',
			kicker: 'Configuration poste utilisateur',
			title: 'Installe les dotfiles sans commencer par cloner le dépôt.',
			description:
				'Bootstrappe le dépôt dotfiles principal, le met à jour proprement, puis lance le vrai installateur. La cible reste le profil utilisateur: config éditeur, helpers shell, outils terminal et binaires user-local quand les droits système sont limités.',
			command: 'curl -fsSL https://winglowz.com/dotfiles-script | sh',
			rawScriptUrl: '/dotfiles-script',
			githubUrl: 'https://github.com/dianedef/dotfiles',
			githubLabel: 'Dépôt dotfiles',
			accent: 'magenta',
			visualLabel: 'profil utilisateur',
			terminalLines: [
				'Préparation de l’installation dotfiles...',
				'Mise à jour du dépôt dotfiles...',
				'Starting dotfiles installation...',
				'User-local paths configured',
			],
			fitTitle: 'Idéal pour',
			fit: ['postes Linux', 'environnements type Codespaces', 'configuration shell et éditeur utilisateur', 'mise à jour reproductible des dotfiles'],
			installedTitle: 'Installé par le profil',
			installed: ['configuration Neovim', 'Starship, Zoxide, FZF, Ranger', 'alias shell et PATH', 'CLI optionnelles en user-local', 'symlinks de config avec sauvegardes'],
			excludedTitle: 'Limite claire',
			excluded: ['ShipGlowz garde son installateur système root séparé', 'les services système ne sont pas activés silencieusement en mode utilisateur', 'les secrets privés ne sont pas créés par le bootstrap'],
			linksTitle: 'Liens utiles',
			links: [
				{ label: 'Profil mobile Termux', href: '/fr/termux' },
				{ label: 'Installateur ShipGlowz', href: '/fr/shipglowz' },
			],
			copyLabel: 'Copier la commande',
			copiedLabel: 'Copié',
			rawScriptLabel: 'Ouvrir le script brut',
			installNote: 'Le bootstrap clone ou met à jour ~/dotfiles, stash les changements locaux avant update, puis lance dotfiles/install.sh.',
		},
	},
	shipglowz: {
		en: {
			slug: 'shipglowz',
			name: 'ShipGlowz Script',
			kicker: 'Server and agent workflow setup',
			title: 'Install the operating layer around agent-built work.',
			description:
				'ShipGlowz combines a server control layer with an AI work discipline: context maps, scoped tasks, verification gates, skills, tunnels, PM2, Caddy, Flox, and the commands used to run real projects without losing the thread.',
			command: 'curl -fsSL https://winglowz.com/shipglowz-script | sudo sh',
			rawScriptUrl: '/shipglowz-script',
			githubUrl: 'https://github.com/dianedef/ShipGlowz',
			githubLabel: 'ShipGlowz repository',
			accent: 'green',
			visualLabel: 'root install',
			terminalLines: [
				'Préparation de l’installation ShipGlowz...',
				'Téléchargement de ShipGlowz...',
				'Mode root confirmé',
				'Configuration ShipGlowz multi-utilisateur',
			],
			fitTitle: 'Best for',
			fit: ['servers that run active projects', 'AI-assisted product work', 'fresh-agent handoffs', 'PM2, Caddy, Flox and tunnel operations'],
			installedTitle: 'Installed',
			installed: ['ShipGlowz CLI commands: shipglowz, sf, s', 'Claude/Codex skill symlinks', 'server tooling and wrappers', 'local project tracking data', 'terminal TUI commands when available'],
			excludedTitle: 'Important boundary',
			excluded: ['this installer requires root because it manages system dependencies', 'it does not replace project-specific deployment proof', 'it does not store provider OAuth tokens itself'],
			linksTitle: 'Useful links',
			links: [
				{ label: 'ShipGlowz public docs', href: 'https://github.com/dianedef/ShipGlowz' },
				{ label: 'Dotfiles installer', href: '/dotfiles' },
			],
			copyLabel: 'Copy command',
			copiedLabel: 'Copied',
			rawScriptLabel: 'Open raw script',
			installNote: 'Run from a sudo-capable account. The bootstrap prepares ~/shipglowz for that user, then delegates system setup to install.sh as root.',
		},
		fr: {
			slug: 'shipglowz',
			name: 'Script ShipGlowz',
			kicker: 'Setup serveur et workflow agents',
			title: 'Installe la couche d’opération autour du travail produit par agents.',
			description:
				'ShipGlowz combine une couche de contrôle serveur et une discipline de travail IA: cartes de contexte, tâches cadrées, gates de vérification, skills, tunnels, PM2, Caddy, Flox et commandes pour faire tourner de vrais projets sans perdre le fil.',
			command: 'curl -fsSL https://winglowz.com/shipglowz-script | sudo sh',
			rawScriptUrl: '/shipglowz-script',
			githubUrl: 'https://github.com/dianedef/ShipGlowz',
			githubLabel: 'Dépôt ShipGlowz',
			accent: 'green',
			visualLabel: 'install root',
			terminalLines: [
				'Préparation de l’installation ShipGlowz...',
				'Téléchargement de ShipGlowz...',
				'Mode root confirmé',
				'Configuration ShipGlowz multi-utilisateur',
			],
			fitTitle: 'Idéal pour',
			fit: ['serveurs qui font tourner des projets actifs', 'travail produit assisté par IA', 'handoffs vers agents frais', 'opérations PM2, Caddy, Flox et tunnels'],
			installedTitle: 'Installé',
			installed: ['commandes ShipGlowz: shipglowz, sf, s', 'symlinks de skills Claude/Codex', 'outillage serveur et wrappers', 'tracking local des projets', 'commandes TUI terminal quand disponibles'],
			excludedTitle: 'Limite importante',
			excluded: ['cet installateur demande root car il gère des dépendances système', 'il ne remplace pas la preuve de déploiement propre à chaque projet', 'il ne stocke pas lui-même les tokens OAuth fournisseurs'],
			linksTitle: 'Liens utiles',
			links: [
				{ label: 'Docs publiques ShipGlowz', href: 'https://github.com/dianedef/ShipGlowz' },
				{ label: 'Installateur dotfiles', href: '/fr/dotfiles' },
			],
			copyLabel: 'Copier la commande',
			copiedLabel: 'Copié',
			rawScriptLabel: 'Ouvrir le script brut',
			installNote: 'À lancer depuis un compte avec sudo. Le bootstrap prépare ~/shipglowz pour cet utilisateur, puis délègue l’installation système à install.sh en root.',
		},
	},
}

export function getScriptInstallPage(slug: ScriptPageKey, lang: Language) {
	return pages[slug][lang]
}
