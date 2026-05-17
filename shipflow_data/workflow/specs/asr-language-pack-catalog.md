---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "winflowz_app"
created: "2026-05-14"
created_at: "2026-05-14 22:30:00 UTC"
updated: "2026-05-17"
updated_at: "2026-05-17 13:26:48 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "feature"
owner: "Diane"
user_story: "En tant qu'utilisatrice WinFlowz qui veut dicter dans sa langue depuis le clavier Android, je veux installer seulement les packs vocaux locaux dont j'ai besoin et comprendre clairement le fallback disponible, afin d'utiliser la dictée sans coût serveur implicite ni promesse trompeuse."
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "Android IME keyboard"
  - "Flutter Settings"
  - "On-device ASR runtime"
  - "Diagnostics"
  - "Local storage"
  - "Optional cloud fallback"
depends_on:
  - artifact: "shipflow_data/workflow/specs/keyboard-action-bar-voice-recording.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "shipflow_data/workflow/specs/on-device-asr-free-options-research.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "shipflow_data/workflow/specs/local-first-user-owned-sync-strategy.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "shipflow_data/business/business.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/business/gtm.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/technical/architecture.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "User decision 2026-05-14: keyboard becomes primary voice UI; overlay stays optional."
  - "User decision 2026-05-14: local device resources should be used instead of WinFlowz workers whenever possible."
  - "User decision 2026-05-14: global LTD buyers require install-on-demand language packs rather than French/English-only assumptions."
  - "User decision 2026-05-14: do not bundle all models in the APK; downloading after install is preferred."
  - "Current code already includes Android IME voice capture through KeyboardVoiceController using Android SpeechRecognizer, proving a fallback path exists but not a local-model catalog."
  - "Current code already exposes Settings and diagnostics surfaces for keyboard and overlay status, which can host pack-management state."
next_step: "/sf-start ASR Language Pack Catalog"
---

# Title

ASR Language Pack Catalog

# Status

Ready. This spec defines the product and implementation contract for downloadable on-device ASR language packs used by the WinFlowz Android keyboard. It exists to turn the current high-level local-first direction into a concrete catalog, installation, fallback, diagnostics, and benchmarking plan that an implementation agent can execute without inventing policy later.

# User Story

En tant qu'utilisatrice WinFlowz qui veut dicter dans sa langue depuis le clavier Android, je veux installer seulement les packs vocaux locaux dont j'ai besoin et comprendre clairement le fallback disponible, afin d'utiliser la dictée sans coût serveur implicite ni promesse trompeuse.

Acteur principal: utilisatrice Android qui dicte depuis le clavier WinFlowz.

Acteurs secondaires: fondatrice WinFlowz, futur support client, utilisateur LTD international, moteur ASR local choisi, fallback Android SpeechRecognizer, fallback cloud explicite.

Déclencheurs principaux:

- l'utilisatrice appuie sur le bouton micro du clavier sans pack local installé;
- l'utilisatrice ouvre Settings pour gérer les langues vocales;
- le système détecte une langue clavier/système sans pack local installé;
- un pack devient obsolète, incompatible, corrompu ou trop lourd pour l'appareil;
- le marketing veut publier une promesse de support langue pour le lancement LTD.

Résultat observable attendu: WinFlowz liste des packs de langue installables avec métadonnées fiables, permet de télécharger/supprimer/mettre à jour un pack, choisit un moteur local compatible quand il existe, et montre un fallback explicite quand le local n'est pas disponible.

# Minimal Behavior Contract

Quand l'utilisatrice veut dicter depuis le clavier, WinFlowz doit pouvoir lui proposer un pack vocal local compatible avec sa langue, le télécharger et l'utiliser sur l'appareil sans passer par un worker WinFlowz par défaut; si aucun pack local compatible n'existe, n'est pas installé, échoue au chargement ou n'est pas supporté par l'appareil, l'app doit afficher un fallback explicite et récupérable plutôt qu'un échec silencieux. Le résultat observable est soit une dictée locale active avec moteur et langue identifiés, soit un statut clair indiquant l'installation, l'incompatibilité ou le mode fallback. L'edge case le plus facile à rater est le cas où la langue système semble supportée mais le pack choisi est trop lourd ou incompatible avec l'ABI/RAM de l'appareil: l'app doit alors refuser proprement le mode local au lieu de promettre une langue "supportée" qui ne marche pas sur le terminal réel.

# Success Behavior

