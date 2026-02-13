---
tags: Rédaction
u_interne: ""
u_externe: ""
datePublié: ""
imageNameKey: ""
_priorité: ""
---

>  Forcing yourself to make decisions every time you capture something adds a lot of friction to the process. This makes the experience mentally taxing and thus less likely to happen in the first place.
>  Tiago Forte - Building a second brain

My mind is 100% focused on the task of capturing knowledge and storing it,
# Monolith - L'outil parfait pour sauvegarder le web

Le 22 juin 2024par Korben -

1. [Developpement](https://korben.info/categories/developpement/ "Voir tous les articles de la catégorie Developpement")
2. [Outils-Dev](https://korben.info/categories/developpement/outils-dev/ "Voir tous les articles de la sous-catégorie Outils-Dev")

Je vais vous parler aujourd’hui d’un outil vraiment cool pour faire de l’archivage de pages web. Alors oui, je sais, on peut déjà enregistrer une page web avec le navigateur, mais cet outil baptisé [Monolith](https://github.com/Y2Z/monolith) permet de faire 1000 fois mieux que ça. Il va non seulement sauvegarder la page cible, mais aussi embarquer d’un coup tous les éléments CSS, images et JavaScript dans un seul et unique fichier HTML5.

Et contrairement à une sauvegarde classique ou même avec `wget`, Monolith intègre tous les assets en URLs de données. Ça veut dire que votre navigateur va pouvoir afficher la page exactement comme elle était sur le web, même sans connexion Internet !

Pour l’installer, c’est ultra simple. Que vous soyez sur Windows, macOS, GNU/Linux ou même sur des devices exotiques avec des processeurs ARM, ça marchera forcement :

- Avec [Cargo](https://crates.io/crates/monolith) (cross-platform) : `cargo install monolith`
- Via [Homebrew](https://formulae.brew.sh/formula/monolith) (macOS et GNU/Linux) : `brew install monolith`
- Avec [Snapcraft](https://snapcraft.io/monolith) (GNU/Linux) : `snap install monolith`
- Et plein d’autres options encore…
# Hoarder - Tout sauvegarder mais surtout, tout retrouver...

Le 10 juillet 2024par Korben -

1. [Outils-Services](https://korben.info/categories/outils-services/ "Voir tous les articles de la catégorie Outils-Services")
2. [Applications-Web](https://korben.info/categories/outils-services/applications-web/ "Voir tous les articles de la sous-catégorie Applications-Web")

Vous êtes un **accumulateur compulsif** de liens intéressants, d’articles à lire plus tard, de notes en vrac et d’images inspirantes ? Ça tombe bien, moi aussi et j’ai trouvé un super outil pour assouvir notre soif de collectionnite aiguë sans nous noyer dans le bordel : **Hoarder** !

C’est quoi Hoarder ? Et bien c’est une app **open source** et **auto-hébergeable** qui permet de sauvegarder en deux clics tout et n’importe quoi : des **liens** avec prévisualisation automatique, des **notes** de texte et même des **images**. Bon OK, je sais, y’a déjà 15000 apps de bookmarking et de prise de notes, alors pourquoi s’emballer pour Hoarder ?

![](https://korben.info/hoarder-app-open-source-sauvegarder-retrouver-facilement/SCR-20240407-rdn-1024x534.webp)

Et bien parce qu’elle coche toutes les cases du cahier des charges de l’accumulateur exigeant :

- 🔍 Une **recherche full-text** puissante pour retrouver en deux secondes la perle rare enfouie sous des tonnes de bookmarks.
- 🏷️ Un **étiquetage automatique** par IA pour classer et organiser le bordel sans effort. Hoarder analyse le contenu et lui colle des tags pertinents. Magique !
- 🌙 Un **mode sombre** (indispensable ^^).
- 💾 La possibilité de tout **héberger soi-même** sur son serveur, pour garder le contrôle sur ses données.
- 📱 Des **apps mobiles** (en plus du web) pour “hoarder” aussi depuis son smartphone.
- 🆓 Tout ça gratuitement et avec une **bonne tronche** bien moderne, merci le design material.

Pour centraliser votre bordel numérique, c’est l’idéal. Vous pourrez sauvegarder tous les articles et threads Twitter intéressants que vous croisez, prendre des notes quand une idée vous traverse l’esprit (un jour peut-être ? ^^) et bien sûr y stocker tous les memes les plus drôles pour les ressortir au bon moment.

Le créateur de Hoarder, Mohamed Bassem, est un ingénieur système qui voulait garder la main dans le dev web tout en se faisant plaisir. Il utilisait Memos, une autre app de prise de notes, mais il lui manquait des features essentielles comme la prévisualisation des liens et le tagging automatique. Plutôt que de râler, il a retroussé ses manches et pondu sa propre solution. Respect.

D’ailleurs, Hoarder s’inspire beaucoup de [Mymind](https://mymind.com/), un produit commercial similaire, mais en y ajoutant la dimension auto-hébergement qui est primordiale pour les paranos de la vie privée dont je fais partie. Les alternatives open source comme Shiori ou LinkWarden ne proposent pas (encore) le tagging automatique par IA.

Et sous le capot, ça tourne avec des technos bien sexy comme **Next.js**, **tRPC**, **Meilisearch** et **OpenAI**.

Pour l’installer, c’est très simple : tout est packagé pour tourner facilement avec **Docker** et **Docker Compose**. Il vous faudra aussi une clé d’API **OpenAI** (pour le tagging) mais c’est optionnel et peu coûteux. [Tous les détails sont dans la doc](https://github.com/MohamedBassem/hoarder-app).

Vous pouvez aussi tester [une démo en ligne](https://try.hoarder.app/) si vous voulez vous faire une idée avant d’installer. Allez, je vous laisse, j’ai un paquet de liens à sauvegarder moi ! 😉

Merci à Lorenper pour l’info !

[Niphtio](https://www.nipht.io/)
## ScreenPipe
[screenpipe](https://screenpi.pe/)

Bienvenue sur ma chaîne YouTube ! Aujourd'hui, nous allons résumer le contenu de la page web de Screenpipe en quelques points clés :

- **Enregistrement 24/7** de votre écran et microphone sur votre ordinateur.
- **Intégration avec l'IA** pour analyser et créer à partir de vos données.
- **Fonctionnalités principales** :
  - Capture des détails des réunions sans connexion internet.
  - Compatible avec WhatsApp, Zoom, Google Meet, etc.
  - Amélioration de la productivité avec automatisation des mises à jour Notion, rapports Slack, et entrées CRM.
  - Extraction instantanée de connaissances à partir de divers contenus (emails, chats, documents).
- **Protection des données** avec suppression des informations personnelles au niveau du réseau.
- **Plugins AI** personnalisables pour optimiser l'enregistrement d'écran.
- Témoignages d'utilisateurs comme Eva et David sur l'augmentation de leur efficacité et de leurs revenus grâce à Screenpipe.
- Ressources disponibles : FAQ, démonstrations, documentation, et support communautaire.
- Options pour télécharger l'application, réserver une démonstration pour les entreprises, et découvrir les tarifs.

N'oubliez pas de vous abonner à notre chaîne YouTube pour plus d'exemples et de conseils ! Et pour toute question, n'hésitez pas à nous contacter par email ou sur nos réseaux sociaux. Merci d'avoir regardé et à bientôt !
Découvre Screenpipe, un logiciel innovant qui utilise l'intelligence artificielle pour enregistrer et analyser en continu les activités de ton écran et de ton micro, en t'assurant une **capture sécurisée** de toutes tes données directement sur ton ordinateur. Ce logiciel est conçu pour **boost** ta productivité en te permettant de ne jamais manquer un détail important lors de tes réunions grâce à ses **capacités de contextualisation** complètes et la **capacité d'extraire instantanément des connaissances** pertinentes, que ce soit à partir d'emails, de discussions ou de documents. Mieux encore, Screenpipe garantit une **protection infaillible de tes données**, en assurant que tes données privées restent inaccessibles au cloud tout en te permettant de travailler avec des modèles d'IA locaux.

Screenpipe est particulièrement apprécié pour sa **flexibilité et son intégration facile** avec divers outils comme WhatsApp, Zoom ou Google Meet, sans compromettre la confidentialité. Il te permet également d'**automatiser de nombreuses tâches** répétitives en mettant à jour automatiquement les entrées Notion, les rapports Slack et les CRM, transformant ainsi ton quotidien en éliminant le travail fastidieux. Les utilisateurs tels que Clara et Bob ont constaté des améliorations significatives dans leurs activités, avec des gains financiers de 30% et un accroissement des revenus clients de 20% respectivement, grâce aux fonctionnalités de Screenpipe. Que tu sois développeur, créateur de contenu ou professionnel en entreprise, cet outil est un **véritable atout** pour renforcer ton efficacité et libérer ton potentiel d'innovation.


[peazip/PeaZip](https://github.com/peazip/PeaZip)
PeaZip offers a LGPLv3 alternative to proprietary software (WinZip, WinRar, etc), running as native application on Windows/Win64, Wine/ReactOS, Linux x86/x86-64 (with Linux ARM and BSD ports also available), and Darwin/macOS both Intel x86_64 and aarch64 (e.g. M1 Apple Silicon SoC).

How to build PeaZip
## Curate better

# **Curate better**

# **Get URLs**

I use [Copy Title and Url as Markdown Style](https://chrome.google.com/webstore/detail/copy-title-and-url-as-mar/fpmbiocnfbjpajgeaicmnjnnokmkehil) for single url because I like the big notif and [Rich URL](https://www.notion.so/0f89f61baad940dd9c29c98f0b7263f9?pvs=21) for several urls

# **Capture screenshots**

- Take full page and custom-size screenshots with [Lightweight Screenshot](https://www.notion.so/52d971c3dac4437e9430a491282c316e?pvs=21). If you [Use Vivaldi](https://www.notion.so/6d4a765b53ad4ceaae3f4588e1d42f3c?pvs=21) you don’t need it because [it has this feature built-in](https://help.vivaldi.com/desktop/tools/capture-a-screenshot/)
- [Nimbus Capture – Capture screenshots and record video & screencasts](https://www.notion.so/f8031621c3d54843abcb8a946ddce4ea?pvs=21)
- [Greenshot](https://www.notion.so/473b90392e164c83af9f832a8352c2d5?pvs=21) in also an awesome free capture tool, you can add effects directly after capturing

# **Highlight the web, manage snippets**

- [Dynalist Highlighter](https://www.notion.so/8d7bf664f72d4185b52a03d9f3ca308f?pvs=21) is the perfect companion if you use the awesome [Dynalist](https://dynalist.io/) outliner
- [LINER | Search Less, Learn More](https://www.notion.so/a508fdb972b24d48bcd5d3b0b695d05d?pvs=21) is an highlighter of web pages that remembers your text highlights
- [Snippet](https://www.notion.so/45b7d31908d24d979e823321b837c4b6?pvs=21) or [Web Highlights + Bookmarks, Tags & Folders](https://chrome.google.com/webstore/detail/web-highlights-%2B-bookmark/hldjnlbobkdkghfidgoecgmklcemanhm/related) will organize and remember snippets on web pages all over the web
    - Does not copy link
    - Cannot merge or export multiple snippets at once
- [Web Highlight](https://chrome.google.com/webstore/detail/web-highlight/nacjdocenajmlomcagpkmhpikhcdligg) automtically highlights the most important sentences on websites, powered by AI.

### **Automatically copy selected text**

- [Auto Copy](https://www.notion.so/dd11c8fa61e44d1a8d40c1464373de1c?pvs=21) send mouse-selected text to your clipboard, and shows a notification on the screen so you’re sure it’s copied
- [Copy text with Alt-Click](https://chrome.google.com/webstore/detail/copy-text-with-alt-click/obhagoegpnbklgknnmbglghkfdidegkl) is an alternative that works by Alt + Click, and does not keep formatted links

### **Clipboard Manager**

- [Clipboard History Pro](https://www.notion.so/82bce3c2e62a47419d3cca0145d0e657?pvs=21)
- [CopyQ](https://www.notion.so/953528133c9f49379d0bcc6539042985?pvs=21) is advanced clipboard manager with editing, grouping and scripting features, it can totally be used for curating content.
- Sometimes you need to input info in popups where you can’t reach any clipboard. that’s when [Paste On Screen](https://chrome.google.com/webstore/detail/paste-on-screen/dhiihpekdgggkglfppkmjjmnaigmnjao) will save you.

[Alternatives that doesn’t watch automatically clipboard](https://www.notion.so/7560b33400454cebbc6829a1052f6151?pvs=21)

- [**Clipt – Seamlessly transfer photos, files & text between devices**](https://www.onelab.studio/work/clipt?trackID=314fdc8c-c746-40bf-abe9-8a60c72f134d) This [#freebie](https://l.facebook.com/l.php?u=https%3A%2F%2Fc.kenmoo.me%2Fclipt%3Ffbclid%3DIwAR0YwNVJOrmUwHyxcAnmeKRJaEYsxo7-j-FKUJC-c8VubDkRt6fI7ro0wkI&h=AT3v8ELZ435UDIt-7Dyxw8hWagkKO-pP2BOrAqflCxdQNrRQeSH37jr5lkZ7r9KDKK1FomXtYS1GYpswvs2bAcVwUolYRuM_sEd69zYzHND_BiC1k7bmkcQF6_AFhMjjIZrO3Ogp5dIHpeahCM20&__tn__=-UK-R&c%5B0%5D=AT3oCLKYICdZJeuHXoL6XLXEci3JZrFBU-Y7Jq3hcEuHqFEEiyoFvUx6JOdAnY50YGBbZum3iNPISPyB2OFGwRCSZEr8aCe65LUNV-NwsYonb-LTzH6BYEfg9QJCNsg6fm3lTtYPGI-5hrVTqpk0i72kmxGN3HfVRv8) seamlessly and safely transfers text, photos, videos, and files between your devices by connecting your phone & laptop clipboard. The App and Chrome extension creates **a link between your devices to seamlessly connect your clipboard.** Once installed you can copy on one device and paste on another or use it to send files back and forth easily, connected to as many devices as you’d like.Tired of sending yourself a message to transfer files between your devices? Get **Clipt** instead! [https://c.kenmoo.me/clipt](https://c.kenmoo.me/clipt)
    - **Transfer photos and videos** from your smartphone (Android/iPhone) to laptop (Mac/PC)
    - **Send a password code** from your phone to computer
    - **Copy on one device & paste on another**
    - **Manage files** between your phone & laptop
    - **Transport text** between devices

# **Useful apps**

- Twitter can be hard to keep up with if you don’t organize the accounts you follow. That’s where [**Twitter Lists**](https://ecosystem.hubspot.com/marketplace/apps/marketing/social-media/twitter) come in handy: curated groups of Twitter users that you can categorize and follow separately from the rest of your feed. Even better, you can make it public so that other Twitter users can access your lists as well. Furthermore, if you create a Pocket account (mentioned above), you can easily save articles from Twitter directly into your account.
- [Best Free OCR API, Online OCR, Searchable PDF](https://www.notion.so/2e7c1122c04e4131b72c0d5f7cb0f6d6?pvs=21) copy text from images
- If you listened to Joe from The Automator when looking at [Use Macros](https://www.notion.so/48eb405fc4f44ff68874975a03cc9b0c?pvs=21), he actually built an [OCR that copies automatically to clipboard](https://www.youtube.com/watch?v=YO--VBqJW7o) with autohotkey
- [Capsulelink | Group, save and send links as one.](https://www.notion.so/624f63da015c4152ae53ac6779279f4a?pvs=21)
- [Inoreader – Take back control of your news feed](https://www.notion.so/6f07a6da10344eda8a56ccd372a651bd?pvs=21) is a curation tool in itself as like other RSS readers it allows you to collect and update blog articles from the web, as must have
- [Stoop – A newsletter app](https://www.notion.so/76838497fdfd4ecdb9f6f200b1ec4cb8?pvs=21) in an amazing app where you can read you newsletter without having to clutter your email. It works so well but seems abandoned unfortunately…

# **Curate, collaborate & showcase**

If you’re working on and for the web, you will spend a lot of time searching, retaining and reusing information. To build this into a scalable strategy, here are awesome curation tools

- [Save to Facebook](https://www.notion.so/da210709de624b4baf93eb02cafab575?pvs=21) you can use if you want Facebook to be the only place you save content to
- [Notion Web Clipper](https://www.notion.so/84e77d6df6d84bb1be37496eb0269110?pvs=21) can capture url & page content and send it to your Notion pages or Database. For saving to databases though, I recommend the use of [Save to Notion](https://www.notion.so/66bffcff84884367a68e5859d961798c?pvs=21) it’s more complete and allows to define properties while saving.
- [Save the internet with one click – Swipebasket](https://www.notion.so/03ed8527a1b4498b9e0b204a28478445?pvs=21) is well done and integrated
- [Evernote Web Clipper](https://www.notion.so/00bd42e2d0f8444ea57cd6f41478005a?pvs=21) is good for those old Evernote users
- [Send to Airtable](https://www.notion.so/e2935167bb78490b8b69485d2609777a?pvs=21) lets you capture any page to any database for FREE
- With Collect from [WeTransfer](https://www.notion.so/abc4be912eac4e7ca5c9aea507454386?pvs=21) you can save and organize files from your mobile phone and from the web, also neatly organize them in presentations
- Alternatives
    - [Pocket](https://www.notion.so/0c0ade46011a452697e2e077fc6927cb?pvs=21) allows you to save articles, Web pages, images and videos and syncs everything across numerous devices, such as your smartphone or tablet.
    - [OneNote Web Clipper](https://www.notion.so/b6d3956dc5db4c13853a0b9dfe284549?pvs=21) lets users quickly clip all or part of a web page
    - [Quuu](https://quuu.co/) integrates with most major social media scheduling tools, including [**HubSpot**](https://www.hubspot.com/), and allows you to discover and share content.
        - It auto-categorizes your content, making it easier to sift through later
        - It offers reader-mode to make your experience free of distractions
        - The integrated scheduling dashboard makes it easy to share the content you discover
        - **Pricing**: $0 to $15.83/month
    - [Elink – Bookmark Manager](https://www.notion.so/049c6ee301e5492ca39771f4c935412c?pvs=21) takes the pain out of content curation and allows anyone to save links on the go and turn them into beautiful, shareable content. You can convert your links into a web page and embed them on a website or send them as a newsletter. They have a whopping 30+ responsive templates that you can customize to your liking. With over 80,000 users worldwide, elink is one of the best tools when it comes to fast and beautiful content curation.
## Download
[Tyrrrz/YoutubeDownloader: Downloads videos and playlists from YouTube](https://github.com/Tyrrrz/YoutubeDownloader)
[Download with Ant Download Manager](https://chromewebstore.google.com/detail/download-with-ant-downloa/dalgiebmfcjackkbjfbfmlnflbdfbekj)

[Video Downloader Professional](https://chromewebstore.google.com/detail/video-downloader-professi/elicpjhcidhpjomhibiffojpinpmmpil)
Sorry. The policies of the Chrome Web Store do not allow extensions to download videos from YouTube. So we removed this functionality from our Add-On.

[CRX Extractor/Downloader](https://chromewebstore.google.com/detail/crx-extractordownloader/ajkhmmldknmfjnmeedkbkkojgobmljda?hl=fr)
Download CRX Files directly as crx or zip file depending upon your choice

Download Chrome extension crx files from google chrome extension store using this extension. ## The source code of the extension is available here https://github.com/tonystark93/crx-download ## This extension doesn't contain any tracking source code or ad code. you can also check by downloading the extension using this same extension to check whether any tracking or ad code is injected. You could either download the extension from google chrome extension webstore as zip file or crx file depending upon your needs. No need to depend or copy paste the Chrome extension url to another website to download as crx or zip file. CRX to ZIP conversion helps users to convert from crx to zip file formats






### [WebTorrent - Streaming browser torrent client](https://webtorrent.io/)
- 🌐 WebTorrent is a streaming torrent client for the web browser and the desktop, written in JavaScript and using WebRTC for peer-to-peer transport
- 🤔 Imagine a peer-to-peer YouTube where viewers help to host the site's content
- 📱 See WebTorrent in action on the Web at Instant.io or install WebTorrent Desktop for Mac, Windows, and Linux
- ℹ️ Learn more about WebTorrent through the Get Started, Docs, and FAQ sections
- 🌐 Connect with WebTorrent through Twitter, GitHub, Discord, and GitHub discussions
- ℹ️ Support WebTorrent by starting a GitHub discussion or opening an issue
You don't have to wait for it to finish downloading.

WebTorrent Desktop is fast, free, non-commercial & open source.
**WebTorrent** is a streaming torrent client for the **web browser** and the **desktop**.
### [Motrix](https://motrix.app/)

## OCR
### [Text-Grab](https://github.com/TheJoeFin/Text-Grab?tab=readme-ov-file)
This is a minimal optical character recognition (OCR) utility for Windows 10/11 which makes all visible text available to be copied.

Too often text is trapped within images, videos, or within parts of applications and cannot be selected. Text Grab takes a screenshot, passes that image to the OCR engine, then puts the text into the clipboard for use anywhere. The OCR is done locally by [Windows API](https://docs.microsoft.com/en-us/uwp/api/Windows.Media.Ocr). This enables Text Grab to have essentially no UI and not require a constantly running background process. Working with text can be much more than just copying text from images, so Text Grab has a range of different modes to make working with text fast and easy.

I am the author of the [PowerToy Text Extractor](https://learn.microsoft.com/en-us/windows/powertoys/text-extractor). The Full-Screen Grab mode of this app was the basis of that PowerToy

Disponible **gratuitement** et **ne nécessitant même pas d’installation** (application portable), _Text-Grab_ est **un utilitaire de reconnaissance de caractères (OCR) permettant de récupérer n’importe quel texte affiché sur votre écran d’ordinateur**. Pratique pour extraire et copier facilement le texte contenu dans une image par exemple ! Cela fonctionne également pour récupérer le texte affiché mais non sélectionnable dans un logiciel.  
  
_Text-Grab_ est très simple d’utilisation. Exécutez-le pour voir apparaître sa barre d’outils et sélectionnez la zone de l’écran dont vous souhaitez extraire le texte. Le texte est automatiquement copié dans le presse-papiers. Vous pouvez alors le coller dans le logiciel de votre choix. Vous pouvez également épingler son icône dans la barre des tâches pour accéder à toutes ses fonctionnalités encore plus rapidement.  
  
Fort de son succès, _Text-Grab_ est désormais également intégré dans [_les PowerToys de Microsoft_](https://www.pcastuces.com/logitheque/powertoys.htm).
## 
[5min Podcast Summaries | Snipd](https://www.snipd.com/ai-podcast-summaries)
Snipd is a platform that provides high-quality summaries of your favorite podcasts, allowing you to quickly grasp key insights and save time. With Snipd, you can read or listen to concise summaries that capture the main points and ideas discussed in the episodes.

- **AI-Powered Summaries**: Snipd utilizes AI technology to generate accurate and concise summaries of podcast episodes.
- **Full Episode Access**: Easily access the full episode of the podcast after reading or listening to the summary.
- **Listening Convenience**: Listen to summaries on the go, while performing daily tasks or during downtime.
- **Wide Podcast Coverage**: Snipd covers a variety of English podcasts, providing summaries for a diverse range of topics and genres.
- **Efficient Learning**: Get key insights from podcasts in just 5 minutes, enabling efficient learning and information consumption.

Use Cases:
- **Time-Saving**: Save time by quickly getting the main points of podcasts without having to listen to the entire episodes.
- **Knowledge Consumption**: Stay up-to-date with industry trends, news, and educational content by reading or listening to podcast summaries.
- **Exploring New Podcasts**: Discover new podcasts and determine if they align with your interests by reading the summaries.
- **Convenient Learning**: Use Snipd to learn on the go while engaged in other activities like commuting, exercising, or doing household chores.
- **Research and Reference**: Use Snipd summaries as a reference tool for gathering key insights and ideas from podcasts for research or presentations.


[Collections pour votre Pocket](https://getpocket.com/fr/collections)
Pocket, anciennement connu sous le nom de Read It Later, est une application et un service Web permettant de gérer une liste de lecture d'articles et de vidéos sur Internet. Lancée en 2007, l'application était à l'origine réservée aux ordinateurs de bureau et portables et est désormais disponible pour macOS, Windows, iOS, Android, Windows Phone, BlackBerry, les liseuses Kobo et les navigateurs Web. Pocket a été racheté par Mozilla, le développeur du navigateur Web Firefox, en 2017.


[ResearchGPT - Research Assistant for finding papers and getting citations backed answers.](https://www.researchgpt.com/)
ResearchGPT is a powerful tool that helps researchers and scientists find relevant papers and obtain answers supported by citations.  
  
The website allows users to search for papers related to their research topics. By entering keywords or specific queries, researchers can discover relevant academic papers from various fields.  
  
ResearchGPT provides answers to users' questions that are backed by citations from credible sources. It ensures that the information provided is well-supported by scientific literature.
## Reader

[Recall - Summarize and save any online content](https://www.getrecall.ai/)
	Recall is a website that offers an AI-powered knowledge base, designed to help you summarize, categorize, and review online content.  
  
Features:  
1. Summarize Any Online Content: Recall allows you to save time by providing summaries of various types of online content. Whether it's a blog post, YouTube video, article, PDF, or any other webpage, you can use the Recall Chrome Browser Extension to generate a summarized version of the content.  
  
2. Centralize Your Content: With Recall, you can gather all your online content in one place. It allows you to summarize and save podcasts, YouTube videos, news articles, blogs, PDFs, and more. This centralization helps you easily access and refer to your saved content whenever needed.  
  
3. Automatic Categorization: Manual categorization can be laborious and inconsistent. Recall simplifies the process by using AI to automatically categorize your saved content. This ensures that your content is organized efficiently and makes it easier for you to find relevant information.  
  
4. Automatic Connections: When you save new content, Recall automatically identifies and links it with existing content that is related. This feature helps you discover connections between different pieces of information, allowing you to explore related topics and deepen your understanding.  
  
5. Spaced Repetition: Recall recognizes that learning is an ongoing process. With the help of spaced repetition, it assists you in retaining and reinforcing knowledge effectively. You can review the content you've saved on a weekly basis and benefit from AI-generated questions to enhance your learning experience.  
  
6. Data Export: Recall offers the flexibility to export your notes to markdown format, ensuring simple interoperability with other tools or platforms. This feature allows you to seamlessly integrate your summarized content with your preferred workflow.  
  
7. Offline Access: All your data is stored locally on your device, enabling you to access it even when you're offline. This ensures that you can review and refer to your saved content anytime, anywhere, without the need for an internet connection.  
  
8. User-Friendly Interface: Recall provides a user-friendly experience, making it easy to install and use the Chrome Browser Extension. The website offers a 2-minute demo from a power user, allowing you to quickly grasp the functionality and benefits of Recall.  
  
9. Pricing and Availability: Recall offers a free version to get started, allowing you to experience the basic features. They also offer Recall Plus, a premium version with additional capabilities. The website provides pricing information and a roadmap for future developments.  
  
Recall simplifies knowledge management by leveraging AI technology to summarize, categorize, and review online content. With its ability to save time, centralize information, automate categorization and connections, support spaced repetition, and provide offline access, Recall empowers users to efficiently organize and learn from the vast amount of information available online.

## Clipboard manager

### [Clibor](https://chigusa-web.com/en/)
**Léger**, disponible **gratuitement** et **ne nécessitant même pas d’installation** (application portable), _Clibor_ est **un utilitaire permettant de gérer l’historique de votre presse-papiers**. Vous pourrez ainsi accéder à vos anciens textes copiés afin de les coller ultérieurement, à n’importe quel moment, même après un redémarrage de votre ordinateur !  
  
Si au clavier vous saisissez régulièrement les mêmes mots et phrases, _Clibor_ permet également de **les enregistrer et de leur attribuer un raccourci clavier**. Pratique pour par exemple insérer dans vos documents des formules de politesse récurrentes !  
  
L’interface de _Clibor_ tout comme son site son assez obsolète et difficile d’accès. Il y a beaucoup de fonctionnalités mais l’UX n’est pas très bonne. Il se lance avec double CTRL. J’aime la fonction FIFO LILO qu’on ne trouve pas sur d’autres clipboard manager.

### [Clipboard History tool by AutoHotkey](https://www.youtube.com/watch?v=_s8HYciVPA0)
- The video introduces a tool called Clip History, which is a paid tool costing around $4 to $5.
- Clip History is a tool that enhances clipboard functionality on Windows by keeping track of copied text and allowing users to filter and manage their clipboard history.
- Users can assign hotkeys to toggle features like showing suggestions, enabling or disabling the tool, and filtering search results.
- The tool auto-suggests previously copied text as users type, making it easier to paste frequently used phrases.
- Users can apply filters to search results, making it easier to find specific text in the clipboard history.
- Clip History is praised for its functionality and convenience, with the video creator recommending viewers to try it out and explore its features.
- The video also mentions that the tool has been extensively tested and is ready for use, with upcoming videos planned to showcase more features and tools.
- The video concludes with a request for viewers to like the video, subscribe for more content, and check out other tutorials on AutoHotkey.
### [1Clipboard](https://1clipboard.io/)
1Clipboard is a universal clipboard managing app that allows you to access your clipboard from any device: it synchronizes copied items across devices, clipboard history tracking, marking favorites for quick access, and searching past clipboard items. The app ensures security by synchronizing through Google Drive. It also has an offline mode for single-computer use and is built with open-source technologies.
- Universal clipboard managing app for accessing clipboard across devices.
- Features include synchronization, clipboard history, favorites, search functionality.
- Security ensured through synchronization via Google Drive.
- Offers offline mode for single-computer use.
- Built with modern open-source technologies like Angular, Electron, and Node.Js.
### [Alternate Tools - Alternate Memo](https://www.alternate-tools.com/pages/c_memo.php?lang=GER) Ditto
Ditto est bien plus qu'un simple gestionnaire de presse-papiers pour Windows. Il constitue une extension intelligente du presse-papiers standard, offrant des fonctionnalités puissantes et une interface conviviale. Avec Ditto, tu as la possibilité de sauvegarder chaque élément copié, que ce soit du texte, des images, de l'HTML, ou d'autres formats personnalisés. Voici un aperçu des caractéristiques et des avantages de Ditto :

**Caractéristiques Clés :**

1. **Interface Conviviale :** Ditto propose une interface facile à utiliser, accessible depuis l'icône de la barre des tâches ou par raccourci clavier global.
2. **Recherche et Collage Faciles :** Tu peux rechercher et coller rapidement des éléments copiés précédemment, facilitant ainsi le travail avec des informations fréquemment utilisées.
3. **Synchronisation entre Ordinateurs :** Ditto permet de synchroniser les presse-papiers de plusieurs ordinateurs, assurant ainsi une continuité entre tes travaux.
4. **Chiffrement des Données :** Les données sont cryptées lorsqu'elles sont envoyées sur le réseau, garantissant la sécurité de tes informations sensibles.
5. **Support Unicode Complet :** Ditto prend en charge l'affichage de caractères étrangers, offrant une expérience multilingue sans problème.

**Utilisation et Cas d'Application :**

* **Gestion Efficace :** Ditto résout le problème des limitations des bacs à copie intégrés dans des logiciels tels que Microsoft Office ou Visual Studio. Contrairement à ces outils, Ditto collecte les copies de toutes les applications, te permettant de rechercher, coller et gérer efficacement toutes tes copies passées.
* **Collaboration Transparente :** Lors de la collaboration avec plusieurs ordinateurs, Ditto garantit que tes presse-papiers restent synchronisés. Cela est particulièrement utile lorsque tu travailles sur plusieurs appareils et que tu as besoin d'accéder rapidement aux mêmes informations.
* **Productivité Améliorée :** La fonction de recherche rapide, la possibilité de coller dans n'importe quelle fenêtre acceptant les entrées copier/coller standard, et la gestion des images avec des miniatures offrent un environnement de travail fluide et améliorent ta productivité quotidienne.
* **Sécurité des Données :** Le chiffrement des données lors des transferts réseau garantit que tes informations sensibles restent confidentielles, ce qui est particulièrement important dans des environnements professionnels.

En conclusion, Ditto est bien plus qu'un simple gestionnaire de presse-papiers. C'est un compagnon intelligent qui simplifie le flux de travail, améliore la collaboration entre appareils et garantit la sécurité des données. Avec une interface conviviale et des fonctionnalités avancées, Ditto se positionne comme un outil essentiel pour toute personne cherchant à optimiser son efficacité au quotidien.

clipboard [Clips | Light. Multiple features. Runs everywhere.](https://infiniticlips.com/features)
## Capture Tasks

### Snippet Manager

snippet manager [Download typedesk](https://www.typedesk.com/download)

[typedesk Canned Responses](https://chromewebstore.google.com/detail/typedesk-canned-responses/haddgijkelkjimhdhgaopfcjhnoipimj)
	Heureusement tu peux changer les caractères de déclenchement dans les parameters because by default all of your shortcuts will launch after %/:.;
	I had way too much conflicts with other apps, or just typing, for example I have a shortcut that is just “c”, but with the default settings it got triggered with typing url with .com, really annoying so I suggested you choose a symbol you rarely use. 
[Download | massCode](https://masscode.io/download/)

[CopyQ](https://hluk.github.io/CopyQ/)

## Capture Screenshots
Prendre des captures d'écran est l'une des tâches les plus courantes, que ce soit sur un PC ou un téléphone. C'est pourquoi tous les systèmes d'exploitation offrent plusieurs façons de prendre des captures d'écran.

Sur le lieu de travail, vous devez prendre des captures d'écran pour partager des idées avec des collègues, obtenir de l'aide d'autres personnes en partageant l'écran d'erreur ou partager rapidement votre progression sur un projet. Certains travaux nécessitent également que vous preniez des captures d'écran. Par exemple, en tant qu'écrivain, je dois prendre des captures d'écran pour m'assurer que les lecteurs visualisent de quoi je parle.

Même pendant votre temps d'écran personnel, il existe de nombreux cas où vous devez prendre des captures d'écran. Par exemple, lors de l'achat de quelque chose sur Facebook, vous devrez peut-être prendre une capture d'écran pour parler au vendeur, vous pouvez capturer une transaction financière pour avoir une preuve, ou même enregistrer une idée de décoration géniale que vous avez trouvée en ligne.

Même s'il est facile de prendre des captures d'écran sous Windows (appuyez simplement sur les boutons Windows + PrtScn), la fonction par défaut est minimale. Il n'y a pas d'outil d'édition robuste disponible, il manque de nombreuses fonctionnalités d'automatisation, et prendre des captures d'écran de différentes manières peut être un problème.

Si vous devez souvent prendre des captures d'écran, il est obligatoire de vous procurer un logiciel de capture d'écran tiers qui réponde à tous vos besoins. Ces outils peuvent vous aider à prendre des captures d'écran de plusieurs manières, à les enregistrer automatiquement à votre emplacement préféré (en ligne/hors ligne) et à les annoter avec de puissants outils d'édition.

Pour vous aider à trouver le bon logiciel de capture d'écran pour Windows, je vais énumérer certains des meilleurs outils de capture d'écran Windows.

### Greenshot

Si vous voulez un outil de capture d'écran simple, gratuit mais puissant, alors [Greenshot](https://getgreenshot.org/) est le meilleur choix, à mon avis. C'est un [application open-source](https://geekflare.com/fr/windows-open-source-apps/) qui fonctionne à partir de la barre des tâches pour vous permettre de prendre rapidement des captures d'écran de plusieurs manières. Vous pouvez prendre la région, la fenêtre active, le plein écran, la dernière région et de nombreuses captures d'écran à l'aide de l'interface utilisateur et des raccourcis clavier.

Vous pouvez le configurer pour enregistrer des captures d'écran directement dans un dossier spécifique ou même les envoyer à un programme. Il existe également une option pour télécharger des captures d'écran sur Imgur dès que vous les prenez. Il est également extrêmement léger sur les ressources et fonctionne à partir de la barre des tâches pour avoir une interférence minimale dans votre travail.

### PicPick

J'ai utilisé [PicPick](https://picpick.app/en/) pendant près de 2 ans avant de passer à Greenshot car j'avais besoin de quelque chose de plus simple. Cependant, si vous voulez un outil de capture d'écran doté d'un éditeur puissant, PicPick surpasse d'un mile les autres outils de capture d'écran. Il propose 8 façons de capturer une capture d'écran, puis l'ouvre dans son éditeur.

L'éditeur offre toutes les fonctionnalités courantes pour éditer des images, notamment des effets, des annotations, une règle de pixels, un redimensionnement/un recadrage, un dessin et bien plus encore. Toutes les captures d'écran prises sont répertoriées dans l'interface PicPick pour être gérées et modifiées, et vous pouvez les partager n'importe où en ligne à l'aide de l'onglet Partager.

PicPick est entièrement gratuit pour un usage personnel mais sans aucun support client. Vous devez acheter le [version payante](https://picpick.app/en/download) pour un usage commercial.

### Snagit

[Snagit](https://geekflare.com/fr/recommends/snagit/) est un outil de capture d'écran et d'enregistrement premium avec un essai gratuit de 15 jours pour tester l'outil. C'est très puissant quand il s'agit de prendre des captures d'écran, de les éditer et de les partager. Il offre jusqu'à 12 façons de prendre des captures d'écran, chaque option ayant des paramètres supplémentaires pour ajuster le comportement.

Les captures d'écran prises s'ouvrent dans l'éditeur Snagit, qui offre toutes les fonctionnalités d'édition nécessaires ainsi qu'une galerie pour afficher toutes vos captures d'écran en un seul endroit. Il contient également une liste de sites Web pour les images et le stockage en nuage où vous pouvez partager vos captures d'écran immédiatement.

Après l'essai gratuit de 15 jours, vous pouvez acheter la dernière version de Snagit pour un paiement unique de 49.99 $.

Si partager les captures d'écran avec d'autres personnes ou sites Web est important pour vous, alors [ShareX](https://getsharex.com/) est le logiciel de capture d'écran que vous voulez. Il dispose de 7 façons de capturer une capture d'écran et vous pouvez également enregistrer des vidéos et des Gifs. Il existe également une fonction de capture automatique pratique qui prend automatiquement des captures d'écran après un intervalle défini.

ShareX propose des menus dédiés pour télécharger vos captures d'écran sur de nombreux services en ligne différents, et vous pouvez gérer leurs comptes directement depuis l'interface ShareX. Vous pouvez également obtenir des liens courts partageables pour un partage facile.

Dans l'ensemble, l'application est hautement personnalisable au point qu'elle peut être un peu écrasante, et il existe également des outils secondaires, comme un [Outil OCR](https://geekflare.com/fr/convert-image-to-text/).

### Lightshot

Comme son nom l'indique, il s'agit d'un logiciel de capture d'écran très minimal, extrêmement léger et facile à utiliser. [LightShot](https://app.prntscr.com/en/) fonctionne à partir de la barre des tâches tout comme Greenshot, mais vous ne pouvez prendre que des captures d'écran de région ou en plein écran.

En plus d'être facile sur les ressources, il vous permet également de télécharger une capture d'écran sur son site Web pour la partager avec n'importe qui en ligne sans avoir besoin de vous connecter. Vous pouvez également vous inscrire pour enregistrer vos captures d'écran en ligne et les gérer.

Même s'il s'agit d'un outil de capture d'écran léger, il offre toujours un éditeur de base pour annoter les images et les partager en ligne.

### ScreenRec

C'est en fait à la fois un outil de capture d'écran et un [enregistreur d'écran](https://geekflare.com/fr/screen-recorder-software/), mais je vais principalement parler de l'outil de capture d'écran. [ScreenRec](https://screenrec.com/) se trouve sur le côté droit de votre écran et vous permet de capturer rapidement une capture d'écran. Cependant, vous devrez sélectionner manuellement une région pour prendre une capture d'écran.

La capture d'écran prise s'ouvrira dans un éditeur minimal où vous pourrez ajouter des flèches et du texte à l'image, puis l'enregistrer. L'outil possède sa propre galerie où vous pouvez afficher et gérer toutes vos captures d'écran et enregistrements. Si vous vous inscrivez pour le compte gratuit, vous pouvez également obtenir des liens privés partageables pour votre capture d'écran et 2 Go de gratuit [stockage cloud](https://geekflare.com/fr/secure-free-cloud-storage/).

Son utilisation est gratuite, mais son stockage en nuage est limité et vous devez vous inscrire pour utiliser les fonctionnalités en ligne.

### Gyazo

[Gyazo](https://gyazo.com/en) fonctionne à la fois comme outil de capture d'écran et comme gestionnaire de photos en ligne. Les captures d'écran que vous prenez sont immédiatement téléchargées sur le site Web de Gyazo sous un lien dédié. Vous pouvez partager ce lien avec n'importe qui pour partager la capture d'écran ou collaborer.

Sa version gratuite n'est bonne que pour prendre des captures d'écran et les partager facilement en ligne. Si vous voulez tout gérer en ligne, vous devez obtenir le [Gyazo Pro](https://gyazo.com/pro) version (3.99 $/mois) qui offre un accès illimité aux captures d'écran enregistrées et aux fonctionnalités d'édition. Vous pouvez également enregistrer des vidéos et des rediffusions de jeux et les gérer en ligne.

### Apowersoft

Je dois mentionner que cet outil vous invite à passer très fréquemment à la version payante. La version payante de [Capture d'écran Apowersoft](https://screenshot.net/) a des caractéristiques uniques qui en valent la peine.

Vous pouvez prendre des captures d'écran de 12 manières différentes, y compris différentes formes pour prendre des captures d'écran. Les captures d'écran s'ouvrent dans son éditeur qui ressemble beaucoup à l'application MS Paint sous Windows, mais il possède des fonctionnalités d'annotation intéressantes.

La fonctionnalité la plus intéressante est le planificateur de tâches, qui vous permet de planifier le moment où l'application prendra automatiquement des captures d'écran. Vous pouvez même le répéter pour prendre des captures d'écran en continu au fil du temps.

### Awesome Screenshot

Si vous prenez principalement des captures d'écran dans votre navigateur et vos applications ou si vous ne souhaitez pas installer la capture d'écran dans Windows lui-même, une extension Chrome peut être meilleure pour vous. [Captures d'écran impressionnant](https://chrome.google.com/webstore/detail/awesome-screenshot-screen/nlipoenfbbikpbjkfpfillcgkoblgpmj?hl=en) est une extension Chrome pour les captures d'écran qui fonctionne à partir de votre navigateur pour prendre des captures d'écran de Chrome et d'autres applications actives.

Vous pouvez utiliser plusieurs façons de prendre des captures d'écran, puis les modifier dans un nouvel onglet avec des outils d'édition de base. Une fois modifiées, les captures d'écran peuvent être partagées en ligne à l'aide de liens intégrés vers des sites Web, ou vous pouvez les télécharger sur le stockage cloud Awesome Screenshot. Le téléchargement vers le stockage cloud Awesome Screenshot vous permet de partager des captures d'écran en privé et de gérer les images en ligne.

Awesome Screenshot vous permet également de prendre des captures d'écran pleine page de pages Web sans faire défiler vers le bas.

Vous devrez vous procurer la version Pro pour accéder à des outils d'édition supplémentaires et utiliser les fonctionnalités de stockage en nuage.

### Nimbus Capture

[Capture de nimbus](https://nimbusweb.me/screenshot.php) est un logiciel de capture d'écran, d'enregistrement vidéo et de création de GIF qui est facile à utiliser et qui fait rapidement le travail. Même si ses fonctionnalités d'enregistrement vidéo et de création de GIF sont limitées par [Abonnement Pro](https://nimbusweb.me/capture-pro/), sa fonction de capture d'écran est en fait gratuite.

Vous pouvez prendre des captures d'écran en région ou en plein écran. Personnellement, j'ai beaucoup aimé son comportement après la capture d'écran, où il ouvre immédiatement un petit widget qui vous permet d'annoter la capture d'écran sur place et de la télécharger/partager. Les captures d'écran peuvent également être téléchargées sur le compte en ligne Nimbus Capture, où vous pouvez ajouter des notes et les gérer.

### Screenpresso

[Screenpresso](https://secure.2checkout.com/affiliate.php?ACCOUNT=LEARNPUL&AFFILIATE=120460&PATH=http%3A%2F%2Fwww.screenpresso.com%3FAFFILIATE%3D120460) ajoute un petit widget en haut de votre écran sur lequel vous pouvez passer votre souris pour le faire apparaître. Vous pouvez utiliser ce widget pour prendre des captures d'écran régulières et même des captures d'écran différées ou des captures d'écran défilantes. Vous pouvez également utiliser un outil de sélection de couleurs à partir du même widget et utiliser l'OCR sur l'une des captures d'écran.

Si vous accédez aux paramètres de Screenpresso, il existe une fonctionnalité vraiment intéressante pour ajouter automatiquement des effets prédéfinis, un filigrane et redimensionner les captures d'écran dès qu'elles sont prises. Vous pouvez même modifier l'arrière-plan du bureau uniquement lorsque la capture d'écran est prise.

La plupart des fonctionnalités liées aux captures d'écran sont gratuites, mais l'OCR et l'enregistrement vidéo sans filigrane sont disponibles dans la version Pro.

#### Derniers mots 👨‍🏫

j'ai un dédié [outil de retouche photo](https://geekflare.com/fr/best-ai-powered-photo-editor/) que j'aime vraiment, alors je m'en tiens à Greenshot pour tous mes besoins en matière de capture d'écran, car il est plus facile à utiliser et enregistre automatiquement les captures d'écran au fur et à mesure que je les prends. Si je n'avais pas d'éditeur d'image dédié, j'utiliserais certainement PicPick car je trouve que son outil de capture d'écran et d'édition est parmi les meilleurs logiciels de capture d'écran gratuits.

Vous recherchez uniquement des outils intégrés ? Voici [6 façons de prendre des captures d'écran dans Windows 11](https://geekflare.com/fr/screenshot-on-windows-11/).
## 
[Taking a screenshot on Windows 10](https://screenrec.com/screenshot-tool/how-to-screenshot-on-pc/) can be a bit frustrating. Granted, there are a few tricks you can use…

For example, you can press the Print Screen key and the Windows key which will save a screenshot directly to your Pictures folder. That’s nice, but when it comes to [how to edit and annotate a screenshot](https://screenrec.com/screenshot-tool/how-to-screenshot-on-pc/) , you’re on your own. Your other option is the Windows 10 Snipping Tool which is simple but, sometimes, too basic.

There’s got to be more to PC screen capturing than that, right?

Right. Actually, there is such an abundance of Windows 10 screenshot tools that you can easily feel overwhelmed when you try to pick just one. To help you save time, we’ve rounded up the top 7 print screen software (free and easy).

And, if you’re too busy to read a top 7, you can watch our top 3 video below.

## 1. [Screenrec](https://screenrec.com/)

### Overview

If you’re looking for a way to take an **instant screenshot on Windows** , you’ll love ScreenRec. Besides being the easiest and fastest screenshot program on this list, ScreenRec is actually full-featured free screen capture software. This means that you can also use it to [record your PC screen](https://screenrec.com/screen-recorder/how-to-record-your-computer-screen-windows-10/) .

### Why It’s Awesome

There is a single hotkey to remember (Alt + S) to either screengrab or record and you can add annotations to your screenshots with a few mouse clicks.

But what’s best about ScreenRec is the ability to **share your screen captures instantly and securely** (via private URL). As soon as you’re done taking a screenshot or recording your desktop, a sharing link is copied to your clipboard. You can paste it in an email, a private message or wherever you like.

**Press Alt + S -> Capture -> Grab sharing link**. Screenrec is as simple as that.

### Who’s It For

Anyone can benefit from using ScreenRec. Yet, business people stand to gain a lot in productivity when implementing ScreenRec into their daily routine. They can [send video email](https://screenrec.com/business-communication-app/how-to-send-video-email/) , [create tutorial videos](https://screenrec.com/elearning-software/create-training-videos/) , record Skype/Zoom meetings.

## 2. Windows Snipping Tool

### Overview

We know. We said we’d venture beyond the Windows Snipping Tool, but Microsoft has made some changes to the built-in screenshot utility that are worth mentioning. If you want to avoid this program at all costs, continue reading or check out our list of [Snipping tool alternatives](https://screenrec.com/screenshot-tool/free-snipping-tool-alternatives/)

### Why It’s Awesome

In the October 2018 update, Snip & Sketch replaced the Windows Snipping Tool which came with previous versions of Windows. The keyboard shortcut is Windows + Shift + S.

The annotation options in Snip & Sketch include **more colors, writing tools, and even a ruler and a protractor**. Another plus is that you can use Snip & Sketch on a Windows 10 tablet. Actually, it’s somewhat easier to use Snip & Sketch on a tablet than on a PC because it’s optimized for doodling rather than annotating with a mouse. But, if you need more editing options, you can open the snip in another app.

### Who’s It For

Immediate sharing is still a pain in the butt, so we wouldn’t recommend this screenshot program for those who need easy and secure access to their captures. But, if you’re looking for a quick screen snip (especially if you want to do a free-form selection), this app will work just fine.

## 3. [Lightshot](https://app.prntscr.com/en/index.html)

### Overview

Offered by [PrntScr.com](http://PrntScr.com), Lightshot is a screenshot app for PC that allows you to take quick snaps and edit them online or within the app.

### Why It’s Awesome

With Lightshot, you have access to an **online image editing tools** by clicking a single button and uploading your images to their servers. Some people may find this problematic as there is no way to guarantee the privacy of your captures. Nonetheless, once your images are uploaded (and you’ve created an account), you have full access to your online gallery and Lightshot’s editor.

### Who’s It For

Lightshot is for anyone looking to edit/share their screen snapshots publicly. Due to the general lack of security, we wouldn’t recommend uploading images that contain sensitive information. So, Lightshot may not be ideal for business people and companies.

## 4. [Greenshot](https://getgreenshot.org/)

### Overview

This open source screenshot app for Windows is perfectly suited for productivity while keeping things incredibly simple. Much like Gadwin Printscreen, Greenshot aims to make it easier to take screenshots and save them using the PrtScn key.

### Why It’s Awesome

Greenshot requires no prior knowledge. In fact, it may be **the most basic screenshot program available**. And, by “basic” we mean this screen grab application has all of the necessary features (hotkey functions, annotation, built-in editor, upload/sharing options) without bells and whistles.

### Who’s It For

If you just need to take a screenshot on Windows 10 and you don’t need a bunch of features, Greenshot is a good option. You can upload your captured images to file sharing sites or save them locally. Since Greenshot isn’t overly fancy, taking, editing, and sharing your screenshots is a breeze, saving valuable time.

## 5. [ShareX](https://getsharex.com/)

### Overview

Ahh ShareX, the one with the most options… It does everything from capturing the active window or the active monitor, to uploading your content to dozens of predefined sites.

### Why It’s Awesome

Like ScreenRec, ShareX has the ability to not only capture screenshots but also to record your screen. However, the **long list of uploading options** is worth mentioning. Pretty much every social media and file sharing site you can think of is available in the ShareX app. It certainly isn’t private sharing, but it is convenient.

### Who’s It For

ShareX can be used by anyone who isn’t afraid to browse a ton of options and menus. Those who love to (or need to) share via social media will love this app.

## 6. [PicPick](https://picpick.app/)

### Overview

A buffet of features in a single app? Yes, please! PicPick is so full of various features that it’s more of a [photo editor](https://fixthephoto.com/best-photo-editing-software-for-pc.html) than a screenshot app. With its ability to capture scrolling screenshots when you need to snip entire webpages, this app is hard to ignore.

### Why It’s Awesome

PicPick will require a bit of exploration first, but with **a list of edit tools almost as big as Photoshop’s**, it’s worth giving it a once-over. When you’re done editing your screenshot, you can save it as an image or upload it to a public sharing site such as [imageshack.us](http://imageshack.us). What’s more interesting about PicPick is that it is portable. You can move this print screen program onto a jump drive and open it up anywhere without needing to install it.

### Who’s It For

PicPick is best suited for those who are looking for an advanced editor and a screen grab app rolled into one.

## 7. [Awesome Screenshot](https://chrome.google.com/webstore/detail/awesome-screenshot-screen/nlipoenfbbikpbjkfpfillcgkoblgpmj?hl=en)

### Overview

Awesome Screenshot is a browser extension that gives you everything an installed screenshot app offers. The downside? It could make your computer run slow.

### Why It’s Awesome

Forget the downside for a moment. The upside is that, as long as you are signed in, you can use the app on any PC and **upload your screen captures to Google Drive**. This screenshot software can also capture web pages. Keep in mind, though, that you are allowed only 30 images per project and only 30 seconds of screen recording time.

### Who’s It For

Anyone who is constantly on the go can benefit from using Awesome Screenshot. As long as you can log in to your personalized browser, you’re good to go.
## Capture Screen Recordings

[Open Broadcaster Software | OBS](https://obsproject.com/fr)
	Résumé

OBS Studio est un logiciel gratuit et open source permettant d’enregistrer des vidéos et de diffuser en direct sur Windows, Mac ou Linux.

Points clés
OBS Studio offre des fonctionnalités avancées telles que la capture et le mixage audio-vidéo en temps réel, la création de scènes à partir de différentes sources et des options de configuration puissantes.
Il permet également de créer des productions professionnelles grâce à des transitions personnalisables, des raccourcis clavier personnalisés et un mode studio pour prévisualiser les scènes avant de les diffuser.
OBS Studio est également adapté au travail collaboratif grâce à une API permettant l’installation de plugins et l’écriture de scripts personnalisés.
Il prend en charge plusieurs plates-formes de streaming et offre des ressources supplémentaires pour améliorer l’expérience de streaming.
FAQ
Quelles sont les fonctionnalités principales d’OBS Studio ?
OBS Studio offre des fonctionnalités avancées telles que la capture et le mixage audio-vidéo en temps réel, la création de scènes à partir de différentes sources et des options de configuration puissantes.
Comment puis-je prévisualiser mes scènes avant de les diffuser ?
Le mode studio d’OBS Studio permet de prévisualiser les scènes et les sources avant de les inclure dans la diffusion en direct.
Est-il possible de personnaliser OBS Studio avec des plugins et des scripts ?
Oui, OBS Studio dispose d’une API performante permettant l’installation de plugins et l’écriture de scripts personnalisés pour répondre à des besoins spécifiques.
#### [Game Bar on Windows](https://support.xbox.com/en-GB/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)
*Native Windows feature*
	- **Game Recording and Broadcasting:** You can use the Game Bar to record your gameplay or stream it live to platforms like Twitch or YouTube, so it’s useable to record the screen too, but it doesn’t work on Explorer and Desktop 😒
	- **Screenshots:** You can take screenshots
	- **Audio Controls:** You can adjust your microphone and speaker volumes, and even record audio commentary while you're recording gameplay.
	- **Keyboard Shortcuts:** The Game Bar can be accessed using the default keyboard shortcut "Windows key + G". You can also customize your own shortcuts for specific actions.
	- **Widgets:** The Game Bar includes several widgets, like a clock, a calendar, and a performance panel, that you can use without leaving your game.

**HotKey**
🪟+G = Game Bar
🪟+Alt+PrtScrn = Capture Screen
🪟+Alt+G = Record last 30 seconds
🪟+Alt+R = Start/Stop recording
🪟+Alt+M = Activate/Deactivate microphone
🪟+Alt+B = Activate/Deactivate HDR 
You can also [improve the video quality when recording the videos](https://www.softwareok.com/?seite=faq-Windows-11&faq=194)
	
I don’t use it because it’s not reliable enough in my testing, the mic sound isn’t always recorded or in sync, and it doesn’t work on the explorer and desktop 🙄 it’s made for Games.

#### [Screenity - Capture & Annotation d'écran](https://chromewebstore.google.com/detail/screenity-capture-annotat/kbbdabhdfibnancpjfhlkhafgdilcnji)
*Chrome extension · Free · Open-Source*
	🎥 Enregistrez en illimité votre onglet, une zone spécifique, le bureau, n'importe quelle application ou caméra
	🎙️ Enregistrez votre microphone ou l'audio interne, et utilisez des fonctionnalités telles que la fonction "push to talk"
	✏️ Annotez en dessinant n'importe où sur l'écran, en ajoutant du texte, des flèches, des formes, et bien plus encore
	✨ Utilisez des arrière-plans de caméra alimentés par l'IA pour améliorer vos enregistrements
	🔎 Faites un zoom en douceur dans vos enregistrements pour vous concentrer sur des zones spécifiques
	🪄 Floutez tout contenu sensible de n'importe quelle page pour le garder privé
	✂️ Silenciez, supprimez ou ajoutez de l'audio, ou recadrez vos enregistrements avec un éditeur complet
	👀 Mettez en évidence vos clics et le curseur, et passez en mode projecteur
	⏱️ Configurez des alarmes pour arrêter automatiquement votre enregistrement
	💾 Exportez au format mp4, gif et webm, ou enregistrez la vidéo directement sur Google Drive pour partager un lien
	⚙️ Définissez un compte à rebours, masquez des parties de l'interface utilisateur ou déplacez-les où vous le souhaitez
	🔒 Vous êtes le seul à pouvoir voir vos vidéos, nous ne collectons pas vos données. Vous pouvez même l'utiliser hors ligne !
	💙 Pas de limites, créez autant de vidéos que vous le souhaitez, aussi longtemps que vous le souhaitez
	... et bien plus encore - tout cela gratuitement et sans besoin de vous connecter !

## Scrappi
Meet **Scrappi**, your ultimate digital companion for collecting, creating, and collaborating online. It's your one-stop app for capturing websites, screenshots, notes, and images effortlessly. Ideal for researchers, creatives, or anyone collecting digital content, Scrappi helps you retain what matters most. Scrap it and Never forget it.

📌 Capture with ease: Quickly save any digital content. 🎨 Organize content: Arrange your digital collections into meaningful stories. 👥 Collaborate effortlessly: Research and collect with others in real-time. 🚀 Start for free: ain't nothing better than free. It's more than just bookmarking - it's a journey for organizing digital chaos.

Free full access with no limits up to 5GB of Scraps
### Sourcer
[GigaBrain - AI Companion for Reddit](https://chromewebstore.google.com/detail/gigabrain-ai-companion-fo/kofkhnkdmpbngifdgbjeedlppjilcaei?hl=en)
[GitHub - lextrack/Simple-Screen-Recorder: Simple and easy-to-use screen recorder for Windows.](https://github.com/lextrack/Simple-Screen-Recorder)
	Disponible **gratuitement**, **en français** et **ne nécessitant même pas d’installation** (application portable), _Simple Screen Recorder_ est un outil vous permettant d’enregistrer votre activité à l’écran ainsi que l’audio. Concrètement, avec _Simple Screen Recorder_ **vous réalisez un véritable enregistrement vidéo de ce qui est diffusé sur votre écran d’ordinateur**. Idéal pour faire une vidéo de démonstration, un tutoriel, etc.  
	Pour les novices, il suffit simplement de cliquer sur le bouton **Démarrer l’enregistrement** (ou d’utiliser le raccourci clavier **F9**) pour débuter l’enregistrement puis de cliquer sur le bouton **Arrêter l’enregistrement** (ou d’utiliser le même raccourci clavier **F9**) pour terminer l’enregistrement et le sauvegarder.  
	Pour les plus expérimentés, de nombreux réglages vous permettent de peaufiner votre enregistrement : sélection de l’écran, format de la vidéo (AVI, MKV), fréquence d’images, encodeur, méthode d’enregistrement audio, etc.
[Say more, meet less, with Dropbox Capture](https://www.dropbox.com/capture)
### Video info capture
  
Video as a learning medium is both engaging and high-bandwidth, combining visuals, sounds, and voices that impress information into us in ways that text alone can’t. Podcasts also give us access to the minds and thinking of modern experts who often aren’t writing or publishing articles.

There are some challenges to learning from this medium though, such as it being harder to skim and review/revisit excerpts. Highlighting is a common knowledge capture practice for books and articles, but there’s no equivalent for video. It’s also harder to control the pace while you’re absorbing information - a video keeps rolling by default and “turns the page” on you, even if you need to stop to digest the point you just heard.

For these reasons, I wanted a dedicated experience for learning from videos and audio.

The core UX needed was to fix the continuous toggling back and forth between a rolling video and your notes. I experimented with bringing the note-taking interface to YouTube, but eventually realized the best experience was to embed the media directly into your notes. This gave the added benefits of a focused learning environment (the comments section and recommended feed aren’t exactly conducive to that), and the ability to browse your knowledge base to make connections to the new thing you’re learning.

It also enabled some cool UX patterns because of the integrated environment, such as being able to seamlessly control the video while note-taking with hotkeys, and inserting timestamps to record and replay key moments.


### Media Operations
[History - The picture reduction app for Windows OS](https://www.softwareok.com/?seite=Freeware/PhotoResizerOK/History)
[Alternate Tools - Alternate Quick Audio](https://www.alternate-tools.com/pages/c_quickaudio.php?lang=GER)
A simple program to convert audio files. The program is freeware. With the program it is possible to convert audio files (and also some types of video files) to other audio formats (e.g. from WAV to MP3 or from MP4 to WAV).
### Text Operations
VSCODE POUR LES fichiers text

### Capture

* Downloading Files
	* bitorrent
	* [moshfeu/y2mp3: An Electron app to download youtube playlist](https://github.com/moshfeu/y2mp3)
	* most Chrome extension won't work reliably and be freemiums so I recommend [JDownloader.org - Official Homepage](https://jdownloader.org/fr/download/index),  a free, [open-source](https://support.jdownloader.org/Knowledgebase/Article/View/setup-ide-eclipse) download management tool with a [huge community](https://board.jdownloader.org/) that makes downloading very easy with rules, auto-extract archives and much more
	* for torrent I use [qBittorrent Official Website](https://www.qbittorrent.org/download) which is very lightweight. You can use [put.io: Stash your digital goods here.](https://put.io/) to hide your identity while downloading content.
* Highlighting
	* [Highlights - Highlighter and Web Clipper](https://chrome.google.com/webstore/detail/highlights-highlighter-an/fiajhjomgpnlefcbdhfghnbhpillkklb) Surligne Avec Options de Marquage et de Recherche, Synchronisation, Notes et Exportation Vers Titter et ROAM [https://youtu.be/euBrnK8Ma6Y](https://youtu.be/euBrnK8Ma6Y)
	* Hypothèse - Annotation Web et PDF](https://chrome.google.com/webstore/detail/hypothesis-web-pdf-annota/bjfhmglciegochdpefhhlphglcehbmek)
	* [Surligneur de pages Web - Chrome Web Store](https://chrome.google.com/webstore/detail/web-page-highlighter/poemphopblfbpoaoglhbljbjfodofmpa) : Web Page Highlighter Pour Google Chrome Permet à Un Utilisateur de Mettre En Évidence Un Fragment de Texte Sélectionné Sur Une Page Web et de Générer Une URL Qui Défile Automatiquement Vers la Partie Mise En Évidence de la Page Web.
	* [Web Highlights - PDF & Web Highlighter](https://chromewebstore.google.com/detail/web-highlights-pdf-web-hi/hldjnlbobkdkghfidgoecgmklcemanhm): Highlight websites, take notes, and save websites as bookmarks. Choose between offline mode or seamless sync with our web app at web-highlights.com. Enjoy efficient access to your research, highlights, notes, and bookmarks with tags and full-text search. Receive email reminders, daily highlights, and easily export to Notion, Obsidian, and more for enhanced learning and productivity.
* Copy text & urls & images
	* [Copy text with Alt-Click](https://chromewebstore.google.com/detail/copy-text-with-alt-click/obhagoegpnbklgknnmbglghkfdidegkl)
	* [Auto Copy](https://chromewebstore.google.com/detail/auto-copy/bijpdibkloghppkbmhcklkogpjaenfkg)
	* [Autoriser la copie - activer le clic droit](https://chromewebstore.google.com/detail/autoriser-la-copie-active/mmpljcghnbpkokhbkmfdmoagllopfmlm)
	* [Rich URL](https://chromewebstore.google.com/detail/rich-url/bkjdcppkdgccnhjibfhlhmeiafnjfamk)
		* [COPY RICH URL](https://chromewebstore.google.com/detail/copy-rich-url/lijjekihhdocbcginjcbipabahcjpjoe)
		* Si Tu Ne Veux Pas T'embêter Avec les Personnalisations et Que Tu Veux Juste Copier L'url En Markdown, Utilise Celle-ci : [Copy Title and Url as Markdown Style - Chrome Web Store](https://chrome.google.com/webstore/detail/copy-title-and-url-as-mar/fpmbiocnfbjpajgeaicmnjnnokmkehil)
	* if a website doesn't allow copy you can use [Autoriser la copie - activer le clic droit](https://chromewebstore.google.com/detail/autoriser-la-copie-active/mmpljcghnbpkokhbkmfdmoagllopfmlm) to bypass it
* Prendre Une Capture D'écran de la zone/de la Page Entière
	* Vivaldi does it natively: [Capture a screenshot in Vivaldi](https://help.vivaldi.com/desktop/tools/capture-a-screenshot/)
	* I use [ShareX](https://getsharex.com/) that also does video and GIF capture
		What is OCR?
		Optical Character Recognition (OCR) is the process that converts an image of text into a machine-readable text format.
		
		How to install more OCR languages?
		In Windows, open the "Language settings" window. (You can search it by pressing Win key)
		In "Preferred languages" section, press "Add a language" button.
		Choose a language that you would like to install, and press "Next" button.
		Uncheck all "Optional language features" as we don't need any of them for OCR to work.
		Make sure that under "Required language features" it lists "Optical character recognition", if it's not listed there then your language doesn't support this feature, and press "Install" button.
		Wait for Windows to install the language we choose in the background.
		After the language is installed, ShareX will include it in language drop down menu next time OCR window is opened.
	* You can use [Lightshot](https://app.prntscr.com/en/index.html) to capture, edit and uploac screenshots
OCR

Alternatives
	[Capture2Text](https://capture2text.sourceforge.net/)



## Research
### Afforai
Using the Semantic Scholar API, researchers can supplement Afforai AI research assistant verified knowledge from a 128 million peer-reviewed research papers database: [https://www.semanticscholar.org/api-gallery/afforai](https://www.semanticscholar.org/api-gallery/afforai)  

Afforai is now featured on the Semantic Scholar Gallery. This showcases innovative applications of the Semantic Scholar APIs, highlighting how partners like us are contributing to the mission of accelerating scientific discovery.
### [Connected Papers](https://webcurate.co/p/connected-papers)
Connected Papers is a platform that allows you to discover and explore academic papers in a connected and visual manner. By visualizing the relationships between papers, it helps you navigate through the academic literature more effectively.
- **Paper Graph**: Explore a visual graph of interconnected academic papers, representing their relationships and citations.
- **Paper Recommendations**: Receive personalized recommendations based on the papers you're interested in.
- **Search Functionality**: Search for specific papers, authors, or keywords to find relevant research.
- **Paper Collections**: Create and save collections of papers for easy reference and organization.
- **Collaboration**: Share and collaborate on paper collections with colleagues and peers.
- **Export and Citations**: Export papers and their citation data in various formats for further analysis.

Use Cases:
- **Literature Review**: Conduct comprehensive literature reviews by visualizing the connections and relationships between papers in your research field.
- **Research Exploration**: Discover new papers and build upon existing knowledge by exploring related works and citations.
- **Collaboration**: Collaborate with colleagues and peers by sharing and discussing paper collections.
- **Personal Knowledge Management**: Organize and save papers of interest for future reference and quick access.

How to use it?
1. **Enable JavaScript**: Make sure JavaScript is enabled in your browser to use Connected Papers effectively.
2. **Search or Explore**: Use the search bar to find specific papers or topics of interest, or explore the visual graph to discover interconnected papers.
3. **Navigate the Paper Graph**: Click on nodes to view papers, their titles, and authors. Use zoom and drag functionalities to navigate the graph.
4. **Save and Organize**: Create paper collections and save papers for easy access and organization.
5. **Collaborate**: Share paper collections with colleagues and peers for collaboration and discussion.
6. **Export and Analyze**: Export papers and their citation data in various formats to further analyze and integrate with other tools.
Connected Papers is a powerful tool for academic researchers, allowing you to explore and navigate through the vast landscape of academic papers in a visual and connected manner.  
  
By uncovering the relationships between papers, it facilitates comprehensive literature reviews, enables discovery of new research, and promotes collaboration within the academic community.

### [Jenni AI](https://jenni.ai/)
Jenni AI is an AI-powered text editor that helps you write, edit, and cite with confidence, saving you hours on your research papers.
- **Auto In-Text Citations**: Jenni automatically generates accurate in-text citations in APA, MLA, IEEE, Chicago, or Harvard style, based on the latest research and your uploaded PDFs.
- **10x Writing Speed**: With AI autocomplete, Jenni assists you in overcoming writer's block and provides suggestions to expand your notes into full paragraphs, enabling you to write faster.
- **Plagiarism Checker**: Ensure the originality of your content with the built-in plagiarism checker, trusted by universities and businesses worldwide.
- **Paraphrase & Rewrite**: Jenni can paraphrase any text in any tone, allowing you to customize and rewrite internet content to suit your needs.
- **Source-Based Generation**: Bring your research papers to life by generating content based on your saved sources, making it easier to cite and reference.
- **AI Chat Assistant**: Quickly understand and summarize your research papers using Jenni's AI chat assistant, which helps you navigate and extract key information.
- **Outline Builder**: Enter your prompt, and Jenni provides a list of section headings, ready for you to flesh out and structure your paper.
- **Multilingual Support**: Jenni can generate content in US or British English, Spanish, German, French, or Chinese, catering to a wide range of language needs.
- **Research Library**: Save and manage your research papers in your library, making it easy to cite and reference them in any document.
- **Export Options**: Export your drafts to LaTeX, .docx, or HTML formats without losing any formatting.
Use Cases:
- **Essays**: Save time writing essays with the AI essay writing tool.
- **Literature Reviews**: Discover, write, and cite relevant research for comprehensive literature reviews.
- **Research Papers**: Polish your writing and increase your submission success rate for research papers.
- **Personal Statements**: Create compelling college motivation letters and personal statements.
- **Blog Posts**: Write blogs and articles faster with the assistance of AI.
- **Speeches**: Craft compelling speeches in less time, ensuring impactful delivery.

Jenni AI is your ultimate research paper companion, empowering you to supercharge your writing process. With its AI-powered features like auto in-text citations, autocomplete, and plagiarism checker, Jenni ensures accurate and efficient writing. The ability to paraphrase, generate content from sources, and provide multilingual support further enhances its capabilities.
### [Synth | The Research Browser](https://synth.app/)
Synth is an innovative browser designed specifically for research purposes. With Synth, users can browse the web smartly and efficiently, enabling them to get things done quickly.  
  
The browser offers powerful features and tools that enhance the research experience, allowing users to gather information, organize their findings, and collaborate seamlessly.  
  
From its intelligent search capabilities to its intuitive interface, Synth is the ideal browser for researchers who are looking for a streamlined and productive browsing experience.

### [ResearchGate | Find and share research](https://www.researchgate.net/)
ResearchGate is a platform that allows you to discover scientific knowledge, stay connected to the world of science, and collaborate with researchers from various fields. It provides access to over 160 million publication pages, helping you stay up to date with the latest research in your field.

- **Discover Research**: Access over 160 million publication pages to explore scientific knowledge across various disciplines.
- **Stay Connected**: Connect with your scientific community, collaborate with peers, and get the support you need to advance your career.
- **Topic Pages**: Visit topic-specific pages to explore research in engineering, mathematics, biology, computer science, climate change, medicine, physics, social science, astrophysics, and chemistry.
- **Measure Your Impact**: Get detailed statistics on who has been reading your work and keep track of your citations to understand your research impact.
- **ResearchGate Business Solutions**: Scientific Recruitment allows you to hire qualified researchers and build the best teams in science. Marketing Solutions help you grow your brand's impact in the scientific community.
Use Cases:
- **Researchers**: Access a vast repository of research papers and publications, connect with peers, and collaborate on projects.
- **Academics**: Stay up to date with the latest research in your field, share your own research findings, and connect with other researchers worldwide.
- **Scientists**: Explore research from various disciplines, join discussions, and contribute to the scientific community.
- **Industry Professionals**: Access scientific knowledge relevant to your field, connect with experts, and stay informed about advancements.

How to use it?
1. **Join for Free**: Sign up on ResearchGate to create your profile and gain access to the platform's features.
2. **Discover Research**: Use the search function to find research papers, topics, or specific researchers.
3. **Connect and Collaborate**: Engage with the scientific community by connecting with researchers, joining discussions, and sharing your own research.
4. **Measure Impact**: Track the impact of your research by monitoring readership and citation statistics.
5. **Explore Business Solutions**: If you are an organization, explore ResearchGate's business solutions for scientific recruitment and marketing.


ResearchGate is a valuable platform for researchers, academics, scientists, and industry professionals looking to access scientific knowledge, collaborate with peers, and stay up to date with the latest research.  
  
Joining ResearchGate allows you to connect with a global scientific community, measure the impact of your research, and contribute to the advancement of knowledge in your field.

### [Consensus: AI Search Engine for Research](https://consensus.app/)

Consensus is an AI search engine designed to help users find insights in research papers. It offers extensive coverage with access to over 200 million scientific papers, trustworthy results tied to actual studies, and instant analysis using advanced AI models like GPT4. The platform is utilized by researchers, students, professionals, and consumers seeking reliable research information.
- Consensus is an AI search engine for research that uses AI to analyze and summarize insights from research papers.
- It provides access to over 200 million scientific papers, ensuring extensive coverage without needing specific keywords.
- The results provided by Consensus are trustworthy, linked to actual studies, and free from advertisements.
- The platform leverages advanced AI models like GPT4 for instant analysis and summarization of research findings.
- Consensus is used by a diverse range of users, including researchers, students, doctors, professionals, and evidence-conscious consumers, for conducting effective research.
### [Elicit: The AI Research Assistant](https://elicit.com/)
Elicit is a powerful tool that allows you to automate time-consuming research tasks associated with analyzing research papers. It provides features such as summarizing papers, extracting data, and synthesizing findings, all at an incredibly fast pace.
- **Search for research papers**: Ask a research question and get a list of relevant papers from Elicit's database of 200 million papers.
- **One-sentence abstract summaries**: Quickly get a concise summary of papers to understand their main points.
- **Select relevant papers and find similar ones**: Identify papers that are relevant to your research and discover more papers similar to them.
- **Extract details into an organized table**: Easily extract important information from papers and organize it in a table format.
- **Find themes and concepts across multiple papers**: Analyze and synthesize themes and concepts from a large number of papers.
Use Cases:
- **Literature review acceleration**: Speed up the process of reviewing academic literature by quickly finding relevant papers.
- **Data extraction automation**: Save time and effort by automatically extracting data from research papers.
- **Systematic reviews and meta-analyses**: Automate the process of conducting systematic reviews and meta-analyses.
- **Exploring unfamiliar literature**: Discover new research areas by using Elicit as a front page for exploring unfamiliar literature.
How to use it?
1. Sign up for an account on Elicit.
2. Upload your own PDFs or search for papers within Elicit's database.
3. Utilize the various features such as summarizing papers, extracting data, and synthesizing findings.
4. Save and review your results for future reference.

Elicit provides 2 pricing plans. Here is an overview of each:  
Basic (Free)**: Explore Elicit's features for free, with limitations on credits, exporting results, and buying more credits.
**Plus ($10/month, billed annually)**: Access additional features such as buying more credits, exporting results to CSV and BIB formats, high accuracy mode, and utilizing information from tables in papers.
**Enterprise and Institutions (Custom pricing)**: Tailored plans for teams, companies, and educational institutions, including as many credits as needed, sharing credits across the organization, invoice-based billing, and top priority customer support.
  

Elicit is a revolutionary tool that empowers researchers to analyze research papers with superhuman speed. By automating tasks like summarizing papers, extracting data, and synthesizing findings, Elicit saves researchers significant time and effort.

### [Demo of Custom GPTs » JesseZhang.org](https://jessezhang.org/llmdemo)
Demo of PapersGPT is an interactive tool that allows you to feed various data sources into GPT (Generative Pre-trained Transformer) to provide it with deep customized knowledge. By connecting a data source on the left, you can ask questions and receive informative responses.

- **Data Source Integration**: You can connect different data sources to GPT, enabling it to access a wide range of information for generating responses.
- **Question-Answering Capability**: PapersGPT can answer questions based on the knowledge it has acquired from the connected data sources.
- **Scientific Papers Examples**: The tool is specifically designed to handle scientific papers and can provide insightful responses related to various scientific domains.
- **AI Transformers**: PapersGPT leverages AI transformers to process and understand complex information from the connected data sources.
- **Quantum Computing**: You can explore and ask questions about quantum computing, a cutting-edge field, and get detailed explanations.
- **Reinforcement Learning**: The tool has knowledge about reinforcement learning techniques and can provide insights and explanations related to this field.
- **DeepMind Publications**: PapersGPT has access to publications from DeepMind, a prominent AI research organization, allowing you to inquire about their work.
- **Integration with PubMed Central (PMC)**: You can connect PMC to PapersGPT and ask questions about scientific articles available on the platform.

Use Cases:
- **Research and Study**: Researchers and students can utilize PapersGPT to gain quick insights and explanations on various scientific topics, papers, and fields of study.
- **Knowledge Exploration**: Users interested in AI, quantum computing, and reinforcement learning can use the tool to delve deeper into these subjects and receive informative responses.
- **Reference and Verification**: PapersGPT can be used to cross-reference information, verify scientific claims, and gain a better understanding of complex concepts.

How to use it?
1. **Visit the website**: Go to jessezhang.org/llmdemo.
2. **Connect a Data Source**: Choose a data source from the options on the left-hand side to provide GPT with relevant knowledge.
3. **Ask Questions**: Type in your questions related to the selected data source, scientific papers, AI, quantum computing, reinforcement learning, or DeepMind publications.
4. **Receive Responses**: PapersGPT will generate informative responses based on the knowledge it has acquired from the connected data sources.
5. **Explore Different Topics**: Feel free to explore various scientific domains and subjects by asking relevant questions.

Demo of PapersGPT is an interactive tool that empowers you with deep customized knowledge. By connecting different data sources and leveraging GPT's capabilities, you can ask questions and receive informative responses on scientific topics, AI, quantum computing, reinforcement learning, and DeepMind publications.

### [Upword - AI powered research and knowledge assistant](https://www.upword.ai/)
Upword is an advanced AI research assistant that empowers users to process information at an accelerated pace and expand their knowledge. Built on the powerful GPT-4 technology, Upword offers personalized AI capabilities tailored to individual users.  
  
With Upword, you can search, retrieve, and organize textual data with ease, as if you have a personalized ChatGPT for your knowledge needs.  
  
The AI copilot feature enables you to work collaboratively with AI, allowing you to generate key notes, highlights, simplified text, translations, and more.  
  
Transform your work into online documents such as blogs, reports, and essays effortlessly. Upword enhances your research efficiency, reduces reading time significantly, and enables seamless knowledge production and sharing.

### [Cognosys](https://www.cognosys.ai/)

Cognosys is an intelligent assistant platform that leverages AI to supercharge productivity and streamline workflows. It offers integrations to help individuals and teams automate tasks, organize emails, generate reports, and more.
- **Workflow Automation**: Schedule or set triggers for workflows to run autonomously, saving time and effort.
- **Email Management**: Organize and label emails, create summaries, and move them to project folders based on specific criteria.
- **Notion Integration**: Create and manage workflows using Notion documents, streamlining collaboration and information sharing.
- **Market Research**: Generate market research reports on specific topics of interest.
- **Document Analysis**: Analyze and extract information from documents for better insights and decision-making.
- **Trip Planning**: Plan itineraries and organize trips with ease.
- **Multitasking**: Execute multiple workflows in parallel without the need for separate chats or interactions.

Use Cases:
- **Professionals**: Cognosys helps professionals automate repetitive tasks, manage emails efficiently, and generate reports, enabling them to focus on more strategic and high-value activities.
- **Teams and Projects**: Cognosys provides collaboration tools and integrations with popular platforms like Notion, allowing teams to streamline workflows, organize documents, and enhance productivity.
- **Market Researchers**: Cognosys assists market researchers in generating comprehensive reports by automating data collection, analysis, and report generation processes.
- **Travelers**: With its trip planning features, Cognosys helps travelers create detailed itineraries, find attractions, and organize their trips effectively.
- **Document Analysis**: Cognosys enables users to extract insights and analyze information from various types of documents, saving time and effort in manual processing.
- **Email Organization**: Cognosys helps individuals and teams efficiently manage their email inbox, automatically labeling and organizing emails based on specific criteria.



## Youtube Transcripts

### [YTScribe](https://ytscribe.com/)
YTScribe is a platform that provides free transcripts of YouTube videos. With its Chrome extension, you can easily transcribe any YouTube video with just one click. It is a powerful tool for creating transcripts, making it convenient for interviews, scanning podcasts, and providing transcripts to your audience.
- **Free Transcripts**: Allows you to obtain free transcripts of any YouTube video.
- **Chrome Extension**: The YTScribe Chrome extension adds a 1-click transcribe button to every video, making it easy to generate transcripts.
- **Fast and Efficient**: You can quickly scan long podcasts or interviews to find specific information.
- **Transcripts for Your Audience**: Enables you to provide transcripts to your audience, making your content more accessible and inclusive.
- **User-Friendly Interface**: The platform is designed to be intuitive and easy to use, allowing users to transcribe videos with minimal effort.

## Use Cases:
- **Content Creators**: YTScribe is beneficial for content creators who want to provide transcripts of their videos to improve accessibility and reach a wider audience.
- **Researchers and Journalists**: Researchers and journalists can use the tool to transcribe interviews, podcasts, or speeches, making it easier to reference and analyze the content.
- **Language Learners**: YTScribe can be utilized by language learners to practice listening skills and improve comprehension by reading along with the transcript.

## How to use it?
1. **Install the Chrome Extension**: Visit the YTScribe website and install their Chrome extension.
2. **Find a YouTube Video**: Go to the YouTube video you want to transcribe.
3. **Click the Transcribe Button**: Once the extension is installed, a transcribe button will appear below the video. Click on it to initiate the transcription process.
4. **View and Download the Transcript**: Once the transcription is complete, the transcript will be displayed on the screen. You can also download it for future reference.

## Pricing Plans
- **Monthly Billing**: This plan provides unlimited AI punctuations and YouTube transcripts for $9.99 per month (billed monthly).
- **Yearly Billing (Save 20%)**: By opting for the annual subscription, you can enjoy unlimited AI punctuations and YouTube transcripts for a discounted price of $4.99 per month (billed annually). This plan offers a 20% savings compared to the monthly billing option.

YTScribe is a convenient and powerful platform for obtaining free transcripts of YouTube videos. With its Chrome extension, you can easily transcribe videos with just one click, making it useful for content creators, researchers, journalists, and language learners. The user-friendly interface and efficient transcription process make YTScribe a valuable tool for enhancing accessibility and analyzing video content.

## [FilelistCreator](https://fr.sttmedia.com/filelistcreator)
Disponible **gratuitement**, **en français** et **ne nécessitant même pas d’installation** (application portable), _FilelistCreator_ est un utilitaire permettant **d’établir la liste de tous les fichiers du dossier de votre choix**. Très pratique pour répertorier en quelques secondes tous les fichiers contenus sur un disque dur externe par exemple !  
  
**Très simple d’utilisation**, il suffit d’indiquer à _FilelistCreator_ quel dossier ou lecteur vous souhaitez inventorier et le tour est joué. La liste de vos fichiers peut être **copiée** dans le presse-papiers, **imprimée** ou **sauvegardée** dans le format de votre choix : TXT (texte), HTML (page web), CSV, XLSX (Excel), ODS, DIF, PNG, JPG, BMP.





# **Simply highlight text and save it on the page**

- [Highlights – Highlighter and Web Clipper](https://chrome.google.com/webstore/detail/highlights-highlighter-an/fiajhjomgpnlefcbdhfghnbhpillkklb) | Highlight with tagging & search options, sync, notes, & export to Titter and ROAM [https://youtu.be/euBrnK8Ma6Y](https://youtu.be/euBrnK8Ma6Y)
- Alternative : [Highlighter](https://chrome.google.com/webstore/detail/highlighter/dinoehnfgoidbfpggkdkofpijennefgf)
- [https://youtu.be/RzvQBbJUZjs](https://youtu.be/RzvQBbJUZjs)

# **Share highlight with your group**

- [Hypothesis – Web & PDF Annotation](https://chrome.google.com/webstore/detail/hypothesis-web-pdf-annota/bjfhmglciegochdpefhhlphglcehbmek)

[Copy As Plain Text – Chrome Web Store](https://chrome.google.com/webstore/detail/copy-as-plain-text/eneajgkmdhmjmloiabgkpkiooaejmlpk/related)

a lite multi-browser addon that let you easily copy any text without formatting to the clipboard via right-click context-menu item. Simply browse to a website and select a desired text, then right-click and select – Copy as plain text – from the context-menu. The selected text will be copied to the clipboard without any formatting. Please note that, in order to paste to the clipboard you can use (Ctrl + V) or right-click and select – paste – in the context menu. 2. How can I work with Copy As Plain Text addon? In order to work with this addon, as mentioned above, simply select any text from a webpage and then right-click and select – Copy as plain text – in the context-menu item. The text will be copied to the clipboard. 3. How can I download the source code for Copy As Plain Text? To download the source code for this extension from Chrome Web Store, it is recommended to use Extension Source Downloader. With this addon, you can download the source code as a ZIP or CRX format to your machine. If you want to download the source code from the Firefox addons store, please open the firefox download link (if available) in the Firefox browser and then right-click on the – Add to Firefox – button and select – Save Link As… – item. Choose the destination folder on your machine and then save the file in XPI format. You can then rename the XPI format to a RAR or ZIP file. Some extensions may have a GitHub repo address, which you can use to download the source code as well. But, it may not be the latest version of the addon. Therefore, downloading the source code from the official web stores is the best option as it always gives you the latest version of the addon. 4. Is there any options or settings for this addon? No, this addon has no options or setting to adjust. Just add it to your browser and start using it right away. 5. Does this addon store the clipboard to the memory? No, this addon does not store any text to the memory. Whatever you copy will be erased once you select another text or restart the browser. 6. How can I remove the context-menu item from right-click? In order to remove the context-menu item, you need to disable the addon. Please head to the extensions page in your browser, find the addon and then click on the disable button. 7. Can I copy images to the clipboard with this addon? No, you cannot copy images to the clipboard at the moment. This is because currently the clipboard API only works for text format. 8. Can I use the toolbar button to copy text No, currently you can only use the right-click context-menu item to copy any text. In fact, this addon does not have any toolbar button. All you need is available within the context-menu item. 9. Where can I find the privacy policy for Copy As Plain Text? Please read the privacy policy for this extension here.

[Copy as Plain Text – Chrome Web Store](https://chrome.google.com/webstore/detail/copy-as-plain-text/hmjdnojobglgfjhfdeamomnjdlfcmogl)

- [Pensive an extensive highlighter](https://chrome.google.com/webstore/detail/pensive-an-extensive-high/hpphpjjfaccabjggafeageiljmkppmla/related)
    
- [SelectionSK](https://chrome.google.com/webstore/detail/selectionsk/npohodmlkdednnlbhfegpnhohpgckocf) is an alternaive with lots of seful features
![](VI.a%20Capture,%20Curate,%20Collect-202411251731.png)

![](Pasted%20image%2020241125173157.png)

    
- Simple search[Selection Popup – Chrome Web Store](https://chrome.google.com/webstore/detail/selection-popup/ahecgidbcpeicikbcpaljaocofecilpd) Allow selecting, copying, pasting and right clicking in some restricted pages. [Enable Copy – Chrome Web Store](https://chrome.google.com/webstore/detail/enable-copy/lmnganadkecefnhncokdlaohlkneihio) [Free and Simple Clipboard – Quick Clip – Chrome Web Store](https://chrome.google.com/webstore/detail/free-and-simple-clipboard/dlceoimfobgafaicldbpbdcpbiddpnom)  [Copy as Plain Text – Chrome Web Store](https://chrome.google.com/webstore/detail/copy-as-plain-text/hmjdnojobglgfjhfdeamomnjdlfcmogl) [Diigo Web Collector – Capture and Annotate – Chrome Web Store](https://chrome.google.com/webstore/detail/diigo-web-collector-captu/pnhplgjpclknigjpccbcnmicgcieojbh) ‣ If you don’t want to bother with customizations and just copy url as markdown use this one : [Copy Title and Url as Markdown Style – Chrome Web Store](https://chrome.google.com/webstore/detail/copy-title-and-url-as-mar/fpmbiocnfbjpajgeaicmnjnnokmkehil)
    ![](VI.a%20Capture,%20Curate,%20Collect-202411251732.png)
    
- [Web Page Highlighter – Chrome Web Store](https://chrome.google.com/webstore/detail/web-page-highlighter/poemphopblfbpoaoglhbljbjfodofmpa) : Web Page Highlighter for Google Chrome allows a user to highlight a selected text fragment on a web page and generate a URL that automatically scrolls to the highlighted portion of the web page.
    

[Free and Simple Clipboard – Quick Clip – Chrome Web Store](https://chrome.google.com/webstore/detail/free-and-simple-clipboard/dlceoimfobgafaicldbpbdcpbiddpnom)

[Copy as Plain Text – Chrome Web Store](https://chrome.google.com/webstore/detail/copy-as-plain-text/hmjdnojobglgfjhfdeamomnjdlfcmogl)

[Diigo Web Collector – Capture and Annotate – Chrome Web Store](https://chrome.google.com/webstore/detail/diigo-web-collector-captu/pnhplgjpclknigjpccbcnmicgcieojbh)

If you don’t want to bother with customizations and just copy url as markdown use this one : [Copy Title and Url as Markdown Style – Chrome Web Store](https://chrome.google.com/webstore/detail/copy-title-and-url-as-mar/fpmbiocnfbjpajgeaicmnjnnokmkehil)