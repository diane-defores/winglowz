---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "winflowz_app"
created: "2026-05-16"
created_at: "2026-05-16 07:23:29 UTC"
updated: "2026-05-16"
updated_at: "2026-05-16 09:27:41 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "feature"
owner: "Diane"
user_story: "En tant qu'utilisatrice du clavier WinFlowz sur Android, je veux que les actions du clavier, les réglages et les diagnostics restent récupérables même quand une action native échoue, afin de ne plus perdre le clavier ou l'application sans information exploitable."
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "Android IME Kotlin"
  - "Flutter settings"
  - "Flutter diagnostics"
  - "Sentry Flutter/native telemetry"
  - "Keyboard Theme Studio"
  - "ShipFlow bug/spec workflow"
depends_on:
  - artifact: "shipflow_data/technical/architecture.md"
    artifact_version: "0.1.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/technical/guidelines.md"
    artifact_version: "0.1.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/workflow/specs/android-ime-winflowz_app-keyboard.md"
    artifact_version: "unknown"
    required_status: "active"
  - artifact: "shipflow_data/workflow/specs/keyboard-theme-studio.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "User report 2026-05-16: tapping the Android keyboard action-bar symbol '#+=' crashes the real IME while preview works."
  - "User report 2026-05-16: Android OS terminates the app/keyboard before WinFlowz can offer logs."
  - "Local code: lib/core/bootstrap/sentry_bootstrap.dart configures sentry_flutter 9.20.0 and redacted breadcrumbs."
  - "Local code: android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzKeyboardView.kt centralizes drawing, touch dispatch, panel switching and layout snapshot rebuilds."
  - "Official docs checked 2026-05-16: Sentry Flutter docs state the Flutter SDK supports automatic error reporting; Flutter error-reporting docs state Sentry can capture Dart and native Android layers, including Java/Kotlin/C/C++."
next_step: "/sf-fix BUG-2026-05-16-003"
---

## Title
Keyboard Resilience and Error Management

## Status
Ready. Validated by `/sf-ready` on 2026-05-16; ready for `/sf-start Keyboard Resilience and Error Management`.

## User Story
En tant qu'utilisatrice du clavier WinFlowz sur Android, je veux que les actions du clavier, les réglages et les diagnostics restent récupérables même quand une action native échoue, afin de ne plus perdre le clavier ou l'application sans information exploitable.

## Minimal Behavior Contract
Quand l'utilisateur interagit avec le clavier Android ou ses réglages, WinFlowz accepte les taps, gestes, changements de panel, changements de thème, réglages de hauteur/compact, imports et actions média/navigation sans laisser une exception non gérée tuer le clavier. En cas de panne locale, le système doit annuler uniquement l'action fautive, afficher un message court dans le clavier ou les settings, enregistrer un diagnostic redigé et, si Sentry est configuré, envoyer un contexte technique sans texte saisi, presse-papiers, secrets ni contenu utilisateur. L'edge case facile à rater est une exception pendant le rendu ou la reconstruction du layout: elle ne peut pas dépendre du layout cassé pour afficher l'erreur, donc le clavier doit basculer vers un fallback minimal sûr.

## Success Behavior
- Précondition: le clavier WinFlowz est actif dans une app Android, avec thème, hauteur, mode compact, panels et raccourcis potentiellement configurés.
- Action: l'utilisateur tape sur une action sensible (`#+=`, `Prefs`, `Clip`, `Media`, `Theme`, hauteur, compact), utilise un appui long, scrolle un panel ou applique un thème custom.
- Résultat visible: l'action réussit normalement, ou en cas d'erreur le clavier reste affiché avec un statut court du type `Keyboard recovered` / `Action failed` et un fallback minimal si nécessaire.
- Effet système attendu: un événement diagnostic redigé est conservé localement, le dernier état d'erreur clavier est exposé au pont Flutter, et Sentry reçoit l'erreur native/Flutter quand `SENTRY_DSN` est configuré.
- Preuve de succès: tests Kotlin/Flutter passent, scénario réel de reproduction ne ferme plus l'application, `Copy diagnostic` contient l'événement redigé après `Clear logs` puis reproduction.

