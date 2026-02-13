Cest quoi une TUI

En informatique, une **TUI** signifie **Text-based User Interface** (Interface utilisateur textuelle).

C'est un juste milieu entre la ligne de commande classique (CLI) que l'on tape au clavier et l'interface graphique moderne (GUI) que l'on utilise avec une souris.

### 1. Comment ça se présente ?

Même si elle s'affiche dans un terminal, une TUI ne se contente pas de faire défiler du texte. Elle utilise toute la surface de la fenêtre pour afficher des éléments visuels "dessinés" avec des caractères (comme des traits, des blocs ou des symboles) et souvent des couleurs.

On y trouve généralement :

- Des **menus** navigables.
    
- Des **boutons** et des cases à cocher.
    
- Des **fenêtres** ou des panneaux séparés.
    
- La possibilité d'utiliser les flèches du clavier (et parfois la souris) pour se déplacer.
    

### 2. Pourquoi utiliser une TUI ?

Les TUI sont très populaires chez les développeurs et les administrateurs système pour plusieurs raisons :

- **Légèreté :** Elles consomment très peu de ressources par rapport à une application graphique.
    
- **Rapidité :** Une fois les raccourcis clavier maîtrisés, on va beaucoup plus vite qu'avec une souris.
    
- **Accès à distance :** Elles fonctionnent parfaitement via SSH (pour contrôler un serveur à l'autre bout du monde).
    
- **Esthétique :** Il y a un côté "rétro-geek" très apprécié.
    

### 3. Exemples courants

Voici quelques outils célèbres qui sont des TUI :

- **HTOP :** Pour surveiller l'utilisation du processeur et de la mémoire vive.
    
- **Vim / Nano :** Des éditeurs de texte directement dans le terminal.
    
- **GitUI / LazyGit :** Pour gérer ses versions de code visuellement sans quitter la console.
    
- **Midnight Commander (mc) :** Un gestionnaire de fichiers à l'ancienne.
    

---

**Souhaitez-vous que je vous aide à installer ou à découvrir un outil spécifique sous forme de TUI pour votre ordinateur ?**

Cest quoi fzf

**fzf** (pour _Fuzzy Finder_) est un outil en ligne de commande extrêmement populaire qui permet de faire de la **recherche floue** (fuzzy search) de manière interactive.

C'est une **TUI** (Interface Utilisateur Textuelle) qui agit comme un filtre : vous lui donnez une liste d'éléments, et il vous permet de trouver rapidement ce que vous cherchez en tapant seulement quelques lettres, même si elles ne sont pas consécutives.

---

### Comment ça fonctionne ?

Contrairement à une recherche classique qui exige l'orthographe exacte, `fzf` trouve des correspondances approximatives. Si vous tapez "mdo", il pourra vous trouver un fichier nommé "**m**on_**do**cument.txt".

### Les super-pouvoirs de fzf

Voici pourquoi presque tous les utilisateurs avancés de terminaux l'utilisent :

- **Rapidité fulgurante :** Il est écrit en Go et peut traiter des listes de millions de fichiers instantanément.
    
- **Aperçu interactif (Preview) :** Vous pouvez configurer `fzf` pour afficher le contenu d'un fichier ou une image dans un panneau latéral avant même de le sélectionner.
    
- **Universel :** Il peut filtrer n'importe quoi : des fichiers, votre historique de commandes, des processus en cours, des branches Git, etc.
    
- **Intégration Shell :** Une fois installé, il remplace souvent le traditionnel `Ctrl+R` pour retrouver une ancienne commande beaucoup plus facilement.
    

### Exemples d'utilisation

1. **Rechercher un fichier :** Tapez simplement `fzf` dans un dossier pour ouvrir l'interface et choisir un fichier.
    
2. **Combiner avec d'autres outils (le "Pipe") :**
    
    - `ls | fzf` : Pour choisir un fichier dans la liste.
        
    - `kill -9 $(ps -ef | fzf | awk '{print $2}')` : Pour tuer un processus en le choisissant visuellement dans une liste.
        
3. **L'historique des commandes :** En appuyant sur `Ctrl+R`, vous voyez toutes vos anciennes commandes et vous pouvez les filtrer en temps réel.
    

### Pourquoi est-ce une TUI ?

C'est une TUI car, dès que vous le lancez, il "prend possession" de votre terminal pour afficher une interface interactive avec une barre de recherche et une liste défilante, tout en restant léger et textuel.

---

**Utilisez-vous macOS, Linux ou Windows ? Je peux vous donner la commande pour l'installer et l'essayer tout de suite.**