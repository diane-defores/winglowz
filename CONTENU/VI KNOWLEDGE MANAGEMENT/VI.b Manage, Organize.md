---
tags: Rédaction
u_interne: ""
u_externe: ""
datePublié: ""
imageNameKey: ""
_priorité: ""
---
# TUIFIManager - Le gestionnaire de fichiers en mode terminal

Ah, les gestionnaires de fichiers ! On en a vu de toutes les couleurs, des plus simples aux plus complexes, avec des interfaces graphiques variées plus ou moins foirées. Mais aujourd’hui, je vais vous parler d’un gestionnaire de fichiers qui sort des sentiers battus : **TUIFIManager**. Ce petit bijou fonctionne dans le terminal et vous allez l’adorer !

Alors, pourquoi choisir TUIFIManager plutôt qu’un autre gestionnaire de fichiers ? Tout d’abord, il est **multiplateforme**. Que vous soyez sous Linux, macOS ou Windows, TUIFIManager fonctionnera sans problème. Ensuite, il est **léger** et **rapide** et ne consommera pas toute votre RAM tout en offrant une expérience utilisateur fluide.

Mais ce n’est pas tout puisque TUIFIManager est également **personnalisable**. Vous pouvez modifier son comportement en utilisant des **variables d’environnement**. Vous avez envie de changer la couleur du texte, la taille de la police ou la disposition des éléments ? Pas de problème, TUIFIManager vous permet de le faire facilement.