## Error Behavior
- Exception dans `WinFlowzKeyboardView.onDraw`, `onTouchEvent`, `dispatch`, `refreshLayout` ou `buildSnapshot`: capturer l'erreur, arrêter les callbacks/repeat en cours, désactiver le panel courant si nécessaire, reconstruire un snapshot fallback minimal et afficher un statut récupérable.
- Exception dans `WinFlowzInputMethodService` callback ou action système: capturer l'erreur, ne pas répéter l'action, ne pas envoyer de texte partiel, afficher un statut court et garder l'IME vivant si Android le permet.
- Exception MethodChannel Flutter/Kotlin: renvoyer une `PlatformException` typée ou un status dégradé au lieu d'une exception brute, et enregistrer un diagnostic redigé côté Flutter.
- Sentry indisponible ou `SENTRY_DSN` absent: ne pas bloquer l'app; conserver uniquement le diagnostic local et indiquer `sentry=disabled` dans le diagnostic.
- ANR/boucle UI: ne pas prétendre pouvoir tout récupérer dans le process, mais réduire le risque via garde-fous de fréquence, timers/runnables annulés, et breadcrumbs permettant de voir la dernière action avant l'ANR. Ne jamais logger le texte tapé, le contenu clipboard, les clés API, tokens, prompt, transcription ou contenu privé.

## Problem
Le clavier natif Android est un composant critique: une exception dans son rendu ou dans un tap peut faire arrêter l'IME par Android sans passer par l'UI Flutter. Les diagnostics actuels existent surtout côté Flutter (`AppDiagnostics`) et Sentry est initialisé via `sentry_flutter`, mais les actions Kotlin du clavier n'ont pas encore de contrat explicite de récupération, fallback, redaction et exposition du dernier crash. Résultat: quand une action réelle du clavier crash, l'utilisateur peut seulement constater que l'app doit s'arrêter, sans isoler rapidement l'action fautive.

## Solution
Ajouter une couche de résilience native autour du clavier: reporter Kotlin redigé, wrappers `runKeyboardSafely`, fallback layout minimal, dernier état d'erreur exposé au status Flutter, et intégration diagnostique settings. Utiliser Sentry comme télémétrie distante quand disponible, mais garder un mécanisme local indépendant pour debug rapide et pour les builds sans DSN.

## Scope In
- Garde-fous natifs Kotlin autour du rendu, du touch handling, des dispatch d'actions, des reconstructions de layout et des callbacks IME.
- Diagnostic clavier natif persistant et redigé: dernier crash/action/contexte sûr, compteur de récupération, horodatage UTC.
- Exposition du dernier diagnostic clavier via `getKeyboardStatus` et affichage/copie dans les settings Flutter.
- Clear/copy logs déjà présent à intégrer avec les diagnostics natifs.
- Fallback minimal du clavier si le layout ou le panel courant casse.
- Sentry breadcrumbs/tags/context pour le clavier, sans contenu utilisateur.
- Tests et checks pour crashes de layout, status map, redaction et non-régression des settings.

## Scope Out
- Implémenter une page complète d'administration Sentry ou une console de crash dans l'app.
- Ajouter une session replay ou capture d'écran Sentry pour le clavier.
- Envoyer automatiquement les logs diagnostics par email/support sans consentement explicite.
- Résoudre tous les bugs fonctionnels clavier déjà listés hors crash safety, sauf s'ils sont nécessaires pour valider la résilience.
- Capturer ou stocker le texte tapé, les entrées clipboard, snippets complets, transcriptions ou secrets pour debug.

## Constraints
- Le clavier Android est un IME natif Kotlin: un crash dans `View.onDraw` ou `onTouchEvent` peut contourner les protections Flutter.
- Le clavier manipule des champs potentiellement privés; la privacy policy existante doit rester prioritaire.
- Le fallback ne doit dépendre ni des thèmes custom ni du panel courant, car ces éléments peuvent être la cause du crash.
- Les diagnostics copiables doivent rester utiles mais courts: préférer contexte d'action, mode, panel, thème, flags, stack class/message redigés.
- `sentry_flutter` version locale: `^9.20.0` dans `pubspec.yaml`.
- Docs officielles consultées: Sentry Flutter docs et Flutter error-reporting docs, verdict `fresh-docs checked` pour la capacité native/Dart de Sentry. Aucun ajout de dépendance Sentry Android standalone ne doit être fait sans nouvelle vérification docs officielle.

