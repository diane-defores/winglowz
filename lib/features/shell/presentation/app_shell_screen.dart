import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../../clipboard/presentation/clipboard_screen.dart';
import '../../dictionary/presentation/dictionary_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../snippets/presentation/snippets_screen.dart';
import '../../voice/presentation/voice_screen.dart';

class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  int _index = 0;
  bool _onboardingVisible = false;
  final List<int> _tabHistory = [0];

  void _selectTab(int value) {
    if (value == _index) {
      return;
    }
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
  Widget build(BuildContext context) {
    final pages = [
      VoiceScreen(),
      ClipboardScreen(),
      SnippetsScreen(),
      DictionaryScreen(),
      SettingsScreen(
        onResumeOnboarding: () => setState(() => _onboardingVisible = true),
      ),
    ];
    const titles = ['Voice', 'Clipboard', 'Snippets', 'Dictionary', 'Settings'];

    return PopScope(
      canPop: _tabHistory.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBackInTabs();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('VoiceFlowz • ${titles[_index]}')),
        body: Column(
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
                      onClose: () => setState(() => _onboardingVisible = false),
                      onOpenSettings: () => _selectTab(4),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
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
  }
}

class _OnboardingOverlay extends StatelessWidget {
  const _OnboardingOverlay({
    required this.onClose,
    required this.onOpenSettings,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
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
                              'Start here',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close onboarding',
                            onPressed: onClose,
                            icon: const Icon(Icons.close_outlined),
                          ),
                        ],
                      ),
                      AppGaps.x2,
                      const _OnboardingStep(
                        number: '1',
                        text: 'Enable VoiceFlowz Keyboard in Settings.',
                      ),
                      const _OnboardingStep(
                        number: '2',
                        text: 'Switch to it from any Android text field.',
                      ),
                      const _OnboardingStep(
                        number: '3',
                        text:
                            'Use Voice for dictation tests and Clipboard for captured text.',
                      ),
                      AppGaps.x4,
                      Text(
                        'Why permissions are needed',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      AppGaps.x2,
                      const _PermissionNote(
                        icon: Icons.keyboard_outlined,
                        title: 'Keyboard',
                        text:
                            'Android must enable VoiceFlowz as an input method before it can type dictated text into other apps.',
                      ),
                      const _PermissionNote(
                        icon: Icons.mic_none_outlined,
                        title: 'Microphone',
                        text:
                            'Dictation needs microphone access only while recording speech.',
                      ),
                      const _PermissionNote(
                        icon: Icons.bubble_chart_outlined,
                        title: 'Overlay',
                        text:
                            'The floating control lets you start or stop dictation while another app is open.',
                      ),
                      const _PermissionNote(
                        icon: Icons.accessibility_new_outlined,
                        title: 'Accessibility',
                        text:
                            'Accessibility is optional but required when VoiceFlowz should insert text directly into the active field instead of falling back to the clipboard.',
                      ),
                      const _PermissionNote(
                        icon: Icons.cloud_outlined,
                        title: 'Cloud sync',
                        text:
                            'Cloud sync will use the configured backend adapter when available; local mode keeps testing on this device.',
                      ),
                      AppGaps.x3,
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: onOpenSettings,
                          icon: const Icon(Icons.settings_outlined),
                          label: const Text('Settings'),
                        ),
                      ),
                    ],
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

class _PermissionNote extends StatelessWidget {
  const _PermissionNote({
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

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.stack,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: AppIconMetrics.stepAvatarRadius,
            child: Text(number, style: Theme.of(context).textTheme.labelMedium),
          ),
          AppGaps.horizontalX3,
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