- Given l'utilisatrice ouvre la section "On-device speech" dans Settings, when le catalogue est chargé, then elle voit les packs classés par langue avec moteur, taille, licence, niveau qualité, statut offline et politique fallback.
- Given aucun pack local n'est installé pour la langue active, when l'utilisatrice touche le micro clavier, then WinFlowz propose soit l'installation du pack recommandé, soit un fallback explicite si aucun pack local recommandé n'existe.
- Given un pack compatible est installé et vérifié, when l'utilisatrice dicte depuis le clavier, then le moteur local démarre sans ouvrir l'overlay ni une UI Flutter intermédiaire et le diagnostic identifie le pack, le moteur et la source `keyboard`.
- Given un pack téléchargé à 100% avec checksum valide, when l'installation se termine, then le pack apparaît comme `installed` avec taille disque, version et date d'installation persistantes.
- Given une mise à jour de pack est publiée dans le catalogue, when l'utilisatrice consulte Settings, then l'UI signale qu'une update existe sans forcer l'installation immédiate.
- Given plusieurs packs existent pour une même langue, when WinFlowz choisit le pack par défaut, then le choix suit un ordre déterministe basé sur compatibilité appareil, niveau qualité et politique produit.
- Given une langue n'a pas de pack local prêt à recommander, when le support produit ou le GTM consulte la matrice des langues, then la langue est marquée `experimental` ou `fallbackOnly` et non vendue comme offline vérifiée.

# Error Behavior

- Si le catalogue ne charge pas, l'UI doit afficher un état erreur récupérable avec action `Retry`; l'ancienne liste valide peut rester visible mais marquée stale.
- Si un téléchargement est interrompu, la progression doit rester observable et reprenable; aucun pack partiellement téléchargé ne doit être exposé comme `installed`.
- Si le checksum ou la signature d'un pack échoue, le fichier doit être rejeté, le statut doit passer à `failed_verification`, et aucun chargement moteur ne doit être tenté.
- Si l'appareil ne satisfait pas `minAndroidSdk`, `supportedAbis` ou `minRamMb`, l'installation doit être bloquée avec explication visible et fallback proposé.
- Si le preflight de capacite disque echoue, l'installation doit etre refusee avant download avec un message explicite (`required_mb`, `available_mb`) et un fallback propose.
- Si le moteur local ne peut pas charger le modèle installé, WinFlowz doit journaliser l'échec, marquer la cause dans l'état natif persistant, puis proposer Android SpeechRecognizer ou le fallback configuré.
- Si le démarrage runtime local dépasse le timeout de chargement (`10s`), WinFlowz doit basculer vers fallback explicite, persister `fallback_reason=runtime_timeout`, et ne pas boucler en retry infini.
- Si l'utilisatrice soumet plusieurs actions concurrentes (tap répété micro ou install), les commandes doivent être idempotentes: une seule transaction active par `pack_id`, les autres sont ignorées ou fusionnées avec feedback UI.
- Ce qui ne doit jamais arriver: lancement silencieux d'un worker WinFlowz alors que l'utilisatrice pense etre en local, pack marque `recommended` sans licence commerciale verifiee, ou texte marketing annonçant un support langue offline non benchmarke.

# Problem

Le produit veut devenir keyboard-first et local-first, mais aujourd'hui il n'existe ni catalogue de packs ASR ni contrat unique pour dire quelles langues sont installables, quel moteur local les execute, comment les telecharger, ni quel fallback utiliser. Sans ce cadre, chaque langue risque de devenir un bricolage ad hoc, avec promesses marketing non tenables, support client flou, et depenses worker qui explosent des que les utilisateurs LTD internationaux commencent a dicter.

# Solution

Introduire un catalogue de packs de langue ASR versionne, telechargeable et gratuit, alimente par metadonnees produit verificables et consomme par deux surfaces: le clavier Android pour le choix runtime/fallback, et Settings pour l'installation/maintenance. Le catalogue doit separer clairement le statut marketing d'une langue, le statut technique d'un pack, la compatibilite appareil, et la politique fallback, afin que le produit puisse etendre sa couverture linguistique sans gonfler l'APK ni mentir sur la qualite offline.

# Data Contract

`LanguagePackCatalogEntry` doit exposer les champs obligatoires suivants:

- `pack_id`: identifiant stable unique, format lowercase `engine.language.region.variant.version` sans espace.
- `language_tag`: tag BCP-47 normalise (`fr-FR`, `en-US`, `hi-IN`), distinct de la langue UI.
- `display_name`: libelle user-facing localise ou fallback anglais.
- `engine`: enum stable (`android_speech_recognizer`, `sherpa_onnx`, `whisper_cpp`, `vosk`, `cloud_fallback`, `unavailable`).
- `engine_version`: version moteur ou `unknown` si le fallback systeme Android ne l'expose pas.
- `model_version`: version modele ou `none` pour fallback systeme/cloud sans artefact local.
- `quality_tier`: enum `recommended`, `standard`, `experimental`, `fallbackOnly`.
- `runtime_mode`: enum `local`, `android_fallback`, `cloud_fallback`, `unavailable`.
- `fallback_policy`: enum `prefer_local`, `android_then_cloud_auto`, `cloud_auto_only`, `unavailable`.
- `download_url`: URL HTTPS ou `none` si aucun artefact local n'est telechargeable.
- `download_size_mb`: entier positif ou `0` si aucun artefact local.
- `installed_size_mb`: entier positif ou `0` si aucun artefact local.
- `sha256`: checksum hex lowercase obligatoire pour tout artefact local, `none` sinon.
- `signature`: signature ou reference de signature obligatoire pour tout artefact local, `none` sinon.
- `license_id`: identifiant de licence; ne peut pas etre `unknown` pour un pack `recommended`.
- `commercial_distribution_allowed`: booleen; doit etre `true` pour tout pack `recommended`.
- `min_android_sdk`, `supported_abis`, `min_ram_mb`, `requires_streaming`, `supports_offline`: champs de compatibilite obligatoires.
- `benchmark_status`: enum `unbenchmarked`, `candidate`, `benchmarking`, `passed`, `failed`.
- `benchmark_evidence`: chemin doc local ou `none`; obligatoire et non-`none` pour `recommended`.
- `updated_at`: timestamp UTC ISO-8601 du catalogue.