## Dependencies
- `sentry_flutter` `^9.20.0` déjà présent.
- Android/Kotlin `InputMethodService`, `View`, `SharedPreferences`, `MethodChannel` existants.
- `AppDiagnostics` et `SensitiveRedactor` côté Flutter.
- `KeyboardStateStore` pour persister/exposer le status natif.
- Official docs checked 2026-05-16:
  - Sentry Flutter: `https://docs.sentry.io/platforms/flutter/` - SDK Flutter pour reporting automatique.
  - Flutter error reporting cookbook: `https://docs.flutter.dev/cookbook/maintenance/error-reporting` - Sentry capture les erreurs Dart et native layers, dont Java/Kotlin/C/C++ Android.
- Fresh docs verdict: `fresh-docs checked` for Sentry behavior; `fresh-docs not needed` for local Kotlin fallback behavior.

## Invariants
- Ne jamais inclure le texte saisi, le contenu clipboard, snippets complets, dictionary complet, transcriptions, tokens, clés API, JWT, emails non redigés ou payloads Supabase dans Sentry ou diagnostics copiables.
- Une erreur clavier ne doit pas modifier les préférences utilisateur sauf bascule temporaire vers fallback runtime; les préférences persistées restent intactes sauf action explicite de l'utilisateur.
- Les actions répétées (`Backspace`, navigation, delete word) doivent arrêter leur runnable quand un geste est annulé, échoue ou entre en fallback.
- Le mode private doit désactiver toute donnée contextuelle sensible dans les logs et breadcrumbs.
- Le status Flutter doit rester parsable même si le diagnostic natif est absent ou ancien.

## Links & Consequences
- `WinFlowzKeyboardView.kt`: entrypoint principal pour crashes de rendu/touch/dispatch/fallback.
- `WinFlowzInputMethodService.kt`: callbacks IME, actions système, refresh runtime preferences, start activity et media/clipboard/voice.
- `KeyboardLayoutModels.kt`: layout builder et panels; source probable de crashes liés aux symboles, panels et compact rows.
- `KeyboardStateStore.kt`: persistence status, préférences et exposition Flutter.
- `MainActivity.kt`: MethodChannel keyboard; doit renvoyer des erreurs typées et status enrichi.
- `android_keyboard_bridge.dart`: parsing du status et exceptions Flutter.
- `settings_screen*.dart`: affichage diagnostics, clear/copy logs et éventuel bouton envoyer plus tard.
- `sentry_bootstrap.dart`: tags/breadcrumbs Flutter existants; doit rester redigé.
- Effet perf: wrappers et persistence d'erreur doivent être légers; pas d'écriture disque à chaque tap réussi.
- Effet sécurité: telemetry uniquement opt-in via DSN/config, redaction obligatoire, pas de PII par défaut.

## Documentation Coherence
- Mettre à jour `docs/technical/android-native.md` avec le contrat de fallback IME et diagnostics redigés.
- Mettre à jour `docs/PLATFORM_BEHAVIOR.md` ou `docs/VERIFICATION.md` avec le protocole QA: `Clear logs`, reproduire une action, `Copy diagnostic`, vérifier Sentry si DSN configuré.
- Ajouter une note dans `shipflow_data/workflow/TEST_LOG.md` après validation réelle Android.
- Changelog interne/public à prévoir au ship: "Keyboard crash recovery and diagnostics".

