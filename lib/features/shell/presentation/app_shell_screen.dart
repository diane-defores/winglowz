import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/platform_capabilities.dart';
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
    final pages = const [
      VoiceScreen(),
      ClipboardScreen(),
      SnippetsScreen(),
      DictionaryScreen(),
      SettingsScreen(),
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
            _OnboardingPanel(onOpenSettings: () => _selectTab(4)),
            Expanded(child: pages[_index]),
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

class _OnboardingPanel extends StatelessWidget {
  const _OnboardingPanel({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Start here',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Settings'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 14),
              Text(
                'Why permissions are needed',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
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
                    'Supabase sync stores your history across devices when configured; local mode keeps testing on this device.',
              ),
            ],
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
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            child: Text(number, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