`InstalledLanguagePack` doit exposer les champs obligatoires suivants:

- `pack_id`, `language_tag`, `engine`, `model_version`.
- `install_state`: enum `not_installed`, `queued`, `downloading`, `paused_insufficient_storage`, `verifying`, `installed`, `update_available`, `failed_download`, `failed_verification`, `blocked_incompatible_device`, `blocked_insufficient_storage`, `corrupted`, `removed`.
- `runtime_mode`: enum `local`, `android_fallback`, `cloud_fallback`, `unavailable`.
- `fallback_reason`: enum `none`, `missing_pack`, `incompatible_device`, `insufficient_storage`, `runtime_load_failed`, `runtime_timeout`, `verification_failed`, `unsupported_language`, `cloud_auto_policy`, `user_disabled_cloud`.
- `download_progress`: entier `0..100`.
- `installed_size_mb`, `required_mb`, `available_mb`.
- `checksum_verified`: booleen.
- `installed_at`, `last_verified_at`, `last_error_at`: timestamps UTC ISO-8601 ou `none`.
- `last_error_code`: code stable ou `none`; ne contient jamais de secret, audio, transcription brute ni chemin local complet.

# Scope In

- Definir le format `LanguagePackCatalogEntry` et l'etat `InstalledLanguagePack`.
- Definir la matrice de qualite et de readiness des langues: `recommended`, `standard`, `experimental`, `fallbackOnly`.
- Definir la politique d'installation: apres install app, au premier micro, ou depuis Settings.
- Definir la politique de fallback: local, Android SpeechRecognizer, cloud explicite (mode auto), ou indisponible.
- Definir les controles de compatibilite appareil: SDK, ABI, RAM, taille, support streaming.
- Definir les etats de telechargement, verification, installation, suppression, mise a jour et corruption.
- Definir les diagnostics minimaux cote Flutter et natif.
- Definir le protocole de benchmark qui autorise une langue a passer `recommended`.
- Definir la coherence documentaire et GTM autour des promesses de support langue.

# Scope Out

- Implementer le runtime ASR lui-meme dans cette spec.
- Choisir definitivement entre `sherpa-onnx`, `whisper.cpp`, Vosk ou autre pour toutes les langues avant benchmark.
- Construire un marketplace payant de packs.
- Embarquer tous les modeles dans l'APK.
- Traiter iOS, desktop ou web dans cette premiere spec.
- Promettre un support offline universel.

# Constraints

- Aucun modele ASR lourd ne doit etre bundle par defaut dans l'APK sans decision explicite ulterieure.
- Le catalogue est gratuit et ne doit pas utiliser de vocabulaire "marketplace" dans l'UI actuelle.
- Une langue ne peut etre marquee `recommended` que si le pack associe a passe benchmark qualite/perf/licence sur au moins un appareil representatif.
- Le clavier ne doit jamais perdre sa reactivite parce qu'un chargement modele bloque le thread UI.
- Le produit doit utiliser les ressources du telephone avant tout worker WinFlowz quand un pack local compatible est installe.
- Aucun fallback cloud ne doit etre silencieux; l'utilisatrice doit comprendre quel mode elle utilise.
- Le fallback cloud est autorise en mode auto apres echec local ou indisponibilite locale, mais seulement si l'utilisatrice a active le parametre `allow_cloud_fallback`.
- Avant toute capture susceptible d'utiliser le cloud, l'UI doit afficher le mode actif `cloud_fallback`; apres capture, les diagnostics doivent conserver `runtime_mode=cloud_fallback` et `fallback_reason=cloud_auto_policy`.
- Si `allow_cloud_fallback=false`, un echec local ou Android fallback doit aboutir a un etat recuperable `unavailable`, jamais a un envoi cloud.
- Donnees cloud autorisees: uniquement l'audio necessaire a la transcription et les metadonnees minimales `language_tag`, `engine`, `runtime_mode`, `fallback_reason`; aucune cle API utilisateur, aucun chemin local, aucun pack checksum complet, aucun texte de diagnostic verbeux ne doit etre transmis.
- Logs cloud interdits: audio brut, transcription brute avant affichage utilisatrice, cle API, token, chemin local complet, identifiant appareil persistant non necessaire.
- Le parametre `allow_cloud_fallback` doit etre modifiable dans Settings et son etat doit etre visible dans les diagnostics.
- Les retries automatiques doivent etre bornes et observables (pas de boucle infinie), avec un maximum de `3` retries automatiques par operation.
- Politique capacite disque (deterministe): un install preflight est autorise uniquement si `pack_size_mb <= 5%` de la capacite totale ET `free_space_mb >= max(3 * download_size_mb, installed_size_mb + 1536)`.
- Si le preflight espace disque echoue, l'etat doit devenir `blocked_insufficient_storage` avec l'espace requis et l'espace disponible visibles; aucun telechargement ne demarre.
- Si l'espace disque devient insuffisant en cours de telechargement, l'operation passe en `paused_insufficient_storage`, le fichier temporaire reste reprenable, et l'UI propose `Retry` apres liberation d'espace.
- Chaque transition d'etat doit etre idempotente.
- Les diagnostics ne doivent jamais contenir audio brut, cle API, token, ni chemin local complet sensible.
- Toute entree de catalogue non conforme au `Data Contract` doit etre rejetee avec etat recuperable `catalog_invalid_entry`; elle ne peut pas etre proposee a l'installation ni servir a un claim GTM.
- Les metadonnees de licence doivent faire partie du contrat de catalogue et pas d'une note externe ad hoc.
- Les claims publics AppSumo/LTD doivent etre derives des statuts du catalogue et non l'inverse.