## Edge Cases
- Crash pendant `onDraw`: fallback doit éviter de réutiliser le snapshot ou thème cassé.
- Crash pendant `dispatch` après un effet visuel/haptic: stopper repeat et ne pas relancer l'action.
- Crash causé par un thème custom invalide ou image manquante: fallback visuel neutre, status `theme fallback`, pas de suppression automatique du thème.
- Crash dans un champ privé: diagnostic sans field content ni clipboard.
- Sentry absent, offline ou init failed: aucune régression, diagnostic local conservé.
- Multi-touch ou pointer manquant pendant fallback: annuler proprement le geste.
- ANR par boucle infinie: Sentry/Android peuvent reporter l'ANR, mais le process peut être tué; les breadcrumbs avant freeze doivent inclure la dernière action sûre.
- Compact/settings/clipboard scroll: une erreur de scroll ne doit pas bloquer le clavier entier.
- MethodChannel appelé sur web/desktop: continuer à renvoyer `unsupported` sans crash.

## Implementation Tasks
- [ ] Tâche 1 : Créer un reporter natif de crash clavier redigé
  - Fichier : `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardCrashReporter.kt`
  - Action : Ajouter une classe singleton/service léger qui normalise contexte, message, stack courte, timestamp UTC, compteur, et écrit le dernier incident dans `SharedPreferences` sans contenu utilisateur.
  - User story link : rendre les erreurs observables et copiables après reproduction.
  - Depends on : none
  - Validate with : `./gradlew :app:compileDebugKotlin -x :app:processDebugResources`
  - Notes : Inclure uniquement mode, panel, layout profile, compact, height scale, theme preset/source, action id, build info si accessible, exception class/message redigés.

- [ ] Tâche 2 : Étendre `KeyboardStateStore` avec le diagnostic natif
  - Fichier : `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardStateStore.kt`
  - Action : Ajouter getters/setters pour `lastKeyboardError`, `lastKeyboardErrorAt`, `keyboardRecoveryCount`, `clearKeyboardDiagnostics()`, et inclure ces champs dans `buildStatusMap()`.
  - User story link : exposer au Flutter settings l'état récupérable du clavier.
  - Depends on : Tâche 1
  - Validate with : compile Kotlin + inspection de `getKeyboardStatus` sur Android.
  - Notes : Ne pas dépasser une taille bornée, par exemple message <= 1200 chars.

- [ ] Tâche 3 : Ajouter un wrapper `runKeyboardSafely` dans la vue clavier
  - Fichier : `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzKeyboardView.kt`
  - Action : Encapsuler `onDraw`, `onTouchEvent`, `dispatch`, `handleLongPress`, `refreshLayout`, `buildSnapshot` et les handlers de scroll/touch sensibles avec capture d'exception, report, arrêt de repeat et fallback.
  - User story link : empêcher une action clavier de tuer l'IME.
  - Depends on : Tâche 1
  - Validate with : compile Kotlin + test manuel réel `#+=`, `Prefs`, `Clip`, `Media`, long press `123`, mode compact.
  - Notes : Éviter récursion infinie si le fallback lui-même échoue; un booléen `recovering` ou compteur par frame est nécessaire.

- [ ] Tâche 4 : Implémenter un snapshot/layout fallback minimal sûr
  - Fichier : `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardLayoutModels.kt`
  - Action : Ajouter `KeyboardLayoutBuilder.safeFallback()` ou équivalent avec 2-3 rangées maximum: status/action limitée, lettres basiques, espace, backspace, enter; pas de thème image, pas de panels, pas de corner shortcuts.
  - User story link : garder un clavier utilisable après crash layout.
  - Depends on : Tâche 3
  - Validate with : test de crash simulé dans builder puis affichage fallback.
  - Notes : Le fallback ne doit pas utiliser `KeyboardKeyValueParser` ni données utilisateur.

- [ ] Tâche 5 : Protéger les callbacks IME et actions système
  - Fichier : `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzInputMethodService.kt`
  - Action : Ajouter un wrapper service-level autour de `onText`, delete/navigation/media/clipboard/voice/settings/theme, `refreshInputState`, `applyRuntimePreferencesToView`, et `startActivity` actions.
  - User story link : récupérer aussi les erreurs hors `View`.
  - Depends on : Tâche 1
  - Validate with : compile Kotlin + manual QA actions clavier dans Termux et autres apps.
  - Notes : Retourner `false` sur action échouée, afficher un status court, ne pas réessayer automatiquement une action qui peut produire un side effect.