![](https://korben.info/gestionnaire-fichiers-terminal-tuifimanager-multiplateforme-leger-personnalisable/ezgif.com-webp-maker.gif)

En plus de tout cela, TUIFIManager prend en charge la **souris**. Vous pouvez donc cliquer sur votre mulot comme un dingue pour naviguer dans vos fichiers, sélectionner des éléments et effectuer toutes sortes d’actions. Et si vous préférez utiliser le clavier, TUIFIManager vous offre également des **raccourcis clavier** afin de faciliter votre navigation.

Le projet TUIFIManager est en constante évolution et les développeurs travaillent sans relâche pour ajouter de nouvelles fonctionnalités et améliorer les performances. Pour installer TUIFIManager, il vous suffit d’utiliser la commande suivante :

```fallback
pip3 install TUIFIManager --upgrade
```

Je vous encourage également à vous rendre sur le dépôt GitHub et à suivre les explications fournies pour utiliser au mieux toutes les fonctionnalités de TUIFIManager mais également le personnaliser.

# Immich - La solution de sauvegarde auto-hébergée pour vos photos et vidéos

Le 3 août 2023par Korben -

1. [Outils-Services](https://korben.info/categories/outils-services/ "Voir tous les articles de la catégorie Outils-Services")
2. [Applications-Web](https://korben.info/categories/outils-services/applications-web/ "Voir tous les articles de la sous-catégorie Applications-Web")

Il était une fois, un Développeur nommé Alex qui cherchait désespérément une solution de sauvegarde auto-hébergée pour ses photos et vidéos de son magnifique bébé. Mais Alex ne voulait pas mettre tout ça dans un cloud privé tenu par les GAFAM.

Alors en bon geek, Alex a créé sa propre solution : **Immich** ! C’est une application mobile et web disponible sous licence MIT, axée sur la confidentialité, la collecte de “souvenirs” et bien sûr la facilité d’utilisation.

Voyez ça comme un Google Photos mais en version auto-hébergeable. D’ailleurs l’une des grandes fonctionnalités d’Immich est la sauvegarde automatique de vos photos et vidéos directement depuis votre smartphone et votre ordinateur. Plus besoin de se soucier de tout perdre dans un crash de disque dur ! Immich gère tout pour vous.

![](https://korben.info/immich-solution-sauvegarde-auto-hebergee-photos-videos/immich-screenshots.webp)

Aussi, si vous êtes un(e) passionné(e) de photographie, vous serez encore plus joyeux puisqu’il prend même en charge les formats RAW ! Vous pouvez également rechercher des images en utilisant des métadonnées, des noms d’objets, des visages, et même [CLIP](https://korben.info/comment-plagier-photo.html) dont je vous ai déjà parlé. Impressionnant, non ?

Si vous avez un appareil [Android](https://play.google.com/store/apps/details?id=app.alextran.immich&hl=fr&gl=US) ou [iOS](https://apps.apple.com/cm/app/immich/id1613945652), vous pouvez récupérer l’appli mobile.

Docker Compose est la méthode recommandée pour exécuter Immich en production donc créez un répertoire de votre choix pour y mettre les fichiers docker-compose.yml et .env.

```gdscript3
wget https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env
```

Ensuite, placez-vous dans le répertoire que vous avez créé et récupérez ces fichiers à l’aide des commandes suivantes :

Vous pouvez aussi les récupérer à la main depuis votre navigateur. Renommez le fichier example.env en .env et éditez la pour modifier les valeurs concernant la base de données et l’emplacement où seront stockés les fichiers…etc.

Enfin, lancez le docker-compose comme ceci :

```fallback
docker-compose up -d
```

Et pour récupérer les dernières mises à jour de Immich, utilisez cette commande :

```fallback
docker-compose pull && docker-compose up -d
```

Pour vous aider à en savoir plus, je vous invite à consulter la [documentation officielle](https://immich.app/docs) et pourquoi ne pas jeter un coup d’œil à la [démo](https://immich.app/demo). Notez cependant que l’application est encore en développement, alors ne la considérez pas comme l’unique moyen de stockage pour vos photos et vidéos. Les backups c’est comme les billets de 100 €, c’est mieux quand y’en a plusieurs !

[À découvrir ici](https://immich.app/).

[MoviePrint - Make screenshots of movies in an instant](https://www.movieprint.org/)
**MoviePrint** est un outil gratuit qui révolutionne la manière dont tu peux interagir avec les films, en offrant une solution simple et rapide pour capturer des images fixes de films. Que tu sois cinéaste, directeur de la photographie, animateur ou simplement amateur de cinéma, MoviePrint facilite ta vie en te permettant de **sélectionner, analyser, présenter et archiver** des films à travers des captures d'écran organisées en une image unique, appelée MoviePrint. L'interface est intuitive: il te suffit de glisser tes films ou d'utiliser le bouton "Ajouter des films" pour commencer. Grâce aux fonctionnalités comme le réglage des points d'entrée et de sortie, le choix de cadres alternatifs, l'insertion et la réorganisation de vignettes, tu peux personnaliser chaque MoviePrint selon tes besoins spécifiques. De plus, MoviePrint te permet **d'enregistrer et de partager facilement tes sélections**, que ce soit sous forme d'images PNG intégrant par défaut les numéros de cadres et les chemins de fichiers, ou en fichier JSON pour une réimportation facile.

L'outil offre également la capacité de **remplacer un film par une version différente** tout en conservant ta sélection de cadres, ce qui est idéal pour les coloristes voulant comparer différentes versions d'un film. MoviePrint continue de s'améliorer grâce à une communauté active sur GitHub, et tu es encouragé à contribuer au développement ou à partager tes retours. Avec déjà de nombreux utilisateurs satisfaits, MoviePrint se révèle être non seulement un gain de temps, mais un véritable allié pour la création visuelle et l'archivage cinématographique. Enfin, bien que l’application soit gratuite, MoviePrint encourage les utilisateurs à soutenir des organisations caritatives, soulignant ainsi son engagement envers une société plus solidaire.

## [(161) Best Digital Asset Management For Solo Entrepreneurs Find Stuff Fast!! - YouTube](https://www.youtube.com/watch?v=blxzpt8ST-o&lc=Ugx9syvB9Ii5GBLR1TN4AaABAg.9z1TdYSqMqr9z2syR-tpkr)
# Résumé de la vidéo "Gérer vos actifs numériques"

## Introduction

- Gérer les actifs numériques peut être difficile sans un système de classification efficace.

## Importance de la gestion des actifs numériques

- La gestion des actifs numériques (Digital Asset Management) consiste à administrer et organiser la distribution de fichiers multimédias.
- Il est crucial d'avoir un système organisé pour retrouver facilement les actifs nécessaires.

## Techniques de gestion des informations

- Utilisation de techniques de gestion des informations telles que Widen Collective pour centraliser, automatiser, collaborer et partager les actifs.
- L'ajout de métadonnées aux actifs est essentiel pour faciliter leur recherche et leur distribution.

## Avantages de la gestion des actifs numériques

- Réduction des coûts de production, allocation optimale des ressources et amélioration de la conversion et de la rétention des clients.
- Maintien de la cohérence de la marque et respect des règles de licence pour protéger les actifs.

## Utilisation d'un outil de gestion des actifs numériques

- Présentation de l'outil Eagle pour la gestion efficace des fichiers numériques.
- L'outil permet d'organiser, stocker, rechercher et taguer divers types de fichiers multimédias.

## Organisation des fichiers vidéo

- Mise en place d'un système de dossiers pour organiser les enregistrements bruts, les vidéos produites, les fichiers audio, les images, etc.
- Utilisation de sous-dossiers et de tags pour une recherche rapide et efficace des fichiers vidéo.

## Conclusion

- Un système de gestion des actifs numériques bien structuré permet d'optimiser la productivité et de garantir une utilisation efficace des ressources.

Ce résumé met en lumière l'importance d'une gestion efficace des actifs numériques et présente des conseils pratiques pour organiser et gérer ces actifs de manière optimale.

[Compress | Reduce the file size of your videos.](https://compress.ohzi.io/)
**Compress** is the tool you need that **converts videos** in any format to **nicely sized** lossless **MP4** in a **short time**, with the most seamless user interface.
## Epub & PDFs
[Thorium Reader](https://thorium.edrlab.org/)
**Thorium Reader is the EPUB reader of choice for Windows, MacOS and Linux.**

This EDRLab application is in constant development and is now the reference for accessing EPUB 3 publications in reflow or fixed layout format, audiobooks and visual narratives, PDF documents and DAISY ebooks; LCP protected or not.

It is localized in a large set of languages, each version offering new locales.

Huge efforts are also made to get Thorium Reader highly accessible for visually impaired and dyslexic people.

This application is free, with no ads and no leaks of private data. This is the perfect tools for heavy readers, library patrons and students.


[Explore your research photos | Tropy](https://tropy.org/)
"Tropy" is a tool designed for archival researchers to manage and organize their research photos efficiently. It allows users to turn photos into items, describe sources, organize research, annotate photos, and export research projects in various formats.

- Tropy helps researchers manage research photos efficiently.
- Users can describe sources, organize research items, and annotate photos within the tool.
- The software is fully integrated with Linux, macOS, and Windows operating systems.
- Tropy is free and open-source, supporting sustainable development practices.
- Core plugins like IIIF, Omeka, CSL, CSV, and Archive enable customization and extension of workflows.


[Tonfotos - best photo management software](https://tonfotos.com/)
Tonfotos is a photo organizing software that simplifies browsing and organizing large photo collections by grouping shots based on events, dates, people, and locations. It uses artificial intelligence to automatically find faces in photos and helps users mark images that include relatives and friends. The software allows users to store their photo archives wherever they prefer without limitations on the number of photos.
- Tonfotos organizes photos by events, dates, people, and locations.
- Uses AI to find and mark faces in photos, making it easier to identify loved ones.
- Offers flexibility in storing photo archives without vendor lock or monthly fees.
- Provides stunning slideshows with one click and focuses on enjoying memories rather than just moving files efficiently.
- Licensing options range from a free version to paid versions with additional features like unlimited photo storage and priority support.


[mediaChips is a software for organizing, tagging and viewing local videos](https://mediachips.app/?v=f9308c5d0596)
The text provides an overview of MediaChips, a media library management application that uses metadata "Chips" to organize and filter media files. It emphasizes features like customizable metadata, video preview, dynamic playlists, and detailed filtering options. The software is open-source, multi-platform, and allows for customization of appearance. Users appreciate its functionality for organizing raw video files efficiently.
- MediaChips is a media library management app that uses metadata "Chips" for organization.
- Features include customizable metadata, video preview, dynamic playlists, and detailed filtering options.
- The software is open-source, available on multiple platforms, and allows customization of appearance.
- Users find it helpful for organizing raw video files efficiently, especially for tasks like montage editing.
- The developer is responsive to user feedback and continuously updates the software with new features based on demands.



Reader
	Settings: Auto -advance
[Organize your files and folders with tags | TagSpaces](https://www.tagspaces.org/)
[Air Explorer is tool for managing and synchronizing your cloud data](https://www.airexplorer.net/en/)
## Manage, Organize
### Digital Asset Manager

[PhotoInsight - Find your photos](https://photoinsight.io/)
[Cloaked | Achieve Privacy](https://www.cloaked.com/)
Manage all your digital assets in one single application.  
Find them thanks to a powerful search engine based on metadata.  
Organize them with keywords, smart folders and collections.  
Send them to any application with a simple drag & drop or a right clic.
Cloaked paid subscription now includes Cloaked Identity Theft Insurance for up to $1 Million, Cloaked Pay (protect every payment method with a privacy layer, currently in beta) and Cloaked Data Removal, empowering you to:

- **Replace your personal information with Cloaked identities:** With Cloaked, you can generate unique identities—phone numbers, email addresses, and more—that shield your real information. This minimizes the risk of exposure in case of a data breach. Learn more [here](https://app.us7.list-manage.com/track/click?u=e6cdb0f9e645d98bcbb8b3655&id=f21780e541&e=7818de1b96).
- **Cloaked Data Removal:** We remove your personal information from data brokers and other entities that might misuse it. Learn more [here](https://app.us7.list-manage.com/track/click?u=e6cdb0f9e645d98bcbb8b3655&id=f8b34eb006&e=7818de1b96).
- **Identity Theft Insurance:** Cloaked offers up to $1 million in insurance coverage to cover identity theft and related losses. Learn more [here](https://app.us7.list-manage.com/track/click?u=e6cdb0f9e645d98bcbb8b3655&id=cef1267642&e=7818de1b96).
[Findr: One search for all apps](https://www.usefindr.com/#main)

[Search Aggregate](https://searchaggregate.com/)
[History Q-Dir - The Quad Explorer for MS OS](https://www.softwareok.com/?seite=Freeware/Q-Dir/History
		With the new ["Paste Special" feature, you can now quickly insert images and texts from the clipboard directly into the file explorer of Q-Dir as files, without any detours](https://www.softwareok.com/?seite=faq-Q-Dir&faq=145).
	- 📁 Q-Dir is a file management software for Windows.
	- 🚀 It offers fast and easy access to files and folders.
	- 💼 Suitable for various Windows versions, including Windows 11, 10, and more.
	- 🔑 Key features include file management in 4-window with tabs, folder size display, color filters, and more.
	- 🔄 Q-Dir is an alternative file manager with Quadro-View technique, preserving familiar functions.
	- 🖥️ It can be executed without installation and carried on a USB-stick for portability.
	- 🌐 Available in multiple languages with extensive language support.
	- 🆓 Free for company, business, and private use.
	- 🔄 Regular updates with improvements and bug fixes.
	- 🌈 Offers customizable views, drag & drop functionality, and quick access features.
	- 📜 Detailed version history and multilingual support showcase its popularity worldwide.
  Structure de Nom de Fichier

[Best Digital Asset Management For Solo Entrepreneurs Find Stuff Fast!! - YouTube](https://www.youtube.com/watch?v=blxzpt8ST-o)

	need to be able to search (→ tags)

	 master folder a copier a chaque projet

### Windows Explorer Alternatives

Disponible **gratuitement**, **en français** et **ne nécessitant même pas d’installation**, Q-Dir est un **utilitaire qui remplace l’Explorateur Windows et qui va révolutionner la gestion de vos fichiers sur votre ordinateur**.  
  
En effet, Q-Dir facilite la gestion de vos fichiers et dossiers. Dans la seule fenêtre de Q-Dir, vous pouvez **afficher autant de fenêtres d’exploration que vous le souhaitez** (une, deux, trois, quatre, etc). Ainsi, vos copies et déplacements de fichiers seront facilités.  
  
Pratique, vous pouvez ajouter les dossiers que vous utilisez fréquemment en favoris (_liens rapides_). Ainsi vous n’aurez plus besoin de naviguer dans les méandres de votre disque dur, en un seul clic, vous afficherez vos dossiers préférés.  
  
Q-Dir dispose également de nombreuses fonctionnalités, comme la possibilité **d’imprimer la liste des fichiers et des dossiers** contenus dans un dossier, **personnaliser l’apparence et les couleurs** de Q-Dir, etc.  
  
Si vous travaillez régulièrement dans l’Explorateur Windows pour gérer des fichiers et des dossiers, Q-Dir vous sera d’une grande aide. A tester, d’autant plus qu’il ne nécessite pas d’installation et qu’il est très léger ! Vous pourrez l’emmener partout avec vous, sur une clé USB par exemple.

file explorer 

Convention naming
follow the latch system. Latch stands for location, alphabet, time, category, and hierarchy.

[warpdesign/react-explorer: File manager written in TypeScript, React, Blueprint and packaged with Electron](https://github.com/warpdesign/react-explorer)

Tu Peux Grouper les Onglets

Après les Avoir Regroupés, Tu Peux Renommer, Mettre En Signet Ou Déplacer le Groupe

Mosaïque D'onglets : Verticalement, Horizontalement, Sous Forme de Grille

Organiser Avec Session/marques-pages

Utilise le Panneau Latéral Pour Garder les Applications Importantes Toujours Sur le Côté.

Il Existe de Nombreuses Autres Options, Tu Peux Définir des Touches de Raccourci Ou des Gestes Pour Accéder Aux Panneaux Latéraux, Pour les Rendre Actifs, Tu Peux les Ouvrir Avec la Fine Barre de Gauche Qu'ils Ont, Tu Peux les Faire Flotter Au-dessus de L'onglet de Navigation Qui Se Ferme Lorsque Tu Cliques Sur N'importe Quel Autre Endroit, Ou les Rendre Collants. Voici le Mien : (tu Peux Aussi Cacher les Panneaux Depuis la Barre de panneaux)

Zoomer Ou Dézoomer Sur L'interface Windows UI, Ou S'en Débarrasser Complètement ! Récupérer le Focus.

Ce Sont des Éléments D'un Menu Personnalisé Que J'ai Créé Pour Pouvoir Accéder à Ces Fonctionnalités Avec des Boutons (normalement, Tu Peux Y Accéder Avec des Commandes rapides) :

[Alternate Tools - Alternate Pic View Portable](https://www.alternate-tools.com/pages/c_picview_portable.php?lang=GER)
	Disponible **gratuitement**, **en français** et **ne nécessitant même pas d’installation** (application portable), _Alternate Pic View_ est **une visionneuse et un éditeur d’images**.  
	Concrètement, _Alternate Pic View_ permet d’ouvrir et de travailler sur plusieurs images/photos en même temps : diaporama, ajout d’effets, redimensionnement, convertisseur, extracteur d’icônes, capture d’écran, ajout d’objets (flèches, bulles, etc.).  
	Par défaut en anglais, _Alternate Pic View_ est également disponible **en français**. Pour cela, déroulez le menu **View** et cliquez sur **Language**. Sélectionnez **Français** dans la liste déroulante et cliquez sur **OK**.

## Digital footprint

[Yorba](https://yorba.co/)
Yorba is an online platform designed to make your internet experience less frustrating. It assists you in finding, monitoring, managing, and reducing your online accounts, including logins, paid subscriptions, data breaches, and mailing lists. With Yorba, you can take control of your digital presence and protect your privacy.