# Dependencies

Code local et points d'ancrage:

- `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzInputMethodService.kt`: point d'entree clavier natif, deja capable de dictee et d'insertion de texte.
- `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardVoiceController.kt`: implementation actuelle du fallback Android `SpeechRecognizer`, a transformer en facade moteur avec selection `local` ou `fallback`.
- `lib/core/platform/android_keyboard_bridge.dart`: pont Flutter vers l'IME, extension probable pour exposer statut packs et fallback.
- `lib/features/settings/presentation/settings_screen.dart`: surface existante pour exposer gestion overlay/clavier/diagnostics, cible pour la section "On-device speech".
- `lib/features/shell/presentation/app_shell_screen.dart`: onboarding Android et priorisation clavier/permissions; devra cesser de traiter la voix locale comme implicite.
- `lib/core/platform/android_overlay_bridge.dart`: exemple de bridge natif/Flutter avec statut detaille et diagnostics de reference.

Docs et artefacts locaux:

- `shipflow_data/workflow/specs/keyboard-action-bar-voice-recording.md`: position produit clavier principal, overlay optionnel, packs gratuits a la demande.
- `shipflow_data/workflow/specs/on-device-asr-free-options-research.md`: shortlist runtimes/modeles et recommandations de spike.
- `shipflow_data/workflow/specs/local-first-user-owned-sync-strategy.md`: cadre local-first global et exigence de packs telechargeables pour les acheteurs LTD internationaux.
- `shipflow_data/business/business.md`: promesse produit et contraintes de securite/serveur.
- `shipflow_data/business/gtm.md`: promesse publique sure et formulations a eviter.
- `shipflow_data/technical/architecture.md`: contrat backend-agnostic et pipeline voice local/advanced.

Fresh external docs:

- `fresh-docs not needed` pour ce draft, car la spec ne fige pas encore une API externe ni un SDK de telechargement; elle formalise d'abord les contrats internes a partir des recherches locales deja documentees le 2026-05-14.

# Invariants

- Le clavier reste l'interface primaire de dictee Android.
- L'overlay reste optionnel et independant du choix de pack.
- Le catalogue ne melange pas statut technique et promesse marketing.
- Un pack installe n'est utilisable que si son integrite et sa compatibilite appareil sont verifiees.
- Le mode runtime effectif doit toujours etre observable: `local`, `android_fallback`, `cloud_fallback`, `unavailable`.
- Pour un `pack_id` donne, il ne peut exister qu'une operation active a la fois (`download`, `verify`, `install`, `remove`).
- Une langue sans pack benchmarke ne peut pas etre vendue comme offline garantie.

# Links & Consequences

- Le choix d'un format de catalogue impacte l'IME natif, Settings Flutter, diagnostics, onboarding et support client.
- Le catalogue devient une source de verite transverse pour GTM et pour le comportement runtime; il faut donc eviter les copies de statuts en dur dans plusieurs couches.
- Le passage d'un pack a `recommended` a des consequences business directes sur les claims AppSumo/LTD.
- Les diagnostics backend et support devront inclure l'etat du pack pour expliquer un echec de dictee sans confondre micro, moteur, langue et permission.
- Le futur gestionnaire de telechargement devra stocker des artefacts potentiellement volumineux; la politique de suppression et de mise a jour doit donc rester visible pour eviter la saturation disque.

# Documentation Coherence