- [ ] Tâche 6 : Relier diagnostics natifs au MethodChannel
  - Fichier : `android/app/src/main/kotlin/com/winflowz_app/winflowz_app/MainActivity.kt`
  - Action : Inclure les champs diagnostic dans `getKeyboardStatus`, ajouter une méthode `clearKeyboardDiagnostics` ou intégrer au clear logs, et convertir les erreurs natives attendues en `result.error` typés.
  - User story link : permettre clear/reproduce/copy sans adb.
  - Depends on : Tâches 1-2
  - Validate with : `flutter test test/settings_platform_controllers_test.dart` + compile Kotlin.
  - Notes : Ne pas casser les plateformes non Android.

- [ ] Tâche 7 : Étendre le bridge Flutter et le modèle status
  - Fichier : `lib/core/platform/android_keyboard_bridge.dart`
  - Action : Ajouter champs `lastKeyboardError`, `lastKeyboardErrorAt`, `keyboardRecoveryCount`, méthode `clearKeyboardDiagnostics()`, parsing tolérant.
  - User story link : afficher et copier le diagnostic natif.
  - Depends on : Tâche 6
  - Validate with : `flutter test test/settings_platform_controllers_test.dart`.
  - Notes : Les champs absents doivent donner des valeurs null/zero.

- [ ] Tâche 8 : Unifier diagnostics Flutter + natifs dans Settings
  - Fichier : `lib/features/settings/presentation/settings_screen.dart`
  - Action : Faire inclure le dernier diagnostic clavier natif dans le texte copiable; `Clear logs` doit vider `AppDiagnostics` et le diagnostic clavier natif si Android supporté.
  - User story link : isoler un crash avec Clear logs puis reproduction.
  - Depends on : Tâche 7
  - Validate with : widget/unit tests existants + manual web unsupported.
  - Notes : En web, le bouton clear ne doit pas échouer si le clavier Android est unsupported.

- [ ] Tâche 9 : Afficher un état diagnostic compact dans la section clavier/settings
  - Fichier : `lib/features/settings/presentation/settings_screen_sections.dart`
  - Action : Ajouter une ligne visible mais concise: recovery count, dernier incident horodaté, Sentry enabled/disabled si disponible; garder le bloc logs collapsible.
  - User story link : savoir si la reproduction a produit un signal exploitable.
  - Depends on : Tâches 7-8
  - Validate with : `flutter test test/widget_test.dart` et tests settings.
  - Notes : Ne pas afficher de stack complète hors bloc collapsible.

- [ ] Tâche 10 : Ajouter breadcrumbs/context clavier côté Sentry sans contenu utilisateur
  - Fichier : `lib/core/bootstrap/sentry_bootstrap.dart`
  - Action : Ajouter tags/options si utiles côté Flutter et documenter que les breadcrumbs `AppDiagnostics` restent redigés; si un pont natif direct vers Sentry est envisagé, le faire seulement via SDK déjà inclus par `sentry_flutter` ou après nouvelle vérification docs.
  - User story link : être alerté rapidement côté admin quand un crash/ANR remonte.
  - Depends on : Tâches 1-8
  - Validate with : test manuel build avec `--dart-define=SENTRY_DSN=...` sur environnement de test.
  - Notes : Pas de screenshot, pas de PII, pas de session replay dans ce chantier.

- [ ] Tâche 11 : Ajouter tests de redaction et parsing diagnostic
  - Fichier : `test/settings_platform_controllers_test.dart`
  - Action : Couvrir parsing status avec champs diagnostic, clear logs sans Android, et redaction des messages copiables.
  - User story link : éviter de casser les diagnostics ou d'exposer des secrets.
  - Depends on : Tâches 7-9
  - Validate with : `flutter test test/settings_platform_controllers_test.dart`.
  - Notes : Ajouter un test dédié si le fichier devient trop large.

- [ ] Tâche 12 : Ajouter tests Kotlin ou crash harness local si l'infra le permet
  - Fichier : `android/app/src/test/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardCrashReporterTest.kt`
  - Action : Tester redaction, bornage de taille, fallback counter et status map. Si l'environnement Android unit test n'est pas prêt, créer au minimum une fonction testable pure et documenter la limite.
  - User story link : valider les garde-fous hors QA manuelle.
  - Depends on : Tâches 1-4
  - Validate with : Gradle test disponible ou compile Kotlin si test infra absente.
  - Notes : Ne pas introduire Robolectric lourd sans décision explicite.

