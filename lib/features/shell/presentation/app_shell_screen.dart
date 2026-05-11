import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/platform/android_overlay_bridge.dart';
import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../../clipboard/presentation/clipboard_screen.dart';
import '../../dictionary/presentation/dictionary_screen.dart';
import '../../keyboard/presentation/keyboard_preview_screen.dart';
import '../../settings/application/settings_store_provider.dart';
import '../../settings/domain/onboarding_permission_contract.dart';
import '../../settings/domain/settings_store.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../snippets/presentation/snippets_screen.dart';
import '../../voice/presentation/voice_screen.dart';

class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen>
    with WidgetsBindingObserver {
  static const _unsupportedOverlayStatus = AndroidOverlayStatus(
    enabled: false,
    requestedEnabled: false,
    running: false,
    overlayPermissionGranted: false,
    accessibilityPermissionGranted: false,
    recordAudioGranted: false,
    deliveryMode: OverlayDeliveryMode.clipboardOnly,
    sizeScale: 1,
    opacity: 0.8,
    eventQueueSize: 0,
    serviceState: 'unsupported',
  );

  int _index = 0;
  bool _onboardingVisible = false;
  bool _onboardingDismissed = false;
  bool _onboardingBusy = false;
  final List<int> _tabHistory = [0];
  OnboardingReadiness? _onboardingReadiness;
  String? _onboardingMessage;
  UserSettingsSnapshot? _onboardingSettings;
  AndroidOverlayStatus? _onboardingOverlayStatus;
  AndroidKeyboardStatus? _onboardingKeyboardStatus;

  void _selectTab(int value) {
    if (value == _index) {
      return;
    }
    const titles = [
      'Voice',
      'Clipboard',
      'Keyboard',
      'Snippets',
      'Dictionary',
      'Settings',
    ];
    AppDiagnostics.record(
      'tab_select',
      '${titles[_index]} -> ${titles[value]}',
    );
    setState(() {
      _index = value;
      _tabHistory.remove(value);
      _tabHistory.add(value);
    });
  }

  void _goBackInTabs() {
    if (_tabHistory.length <= 1) {
      return;
    }
    setState(() {
      _tabHistory.removeLast();
      _index = _tabHistory.last;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_refreshOnboardingState);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshOnboardingState();
    }
  }

  Future<AndroidOverlayStatus> _loadOverlayStatusForOnboarding() async {
    if (!PlatformCapabilities.overlaySupported) {
      return _unsupportedOverlayStatus;
    }
    try {
      return await AndroidOverlayBridge.getStatus();
    } catch (_) {
      return _unsupportedOverlayStatus;
    }
  }

  Future<AndroidKeyboardStatus> _loadKeyboardStatusForOnboarding() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return AndroidKeyboardStatus.unsupported();
    }
    try {
      return await AndroidKeyboardBridge.getStatus();
    } catch (_) {
      return AndroidKeyboardStatus.unsupported();
    }
  }

  Future<void> _saveOnboardingSettings(UserSettingsSnapshot settings) async {
    try {
      await ref.read(settingsStoreProvider).save(settings);
    } catch (_) {
      // Onboarding should stay operational even if settings persistence fails.
    }
  }

  Future<void> _refreshOnboardingState() async {
    if (!PlatformCapabilities.isAndroid ||
        !PlatformCapabilities.overlaySupported) {
      if (!mounted) {
        return;
      }
      setState(() {
        _onboardingReadiness = const OnboardingReadiness(
          platformSupported: false,
          steps: <OnboardingStepProgress>[],
          currentStep: 0,
          onboardingCompleted: false,
        );
        _onboardingOverlayStatus = _unsupportedOverlayStatus;
        _onboardingKeyboardStatus = AndroidKeyboardStatus.unsupported();
        _onboardingVisible = false;
        _onboardingDismissed = true;
      });
      return;
    }

    setState(() {
      _onboardingBusy = true;
      _onboardingMessage = null;
    });

    try {
      final store = ref.read(settingsStoreProvider);
      final rawSettings = await store.load();
      final overlayStatus = await _loadOverlayStatusForOnboarding();
      final keyboardStatus = await _loadKeyboardStatusForOnboarding();
      final readiness = evaluateOnboardingReadiness(
        isPlatformSupported: PlatformCapabilities.overlaySupported,
        overlayStatus: overlayStatus,
        keyboardStatus: keyboardStatus,
        persistedStep: rawSettings.onboardingCurrentStep,
        onboardingCompleted: rawSettings.onboardingCompleted,
        accessibilitySkipped: rawSettings.onboardingAccessibilitySkipped,
        microphoneSkipped: rawSettings.onboardingMicrophoneSkipped,
      );

      var nextSettings = rawSettings;
      if (rawSettings.onboardingCurrentStep != readiness.currentStep ||
          rawSettings.onboardingLastSeenAt == null) {
        nextSettings = rawSettings.copyWith(
          onboardingCurrentStep: readiness.currentStep,
          onboardingLastSeenAt: DateTime.now().toUtc(),
        );
        await _saveOnboardingSettings(nextSettings);
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _onboardingReadiness = readiness;
        _onboardingSettings = nextSettings;
        _onboardingOverlayStatus = overlayStatus;
        _onboardingKeyboardStatus = keyboardStatus;
        _onboardingBusy = false;
        if (readiness.shouldShowOnboarding && !_onboardingDismissed) {
          _onboardingVisible = true;
        }
        if (!readiness.shouldShowOnboarding) {
          _onboardingVisible = false;
          _onboardingDismissed = true;
        }
      });

      AppDiagnostics.record(
        'onboarding_refresh',
        'current=${readiness.currentStep}/${readiness.steps.length};mandatory=${readiness.hasPendingMandatory};recommended=${readiness.hasPendingRecommended};visible=${_onboardingVisible}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _onboardingBusy = false;
        _onboardingMessage = 'Impossible de charger l’onboarding: $error';
      });
    }
  }

  Future<void> _openCurrentStepPrimaryAction() async {
    final step = _onboardingReadiness?.activeStep?.definition;
    if (step == null) {
      return;
    }
    setState(() {
      _onboardingBusy = true;
      _onboardingMessage = null;
    });
    try {
      AppDiagnostics.record('onboarding_primary_action', step.id.name);
      if (step.id == OnboardingStepId.overlay) {
        await AndroidOverlayBridge.openPermissionSettings();
      } else if (step.id == OnboardingStepId.keyboardIme) {
        await AndroidKeyboardBridge.openInputMethodSettings();
      } else if (step.id == OnboardingStepId.accessibility) {
        await AndroidOverlayBridge.openAccessibilitySettings();
      } else {
        await AndroidOverlayBridge.openAppSettings();
      }
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _onboardingMessage =
                'Action impossible (${error.code}): ${error.message}',
      );
    } on AndroidKeyboardBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _onboardingMessage =
                'Action clavier impossible (${error.code}): ${error.message}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _onboardingMessage = 'Action impossible: $error');
    } finally {
      if (!mounted) {
        return;
      }
      setState(() => _onboardingBusy = false);
      await _refreshOnboardingState();
    }
  }

  Future<void> _openCurrentStepSecondaryAction() async {
    final step = _onboardingReadiness?.activeStep?.definition;
    if (step == null || step.id != OnboardingStepId.keyboardIme) {
      return;
    }
    setState(() {
      _onboardingBusy = true;
      _onboardingMessage = null;
    });
    try {
      await AndroidKeyboardBridge.showInputMethodPicker();
    } on AndroidKeyboardBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _onboardingMessage =
                'Impossible d’ouvrir le sélecteur (${error.code}): ${error.message}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _onboardingMessage = 'Impossible d’ouvrir le sélecteur: $error',
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() => _onboardingBusy = false);
      await _refreshOnboardingState();
    }
  }

  Future<void> _skipCurrentStep() async {
    final step = _onboardingReadiness?.activeStep;
    if (step == null || step.isMandatory) {
      return;
    }
    final settings = _onboardingSettings;
    if (settings == null) {
      return;
    }
    final updated = step.definition.id == OnboardingStepId.accessibility
        ? settings.copyWith(
            onboardingAccessibilitySkipped: true,
            onboardingLastSeenAt: DateTime.now().toUtc(),
          )
        : settings.copyWith(
            onboardingMicrophoneSkipped: true,
            onboardingLastSeenAt: DateTime.now().toUtc(),
          );
    await _saveOnboardingSettings(updated);
    if (!mounted) {
      return;
    }
    setState(() {
      _onboardingSettings = updated;
    });
    await _refreshOnboardingState();
  }

  Future<void> _completeOnboarding() async {
    final readiness = _onboardingReadiness;
    final settings = _onboardingSettings;
    if (readiness == null || settings == null || !readiness.shouldShowCompletion) {
      return;
    }
    setState(() {
      _onboardingBusy = true;
    });
    try {
      await _saveOnboardingSettings(
        settings.copyWith(
          onboardingCompleted: true,
          onboardingLastSeenAt: DateTime.now().toUtc(),
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _onboardingVisible = false;
        _onboardingDismissed = true;
      });
      await _refreshOnboardingState();
    } finally {
      if (mounted) {
        setState(() => _onboardingBusy = false);
      }
    }
  }

  Future<void> _pauseOnboarding() async {
    final settings = _onboardingSettings;
    if (settings != null) {
      await _saveOnboardingSettings(
        settings.copyWith(onboardingLastSeenAt: DateTime.now().toUtc()),
      );
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _onboardingVisible = false;
      _onboardingDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      VoiceScreen(),
      ClipboardScreen(),
      const KeyboardPreviewScreen(),
      SnippetsScreen(),
      DictionaryScreen(),
      SettingsScreen(
        onResumeOnboarding: () {
          setState(() {
            _onboardingDismissed = false;
            _onboardingVisible = true;
          });
          _refreshOnboardingState();
        },
      ),
    ];
    const titles = [
      'Voice',
      'Clipboard',
      'Keyboard',
      'Snippets',
      'Dictionary',
      'Settings',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= AppBreakpoints.navigationRail;
        return PopScope(
          canPop: _tabHistory.length <= 1,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _goBackInTabs();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: Text('WinFlowzApp • ${titles[_index]}')),
            body: Row(
              children: [
                if (useRail)
                  NavigationRail(
                    extended:
                        constraints.maxWidth >= AppBreakpoints.navigationRailExtended,
                    selectedIndex: _index,
                    onDestinationSelected: _selectTab,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.keyboard_voice_outlined),
                        label: Text('Voice'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.content_paste_outlined),
                        label: Text('Clipboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.keyboard_outlined),
                        label: Text('Keyboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.text_snippet_outlined),
                        label: Text('Snippets'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.auto_fix_high_outlined),
                        label: Text('Dictionary'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                Expanded(
                  child: Column(
                    children: [
                      if (!PlatformCapabilities.localSpeechSupported)
                        const MaterialBanner(
                          content: Text(
                            'Local speech is unavailable on Linux. Use advanced Whisper mode.',
                          ),
                          actions: [SizedBox.shrink()],
                        ),
                      if (!PlatformCapabilities.overlaySupported)
                        const MaterialBanner(
                          content: Text(
                            'Android overlay is unavailable on this platform.',
                          ),
                          actions: [SizedBox.shrink()],
                        ),
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(child: pages[_index]),
                            if (_onboardingVisible)
                              _OnboardingOverlay(
                                readiness: _onboardingReadiness,
                                isBusy: _onboardingBusy,
                                message: _onboardingMessage,
                                onClose: _pauseOnboarding,
                                onOpenSettings: () => _selectTab(5),
                                onPrimaryAction: _openCurrentStepPrimaryAction,
                                onSecondaryAction:
                                    _onboardingReadiness?.activeStep?.definition
                                                .id ==
                                            OnboardingStepId.keyboardIme
                                        ? _openCurrentStepSecondaryAction
                                        : null,
                                onSkip: _skipCurrentStep,
                                onRefresh: _refreshOnboardingState,
                                onComplete: _completeOnboarding,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: useRail
                ? null
                : NavigationBar(
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    selectedIndex: _index,
                    onDestinationSelected: _selectTab,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.keyboard_voice_outlined),
                        label: 'Voice',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.content_paste_outlined),
                        label: 'Clipboard',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.keyboard_outlined),
                        label: 'Keyboard',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.text_snippet_outlined),
                        label: 'Snippets',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.auto_fix_high_outlined),
                        label: 'Dictionary',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.settings_outlined),
                        label: 'Settings',
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _OnboardingOverlay extends StatelessWidget {
  const _OnboardingOverlay({
    required this.readiness,
    required this.isBusy,
    required this.message,
    required this.onClose,
    required this.onOpenSettings,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onSkip,
    required this.onRefresh,
    required this.onComplete,
  });

  final OnboardingReadiness? readiness;
  final bool isBusy;
  final String? message;
  final Future<void> Function() onClose;
  final VoidCallback onOpenSettings;
  final Future<void> Function() onPrimaryAction;
  final Future<void> Function()? onSecondaryAction;
  final Future<void> Function() onSkip;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final activeStep = readiness?.activeStep;
    return Positioned.fill(
      child: BlockSemantics(
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: 'Onboarding setup guide',
          child: ColoredBox(
            color: AppColors.overlayScrim,
            child: Center(
              child: SafeArea(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayoutMetrics.onboardingOverlayMaxWidth,
                    maxHeight: AppLayoutMetrics.onboardingOverlayMaxHeight,
                  ),
                  child: Material(
                    elevation: AppElevation.overlay,
                    shadowColor: AppColors.borderLight,
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      padding: AppInsets.onboarding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              AppGaps.horizontalX2,
                              Expanded(
                                child: Text(
                                  'Configuration WinFlowzApp',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Fermer (reprendre plus tard)',
                                onPressed: () => onClose(),
                                icon: const Icon(Icons.close_outlined),
                              ),
                            ],
                          ),
                          AppGaps.x2,
                          if (readiness == null ||
                              !readiness.platformSupported)
                            const Text('Onboarding indisponible sur ce terminal.')
                          else if (readiness.shouldShowCompletion)
                            _OnboardingCompletionContent(
                              readiness: readiness,
                              isBusy: isBusy,
                              onOpenSettings: onOpenSettings,
                              onComplete: onComplete,
                            )
                          else if (activeStep == null)
                            const Text('Onboarding en cours de vérification...')
                          else
                            _OnboardingStepContent(
                              readiness: readiness,
                              step: activeStep,
                              isBusy: isBusy,
                              onPrimaryAction: onPrimaryAction,
                              onSecondaryAction: onSecondaryAction,
                              onSkip: onSkip,
                              onRefresh: onRefresh,
                              onOpenSettings: onOpenSettings,
                            ),
                          if (message != null) ...[
                            AppGaps.x2,
                            Text(
                              message!,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingStepContent extends StatelessWidget {
  const _OnboardingStepContent({
    required this.readiness,
    required this.step,
    required this.isBusy,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onSkip,
    required this.onRefresh,
    required this.onOpenSettings,
  });

  final OnboardingReadiness readiness;
  final OnboardingStepProgress step;
  final bool isBusy;
  final Future<void> Function() onPrimaryAction;
  final Future<void> Function()? onSecondaryAction;
  final Future<void> Function() onSkip;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final definition = step.definition;
    final statusColor = step.satisfied ? AppColors.success : AppColors.warning;
    final status = step.satisfied ? 'OK' : 'En attente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              step.satisfied ? Icons.check_circle : Icons.schedule,
              color: statusColor,
            ),
            AppGaps.horizontalX2,
            Expanded(
              child: Text(
                '${definition.title} — Étape ${readiness.currentStep + 1}/${readiness.steps.length}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderSubtle),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AppSpacing.x1,
                  ),
              child: Text(
                definition.category == OnboardingStepCategory.mandatory
                    ? 'Obligatoire'
                    : 'Recommandé',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
        AppGaps.x1,
        Text(
          '${definition.description}. Status: $status',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        AppGaps.x2,
        Text(definition.why),
        AppGaps.x1,
        _OnboardingPathHint(
          icon: Icons.location_on_outlined,
          title: 'Où la trouver',
          text: definition.whereToFind,
        ),
        if (step.blockerReason != null) ...[
          AppGaps.x2,
          Text(
            step.blockerReason!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
        AppGaps.x2,
        Wrap(
          spacing: AppSpacing.x2,
          runSpacing: AppSpacing.x2,
          children: [
            if (isBusy)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (!step.satisfied)
              ElevatedButton(
                onPressed: () => onPrimaryAction(),
                child: Text(definition.openActionLabel),
              )
            else
              OutlinedButton(
                onPressed: () => onRefresh(),
                child: const Text('Re-vérifier'),
              ),
            if (!isBusy && onSecondaryAction != null)
              OutlinedButton(
                onPressed: () => onSecondaryAction?.call(),
                child: Text(definition.secondaryActionLabel ?? ''),
              ),
            if (!isBusy && !step.isMandatory)
              TextButton(
                onPressed: () => onSkip(),
                child: const Text('Plus tard'),
              ),
            if (!isBusy)
              TextButton(
                onPressed: onOpenSettings,
                child: const Text('Paramètres'),
              ),
          ],
        ),
      ],
    );
  }
}

class _OnboardingCompletionContent extends StatelessWidget {
  const _OnboardingCompletionContent({
    required this.readiness,
    required this.isBusy,
    required this.onOpenSettings,
    required this.onComplete,
  });

  final OnboardingReadiness readiness;
  final bool isBusy;
  final VoidCallback onOpenSettings;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final mandatory = readiness.steps
        .where((step) => step.isMandatory)
        .toList(growable: false);
    final recommended = readiness.steps
        .where((step) => step.isRecommended)
        .toList(growable: false);
    final mandatoryDone = mandatory.where((step) => step.completed).length;
    final recommendedDone = recommended.where((step) => step.completed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Les prérequis sont prêts',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        AppGaps.x2,
        Text('Obligatoire: $mandatoryDone/${mandatory.length}'),
        Text('Recommandé: $recommendedDone/${recommended.length}'),
        AppGaps.x2,
        for (final step in readiness.steps)
          _OnboardingPathHint(
            icon: step.isMandatory
                ? Icons.lock_outline
                : Icons.lightbulb_outline,
            title: step.definition.title,
            text: step.completed
                ? 'OK'
                : 'Recommandé: ${step.definition.whereToFind}',
          ),
        AppGaps.x3,
        Wrap(
          spacing: AppSpacing.x2,
          runSpacing: AppSpacing.x2,
          children: [
            if (isBusy)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              ElevatedButton(
                onPressed: () => onComplete(),
                child: const Text('Terminer'),
              ),
            if (!isBusy)
              TextButton(
                onPressed: onOpenSettings,
                child: const Text('Paramètres'),
              ),
          ],
        ),
      ],
    );
  }
}

class _OnboardingPathHint extends StatelessWidget {
  const _OnboardingPathHint({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.stack,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppIconMetrics.sm,
            color: Theme.of(context).colorScheme.secondary,
          ),
          AppGaps.horizontalX3,
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