- Mettre a jour `shipflow_data/business/business.md` seulement si la taxonomie finale des niveaux de qualite change.
- Mettre a jour `shipflow_data/business/gtm.md` si la matrice MVP des langues modifie les promesses publiques ou les formulations de fallback.
- Aligner `shipflow_data/workflow/specs/keyboard-action-bar-voice-recording.md` quand le contrat de catalogue devient la reference implementation-ready pour le clavier.
- Ajouter une future doc support/FAQ expliquant: comment installer un pack, que signifie `fallbackOnly`, pourquoi une langue peut etre disponible sans etre offline locale, et comment supprimer un pack.

# Edge Cases

- L'utilisatrice a un clavier systeme en `en-IN` mais prefere dicter en hindi.
- Deux packs de meme langue existent, l'un leger mais mediocre, l'autre bon mais trop lourd pour un appareil low-end.
- Le pack est installe puis devient inutilisable apres update app ou manque d'espace disque.
- La langue est supportee localement sur `arm64-v8a` mais pas sur `armeabi-v7a`.
- L'utilisatrice supprime un pack alors qu'il est defini comme langue preferee.
- Le telechargement est coupe en plein milieu puis repris apres redemarrage.
- La langue existe seulement en fallback Android ou cloud et doit rester clairement marquee comme telle.

# Implementation Tasks

- [ ] Tache 1 : Introduire le contrat de catalogue de packs de langue
  - Fichier : `lib/features/voice/domain/language_pack_catalog.dart`
  - Action : Creer les modeles Dart `LanguagePackCatalogEntry`, `InstalledLanguagePack`, enums de qualite, statut installation, mode offline et politique fallback, avec serialisation stable.
  - User story link : permet de representer les packs et leur fallback de facon explicite pour l'utilisatrice.
  - Depends on : none
  - Validate with : tests unitaires de mapping JSON/Map et comparaison de priorite.
  - Notes : utiliser des identifiants stables et une convention compatible avec un futur catalogue distant ou embarque.

- [ ] Tache 2 : Ajouter un store/catalog provider local-first
  - Fichier : `lib/features/voice/application/language_pack_catalog_provider.dart`
  - Action : Definir le provider Riverpod et l'interface de chargement/rafraichissement du catalogue, avec etat `loading/success/error/stale`.
  - User story link : permet a Settings et au clavier de partager la meme source de verite.
  - Depends on : Tache 1
  - Validate with : tests de provider sur etats initiaux, erreur et rafraichissement.
  - Notes : ne pas faire dependre le domaine directement d'un transport reseau ou d'un SDK de download.

- [ ] Tache 3 : Introduire l'etat natif de packs et du moteur vocal
  - Fichier : `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardVoiceController.kt`
  - Action : Refactorer le controleur actuel en facade moteur qui expose le runtime effectif, la langue active, le pack choisi, la derniere erreur moteur et les chemins `local` versus `android_fallback`.
  - User story link : garantit que la dictee clavier peut distinguer local et fallback.
  - Depends on : Tache 1
  - Validate with : tests natifs unitaires ou de logique sur selection moteur et fallback.
  - Notes : l'implementation locale concrete peut rester stubbee au debut, mais l'API interne doit etre definitive.

- [ ] Tache 4 : Exposer le statut packs via le bridge Android clavier
  - Fichier : `lib/core/platform/android_keyboard_bridge.dart`
  - Action : Ajouter les structures et methodes de bridge pour lire le statut de packs, le mode runtime effectif et les actions d'installation/suppression si elles restent orchestrees cote Flutter.
  - User story link : rend le statut visible et actionnable dans l'app.
  - Depends on : Tache 3
  - Validate with : sanity check sur mapping des payloads MethodChannel.
  - Notes : suivre le style du bridge overlay existant pour les erreurs et le status summary.

- [ ] Tache 5 : Ajouter la section "On-device speech" dans Settings
  - Fichier : `lib/features/settings/presentation/settings_screen.dart`
  - Action : Afficher packs installes/disponibles, taille, licence, niveau qualite, mise a jour, suppression et fallback configure.
  - User story link : permet a l'utilisatrice de gerer ses langues sans quitter l'app.
  - Depends on : Tache 2, Tache 4
  - Validate with : test widget ou verification manuelle structuree du rendu et des etats vides/erreur.
  - Notes : l'UI doit etre explicite sur ce qui est local, experimental, fallback-only ou indisponible.

- [ ] Tache 6 : Etendre l'onboarding et le premier usage micro
  - Fichier : `lib/features/shell/presentation/app_shell_screen.dart`
  - Action : Inserer le prompt de pack recommande au premier usage micro et ajuster l'onboarding pour demander un pack local ou un fallback accepte, sans rendre l'overlay obligatoire.
  - User story link : evite l'effet "micro casse" lors du premier usage.
  - Depends on : Tache 2, Tache 5
  - Validate with : scenarios manuels premier lancement/premier micro/pas de pack compatible.
  - Notes : garder les transitions d'onboarding recuperables et diagnostiquables.