- [ ] Tâche 13 : Mettre à jour docs et protocole QA
  - Fichier : `docs/technical/android-native.md`
  - Action : Documenter fallback IME, limites ANR, Sentry, redaction, et procédure `Clear logs -> reproduce -> Copy diagnostic`.
  - User story link : rendre le debug reproductible sans développeur branché en adb.
  - Depends on : Tâches 1-12
  - Validate with : lecture docs + commandes de checks finales.
  - Notes : Ajouter une entrée dans `docs/VERIFICATION.md` si c'est le document QA principal.

## Acceptance Criteria
- [ ] CA 1 : Given le clavier Android réel est actif, when l'utilisateur tape `#+=`, then le panel symboles s'ouvre ou une erreur récupérable est affichée sans fermeture de l'app.
- [ ] CA 2 : Given une exception simulée dans la reconstruction du layout, when `refreshLayout` est appelé, then le clavier affiche un fallback minimal et `keyboardRecoveryCount` augmente.
- [ ] CA 3 : Given une exception simulée dans `dispatch`, when une touche est pressée, then l'action ne se répète pas, le repeat runnable s'arrête et un diagnostic redigé est disponible.
- [ ] CA 4 : Given `Clear logs` est pressé, when l'utilisateur reproduit une action fautive, then `Copy diagnostic` contient uniquement les événements post-clear et inclut le dernier incident clavier.
- [ ] CA 5 : Given un champ privé/password, when une erreur clavier survient, then le diagnostic n'inclut aucun texte saisi, clipboard, suggestion ou contenu utilisateur.
- [ ] CA 6 : Given `SENTRY_DSN` est absent, when une erreur clavier survient, then l'app ne bloque pas et le diagnostic local indique que Sentry est désactivé ou non initialisé.
- [ ] CA 7 : Given `SENTRY_DSN` est configuré en environnement test, when une erreur native/Flutter est capturée, then Sentry reçoit un événement avec tags/breadcrumbs sûrs et sans PII.
- [ ] CA 8 : Given un thème custom invalide ou image manquante, when le clavier rend son background, then le fallback visuel ou thème neutre est utilisé sans supprimer la config utilisateur.
- [ ] CA 9 : Given le panel settings ou clipboard full dépasse la hauteur visible, when l'utilisateur scrolle, then le scroll fonctionne ou échoue sans crash et sans bloquer les touches de sortie.
- [ ] CA 10 : Given la plateforme est web ou desktop, when les settings chargent le status clavier, then les champs diagnostic absents sont tolérés et aucun bouton Android ne crash.

## Test Strategy
- Unit Flutter: `flutter test test/settings_platform_controllers_test.dart` pour parsing status, clear logs et unsupported platforms.
- Widget Flutter: `flutter test test/widget_test.dart` et tests settings existants pour vérifier que les diagnostics restent collapsibles et copiables.
- Kotlin compile: `./gradlew :app:compileDebugKotlin -x :app:processDebugResources` après chaque tranche native.
- Native unit test si disponible: tests purs de reporter/redaction/status map.
- Manual Android QA obligatoire: installer APK debug, activer clavier, `Clear logs`, reproduire `#+=`, `Prefs`, `Clip` long press, `123` long press, compact mode, media app, Termux delete/ctrl flows, puis copier diagnostic.
- Sentry QA optionnelle mais recommandée: build test avec DSN non-production, provoquer une exception contrôlée non sensible, vérifier l'issue et les breadcrumbs.