- [ ] Tache 7 : Ajouter les diagnostics de catalogue et de runtime voix
  - Fichier : `lib/features/settings/presentation/settings_screen.dart`
  - Action : Etendre le diagnostic texte et les breadcrumbs pour inclure `pack_id`, `engine`, `quality_tier`, `runtime_mode`, `fallback_reason`, `install_state`.
  - User story link : permet de comprendre pourquoi une langue fonctionne ou non.
  - Depends on : Tache 4, Tache 5
  - Validate with : sanity check du texte diagnostic et des evenements en usage nominal et erreur.
  - Notes : ne jamais journaliser l'audio brut ni des chemins sensibles complets.

- [ ] Tache 8 : Formaliser le protocole de benchmark et la matrice MVP langues
  - Fichier : `shipflow_data/workflow/specs/on-device-asr-free-options-research.md`
  - Action : Ajouter ou lier une grille normalisee de benchmark par langue/appareil et une matrice des premieres langues candidates au statut `candidate`, `benchmarking`, `recommended` ou `fallbackOnly`.
  - User story link : protege l'utilisatrice contre des promesses de support langue non verifiees.
  - Depends on : none
  - Validate with : revue documentaire et coherence avec GTM/business.
  - Notes : la matrice initiale peut couvrir `fr`, `en`, `es`, `de`, `pt`, `it`, `hi`, `ar`, `zh`, `ja`, `ko` sans toutes les vendre comme offline au depart.

# Acceptance Criteria

- [ ] CA 1 : Given Settings charge le catalogue, when au moins un pack est disponible, then chaque entree affiche langue, moteur, taille de telechargement, taille installee, licence, niveau qualite et fallback.
- [ ] CA 2 : Given aucun pack n'est installe pour la langue active, when l'utilisatrice touche le micro clavier, then WinFlowz propose un pack recommande ou un fallback explicite, jamais un simple echec silencieux.
- [ ] CA 3 : Given un pack compatible est installe et valide, when la dictee commence depuis le clavier, then le runtime effectif est `local` et les diagnostics incluent `pack_id` et `engine`.
- [ ] CA 4 : Given un pack est incompatible avec l'appareil, when l'utilisatrice tente l'installation, then l'installation est refusee avec raison visible et fallback propose.
- [ ] CA 5 : Given un telechargement est interrompu, when l'app revient au premier plan ou relance l'installation, then l'etat reste recuperable et le pack n'apparait pas comme installe tant que la verification n'est pas finie.
- [ ] CA 6 : Given une langue n'a qu'un support `fallbackOnly`, when l'utilisatrice consulte Settings, then cette langue n'est pas presentee comme offline locale.
- [ ] CA 7 : Given un pack a une licence non validee pour distribution commerciale, when le catalogue est prepare pour shipping, then ce pack ne peut pas etre marque `recommended`.
- [ ] CA 8 : Given le GTM veut annoncer une langue en AppSumo/LTD, when la langue n'est pas benchmarkee localement, then la spec et la doc imposent une formulation fallback ou experimental au lieu d'une promesse offline.
- [ ] CA 9 : Given le runtime local depasse son timeout de demarrage (`10s`), when la tentative echoue, then l'app passe en fallback explicite, journalise `fallback_reason=runtime_timeout`, et n'effectue pas de retry infini.
- [ ] CA 10 : Given plusieurs actions concurrentes sont declenchees pour un meme `pack_id`, when l'execution est en cours, then une seule operation active est conservee et l'etat final reste coherent.
- [ ] CA 11 : Given un diagnostic voix est emis, when il est persiste ou affiche, then il contient uniquement des metadonnees techniques autorisees et jamais d'audio brut ni secret.
- [ ] CA 12 : Given une operation `download`, `verify`, `install` ou `remove` echoue, when la politique de reprise s'applique, then au plus `3` retries automatiques sont effectues avant un etat d'echec recuperable explicite.
- [ ] CA 13 : Given le local est indisponible ou echoue, when le fallback cloud auto est active, then l'UI affiche explicitement le mode `cloud_fallback`.
- [ ] CA 14 : Given `pack_size_mb > 5%` de la capacite totale OU `free_space_mb < max(3 * download_size_mb, installed_size_mb + 1536)`, when l'utilisatrice lance l'installation d'un pack, then le systeme refuse le demarrage avec `blocked_insufficient_storage`, affiche `required_mb` et `available_mb`, et n'ecrit aucun etat `downloading`.
- [ ] CA 15 : Given une entree catalogue manque un champ obligatoire du `Data Contract` ou contient un enum invalide, when le catalogue est charge, then cette entree est rejetee avec `catalog_invalid_entry` et n'apparait ni comme installable ni comme `recommended`.
- [ ] CA 16 : Given `allow_cloud_fallback=false`, when aucun runtime local ou Android fallback ne peut transcrire, then WinFlowz affiche `unavailable` avec action de recuperation et n'envoie aucune donnee cloud.
- [ ] CA 17 : Given `allow_cloud_fallback=true` et le local est indisponible ou echoue, when le fallback cloud auto est utilise, then l'UI affiche `cloud_fallback`, les diagnostics exposent `fallback_reason=cloud_auto_policy`, et les logs excluent audio brut, transcription brute, secrets, tokens et chemins locaux complets.

# Test Strategy

- Tests unitaires Dart pour les modeles de catalogue, priorites de selection et mapping des statuts.
- Tests natifs de logique sur la facade `KeyboardVoiceController` pour la selection moteur et les raisons de fallback.
- Tests widget Flutter pour la section Settings "On-device speech" sur etats vide, loading, error, installed et update available.
- Verification manuelle Android sur au moins un appareil low-end et un appareil mid-range pour les flows: premier micro, installation pack, suppression, echec compatibilite, bascule fallback.
- Revue documentaire avant ship pour verifier que la matrice GTM n'annonce que des langues effectivement benchmarkees.

# Risks

- Risque produit: sur-promettre une couverture linguistique offline avant benchmark reel.
- Risque technique: choisir trop tot un moteur local qui ne tient pas les contraintes RAM/latence du clavier.
- Risque UX: rendre le premier usage micro trop complexe si le prompt d'installation est confus.
- Risque support: multiplier les etats implicites sans diagnostic lisible.
- Risque legal: promouvoir un pack dont la licence modele n'autorise pas clairement la distribution commerciale.

# Execution Notes

- Lire d'abord `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzInputMethodService.kt`, `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardVoiceController.kt`, `lib/core/platform/android_keyboard_bridge.dart`, `lib/features/settings/presentation/settings_screen.dart`, puis `shipflow_data/workflow/specs/on-device-asr-free-options-research.md`.
- Commencer par figer le contrat de donnees et les enums avant toute UI ou bridge MethodChannel.
- Reutiliser les patterns de statut/erreur de `android_overlay_bridge.dart` pour eviter un deuxieme langage de diagnostics.
- Garder le download manager et le runtime concret decouples: l'installation d'un pack ne doit pas forcer le choix d'un moteur unique dans le domaine.
- Commandes de validation minimales avant merge:
  - `flutter test lib/features/voice`
  - `flutter test lib/features/settings`
  - `./gradlew :app:testDebugUnitTest`
  - sanity manuelle Android: premier micro sans pack, install, retry, timeout runtime, fallback explicite, suppression pack.
- Stop condition: si le benchmark montre qu'aucun moteur local gratuit ne tient le niveau qualite/perf minimal pour une langue cible, la langue doit rester `fallbackOnly` et le GTM doit etre corrige au lieu de contourner le probleme par un worker silencieux.
- Language doctrine note: this artifact keeps stable English machine anchors (`Title`, `Status`, `Acceptance Criteria`, `Skill Run History`, `Current Chantier Flow`) while keeping user-facing explanatory prose in French, consistent with active project language.

# Open Questions