## Risks
- High: un wrapper dans `onDraw` mal conçu peut créer une boucle fallback/crash et aggraver l'ANR.
- High: diagnostics trop bavards peuvent exposer du contenu utilisateur; redaction et allowlist stricte sont obligatoires.
- Medium: écrire en `SharedPreferences` trop souvent peut affecter perf; écrire seulement sur erreurs/récupérations.
- Medium: Sentry natif peut déjà être inclus via `sentry_flutter`; ajouter `sentry-android` séparément sans docs peut dupliquer ou casser l'init.
- Medium: fallback minimal peut masquer un bug layout si les diagnostics ne gardent pas assez de contexte technique.
- Low: tests Kotlin unitaires peuvent nécessiter une configuration Gradle supplémentaire; ne pas bloquer la protection runtime si l'infra test n'est pas prête.

## Execution Notes
- Lire d'abord `WinFlowzKeyboardView.kt`, `WinFlowzInputMethodService.kt`, `KeyboardStateStore.kt`, `MainActivity.kt`, `android_keyboard_bridge.dart`.
- Implémenter dans l'ordre: reporter natif -> status store -> wrappers view/service -> bridge Flutter -> settings diagnostics -> tests/docs.
- Approche recommandée: allowlist de contexte sûr, pas de logging générique d'objets qui peuvent contenir du texte utilisateur.
- Éviter d'ajouter une dépendance Sentry Android explicite tant que `sentry_flutter` suffit; si besoin réel, refaire `fresh-docs checked` avec docs officielles Sentry Android actuelles.
- Stop condition: si un fallback crash aussi pendant `onDraw`, réduire le fallback à un dessin Canvas sans layout builder et demander arbitrage.
- Stop condition: si les diagnostics nécessitent du contenu utilisateur pour être utiles, refuser ce compromis et chercher des IDs/actions anonymisés.
- Commandes de validation minimales: `flutter test test/settings_platform_controllers_test.dart`, `flutter test test/widget_test.dart`, `./gradlew :app:compileDebugKotlin -x :app:processDebugResources`.

## Open Questions
- None for implementation start. A later product decision can decide whether to add a consent-based `Send diagnostic` button; this spec only requires local copy and Sentry when configured.

## Skill Run History
| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-16 07:23:29 UTC | sf-spec | GPT-5 Codex | Created full spec for keyboard resilience, crash recovery, diagnostics and Sentry-safe reporting. | Draft saved | /sf-ready Keyboard Resilience and Error Management |
| 2026-05-16 07:27:00 UTC | sf-ready | GPT-5 Codex | Validated readiness gate: structure, metadata, user-story alignment, adversarial review, security, language doctrine and fresh-docs evidence. | ready | /sf-start Keyboard Resilience and Error Management |
| 2026-05-16 07:39:27 UTC | sf-start | legacy runtime (gpt3.5-codex unavailable) | Implemented native redacted keyboard crash diagnostics, safe view/service recovery wrappers, fallback snapshot, Flutter bridge/settings copy-clear-status, tests and QA docs. | implemented | /sf-verify Keyboard Resilience and Error Management |
| 2026-05-16 07:41:38 UTC | sf-verify | GPT-5 Codex | Verified implementation against spec with Flutter tests, Kotlin compile, diff check and adversarial review; Android real-device QA, Sentry test correlation and Kotlin unit execution remain unproven. | partial | Manual Android QA for Keyboard Resilience and Error Management |
| 2026-05-16 08:35:48 UTC | sf-test | GPT-5 Codex | Logged Android real-device QA: crash recovery passed for `#+=`, `Prefs`, long press `123`, compact functional behavior and Termux flows; opened bugs for 123 feedback and compact bottom-bar overlap. | fail | /sf-fix BUG-2026-05-16-003 |
| 2026-05-16 08:49:42 UTC | sf-fix | GPT-5 Codex | Fixed Settings Backend Provider diagnostics crash by replacing nested logs expansion with a bounded isolated scroll panel; added widget regression coverage. | fix-attempted | /sf-test --retest BUG-2026-05-16-004 |

## Current Chantier Flow
- sf-spec: done
- sf-ready: ready
- sf-start: implemented - code, tests and docs implemented; real Android QA belongs to verification evidence
- sf-verify: partial - local checks passed; Android QA found usability bugs; Settings diagnostics crash has local fix-attempted pending manual retest; Sentry test event and Kotlin unit test execution still pending
- sf-end: not launched
- sf-ship: not launched

Next command: `/sf-test --retest BUG-2026-05-16-004`.