None.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-14 22:30:00 UTC | sf-spec | GPT-5 Codex | Created `shipflow_data/workflow/specs/asr-language-pack-catalog.md` from keyboard-first local-ASR decisions and existing voice/on-device research. | Draft saved. | /sf-ready shipflow_data/workflow/specs/asr-language-pack-catalog.md |
| 2026-05-15 06:15:00 UTC | sf-spec | GPT-5 Codex | Applied corrective edits after readiness review: language doctrine fixes, timeout/retry/idempotence contract, validation commands, and `Open Questions` normalization. | Partial remediation done; product/security decisions still required. | /sf-spec ASR Language Pack Catalog |
| 2026-05-15 08:35:00 UTC | sf-spec | GPT-5 Codex | Applied user decisions: cloud fallback auto mode, local runtime timeout `10s`, retries cap `3`, and matching acceptance criteria updates. | Remaining blocker: disk-capacity policy thresholds still to be fixed in spec. | /sf-spec ASR Language Pack Catalog |
| 2026-05-15 09:05:00 UTC | sf-ready | GPT-5 Codex | Re-ran readiness gate on structure, metadata, behavior contract traceability, adversarial abuse cases, security posture, language doctrine, and documentation freshness obligations. | Not ready: internal contract language doctrine still inconsistent and disk-capacity/installability policy remains under-specified for deterministic implementation and verification. | /sf-spec ASR Language Pack Catalog |
| 2026-05-15 09:10:00 UTC | sf-spec | GPT-5 Codex | Resolved readiness blockers by adding deterministic storage policy (preflight threshold, blocked/paused states, explicit observable fields) and clarifying language doctrine handling for localized prose with English anchors. | Spec updated for readiness re-check. | /sf-ready shipflow_data/workflow/specs/asr-language-pack-catalog.md |
| 2026-05-15 18:04:26 UTC | sf-spec | GPT-5 Codex | Performed follow-up normalization pass: confirmed deterministic storage policy coverage in constraints/error/acceptance, cleaned trace consistency, and kept next step on readiness gate rerun. | Spec maintained in reviewed state, ready for `/sf-ready` rerun. | /sf-ready shipflow_data/workflow/specs/asr-language-pack-catalog.md |
| 2026-05-15 18:08:42 UTC | sf-build | GPT-5 Codex | Lifecycle orchestration requested (`termine`): performed chantier check and governance gate precheck; build could not proceed to implementation because readiness gate has not passed yet on the updated spec. | Rerouted to readiness rerun before any `sf-start/sf-verify/sf-end/sf-ship`. | /sf-ready shipflow_data/workflow/specs/asr-language-pack-catalog.md |
| 2026-05-15 18:30:02 UTC | sf-ready | GPT-5 Codex | Re-ran readiness gate after the latest spec corrections, checking structure, metadata, behavior contract traceability, adversarial failure modes, language doctrine, freshness obligations, and security posture. | Not ready: the pack data contract is still too implicit for deterministic implementation, and cloud fallback `auto` still lacks explicit consent/trust boundaries for secure execution. | /sf-spec ASR Language Pack Catalog |
| 2026-05-15 19:16:15 UTC | sf-ready | GPT-5 Codex | Re-ran readiness gate after storage-threshold update, checking structure, user-story traceability, data-contract determinism, adversarial bypasses, cloud fallback security, language doctrine, and freshness obligations. | Not ready: storage policy is now deterministic, but the pack data contract remains under-specified and cloud fallback `auto` still needs explicit consent/trust-boundary rules. | /sf-spec ASR Language Pack Catalog |
| 2026-05-15 19:18:30 UTC | sf-spec | GPT-5 Codex | Resolved readiness blockers by adding explicit `LanguagePackCatalogEntry` and `InstalledLanguagePack` data contracts, catalog validation failure behavior, and cloud fallback consent/trust-boundary rules. | Spec updated for readiness re-check. | /sf-ready shipflow_data/workflow/specs/asr-language-pack-catalog.md |
| 2026-05-15 19:19:39 UTC | sf-ready | GPT-5 Codex | Re-ran readiness gate after data contract and cloud fallback trust-boundary corrections. | Ready: structure, metadata, user-story traceability, data contract, adversarial cases, security posture, language doctrine, and freshness obligations are sufficient for first implementation. | /sf-start ASR Language Pack Catalog |
| 2026-05-17 13:26:48 UTC | sf-start | GPT-5 Codex | Implemented first ASR catalog slice: Dart catalog/domain contract, local-first Riverpod provider, Settings "On-device speech" section, IME voice runtime diagnostics, explicit Android fallback status, and benchmark MVP matrix. | Partial: first implementation slice is in place and locally validated; remaining work includes real download manager, local ASR runtime integration, first-micro prompt flow, update/corruption handling, and Android device QA. | /sf-start ASR Language Pack Catalog |
| 2026-05-17 13:36:32 UTC | sf-start | GPT-5 Codex | Implemented a safer Flutter install-state manager slice: testable local repository, idempotent per-pack transitions (`queued/downloading/verifying/installed`), guarded `markInstalled` (no false installed before verification), bounded retries (`max=3`), and provider tests for persistence and failure paths. | Partial: install-state lifecycle safety is now covered in Flutter state + tests, but no real model download/runtime execution is wired yet and first-micro onboarding/update/corruption flows remain. | /sf-start ASR Language Pack Catalog |
| 2026-05-17 13:39:03 UTC | sf-verify | GPT-5 Codex | Verified the implemented ASR catalog slices against the current spec scope: Flutter catalog/domain/provider state machine, Settings visibility, IME diagnostic wiring, local checks, and Android Kotlin compile surface. | Partial: focused tests, `flutter analyze`, diff hygiene, and Kotlin compile pass when resource processing is skipped; full verification is blocked by missing real download/runtime integration, first-micro flow, durable app restart persistence, Android device QA, and local AAPT2 runner incompatibility for full debug resources. | /sf-start ASR Language Pack Catalog |

# Current Chantier Flow

- `sf-spec`: done - latest draft captured the current product direction, deterministic storage policy, data contract, cloud fallback trust boundary, and language doctrine note.
- `sf-ready`: ready - readiness gate passed after data contract and cloud fallback trust-boundary corrections.
- `sf-start`: partial - first implementation slice plus install-state hardening are in place (idempotent transitions, retry cap, guarded install, provider persistence tests), but real download/runtime wiring and first-use orchestration are still pending.
- `sf-verify`: partial - current implementation slices pass local Flutter checks and Kotlin compile surface, but full chantier verification still needs real download/runtime behavior, first-micro orchestration, durable persistence proof, and Android device/CI QA.
- `sf-end`: not launched - closeout depends on implementation and verification.
- `sf-ship`: not launched - shipping is blocked on benchmark-backed language claims and implementation proof.

Next command: `/sf-start ASR Language Pack Catalog`
