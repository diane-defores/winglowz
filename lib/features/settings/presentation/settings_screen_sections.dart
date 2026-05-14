part of "settings_screen.dart";

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.themeMode, required this.onChanged});

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Appearance',
      subtitle: 'Uses the WinFlowz palette and shared Flowz interface tokens.',
      child: SegmentedButton<AppThemeMode>(
        segments: const [
          ButtonSegment(
            value: AppThemeMode.system,
            icon: Icon(Icons.brightness_auto_outlined),
            label: Text('System'),
          ),
          ButtonSegment(
            value: AppThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Light'),
          ),
          ButtonSegment(
            value: AppThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Dark'),
          ),
        ],
        selected: {themeMode},
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}

class _BackendProviderSection extends StatelessWidget {
  const _BackendProviderSection({
    required this.configured,
    required this.diagnosticText,
    required this.onCopyDiagnostic,
  });

  final bool configured;
  final String diagnosticText;
  final VoidCallback onCopyDiagnostic;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Backend provider',
      subtitle: configured
          ? 'Firebase is the active backend adapter. Legacy Supabase may remain unconfigured.'
          : 'Remote sync is not configured. WinFlowz stays in local mode.',
      leading: const Icon(Icons.storage_outlined),
      stretch: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(diagnosticText),
          AppGaps.x3,
          OutlinedButton.icon(
            onPressed: onCopyDiagnostic,
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy diagnostic'),
          ),
        ],
      ),
    );
  }
}

class _SecretsSection extends StatelessWidget {
  const _SecretsSection({
    required this.storageStatusAsync,
    required this.openAiController,
    required this.anthropicController,
    required this.message,
    required this.saving,
    required this.onSave,
    required this.onSignOut,
  });

  final AsyncValue<SecretStorageStatus> storageStatusAsync;
  final TextEditingController openAiController;
  final TextEditingController anthropicController;
  final String? message;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Local AI keys',
      subtitle: 'Stored on this device and kept out of synced preferences.',
      leading: const Icon(Icons.key_outlined),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          storageStatusAsync.when(
            data: (status) {
              if (status == SecretStorageStatus.available) {
                return const ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Local secure storage available'),
                );
              }
              return const ListTile(
                leading: Icon(Icons.warning_amber_outlined),
                title: Text('Secure storage degraded'),
                subtitle: Text(
                  'Web/Linux may not provide equivalent keystore/keychain guarantees. '
                  'Treat cloud AI mode as degraded until explicitly accepted.',
                ),
              );
            },
            loading: () =>
                const ListTile(title: Text('Checking storage capabilities...')),
            error: (error, stack) =>
                ListTile(title: Text('Storage status error: $error')),
          ),
          AppGaps.x3,
          TextField(
            controller: openAiController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'OpenAI API key'),
          ),
          AppGaps.x3,
          TextField(
            controller: anthropicController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Anthropic API key'),
          ),
          if (message != null) ...[AppGaps.x3, Text(message!)],
          AppGaps.x4,
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: saving ? null : onSave,
                  child: const Text('Save local keys'),
                ),
              ),
              AppGaps.horizontalX3,
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : onSignOut,
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlatformCapabilitiesSection extends StatelessWidget {
  const _PlatformCapabilitiesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Platform capabilities',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        AppGaps.x2,
        AppStatusCard(
          icon: Icons.mic_none,
          title: PlatformCapabilities.localSpeechSupported
              ? 'Local speech available'
              : 'Local speech unavailable',
          subtitle: 'Linux falls back to advanced recording + Whisper.',
        ),
        AppStatusCard(
          icon: Icons.bubble_chart_outlined,
          title: PlatformCapabilities.overlaySupported
              ? 'Android overlay supported'
              : 'Android overlay unavailable on this platform',
        ),
        AppStatusCard(
          icon: Icons.keyboard_outlined,
          title: PlatformCapabilities.keyboardImeSupported
              ? 'Android keyboard IME supported'
              : 'Android keyboard IME unavailable on this platform',
          subtitle:
              'WinFlowz keyboard is Android-only and runs as a native input method.',
        ),
      ],
    );
  }
}

class _KeyboardSettingsSection extends StatelessWidget {
  const _KeyboardSettingsSection({
    required this.status,
    required this.busy,
    required this.onRefresh,
    required this.onOpenInputSettings,
    required this.onShowPicker,
    required this.onOpenCornerShortcuts,
    required this.onPreferenceChanged,
  });

  final AndroidKeyboardStatus? status;
  final bool busy;
  final VoidCallback onRefresh;
  final VoidCallback onOpenInputSettings;
  final VoidCallback onShowPicker;
  final VoidCallback onOpenCornerShortcuts;
  final _KeyboardPreferenceChanged onPreferenceChanged;

  String get _enabledLanguages {
    final frenchEnabled = status?.frenchLanguageEnabled ?? true;
    final englishEnabled = status?.englishLanguageEnabled ?? true;
    if (frenchEnabled && englishEnabled) {
      return 'fr+en';
    }
    if (frenchEnabled) {
      return 'fr';
    }
    if (englishEnabled) {
      return 'en';
    }
    return 'none';
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'WinFlowz keyboard',
      subtitle: 'Android input method status, layout, gestures, and privacy.',
      leading: const Icon(Icons.keyboard_outlined),
      child: Column(
        children: [
          ListTile(
            title: const Text('Runtime status'),
            subtitle: Text(
              'enabled=${status?.enabled ?? false} | '
              'active=${status?.active ?? false} | '
              'layout=${status?.layoutProfile.name ?? 'qwerty'} | '
              'corners=${status?.cornerModeEnabled ?? false} | '
              'languages=$_enabledLanguages | '
              'privacy=${status?.privacyMode.name ?? 'auto'}',
            ),
            trailing: busy
                ? const SizedBox.square(
                    dimension: AppIconMetrics.sm,
                    child: CircularProgressIndicator(
                      strokeWidth: AppIconMetrics.progressStroke,
                    ),
                  )
                : IconButton(
                    tooltip: 'Refresh keyboard status',
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
          ),
          if (status?.enabled == false)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Keyboard not enabled'),
              subtitle: Text(
                'Enable WinFlowz keyboard in Android input method settings, then switch to it from any text field.',
              ),
            ),
          Padding(
            padding: AppInsets.keyboardControls,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : onOpenInputSettings,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Input settings'),
                  ),
                ),
                AppGaps.horizontalX2,
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : onShowPicker,
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Switch keyboard'),
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            value: status?.voiceEnabled ?? true,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(voiceEnabled: value),
            title: const Text('Keyboard dictation'),
            subtitle: const Text(
              'Uses Android speech recognition from the IME when microphone permission is available.',
            ),
          ),
          SwitchListTile(
            value: status?.clipboardSyncDesired ?? false,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(clipboardSyncDesired: value),
            title: const Text('Keyboard clipboard sync intent'),
            subtitle: const Text(
              'Opt-in flag for eligible keyboard clipboard items. Sensitive/private fields still disable capture.',
            ),
          ),
          SwitchListTile(
            value: status?.mediaControlsEnabled ?? true,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(mediaControlsEnabled: value),
            title: const Text('Keyboard media play/pause'),
            subtitle: const Text(
              'Sends a generic Android media key without reading media metadata.',
            ),
          ),
          Padding(
            padding: AppInsets.keyboardPrivacy,
            child: DropdownButtonFormField<KeyboardLayoutProfile>(
              initialValue:
                  status?.layoutProfile ?? KeyboardLayoutProfile.qwerty,
              decoration: const InputDecoration(
                labelText: 'Keyboard letter layout',
              ),
              items: const [
                DropdownMenuItem(
                  value: KeyboardLayoutProfile.qwerty,
                  child: Text('QWERTY'),
                ),
                DropdownMenuItem(
                  value: KeyboardLayoutProfile.azerty,
                  child: Text('AZERTY'),
                ),
              ],
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(
                      layoutProfile: value ?? KeyboardLayoutProfile.qwerty,
                    ),
            ),
          ),
          SwitchListTile(
            value: status?.cornerModeEnabled ?? false,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(cornerModeEnabled: value),
            title: const Text('Swipe-corner mode'),
            subtitle: const Text(
              'When enabled, key swipes toward corners insert secondary characters.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.open_in_full_outlined),
            title: const Text('Corner shortcuts'),
            subtitle: Text(
              'Preset=${status?.cornerPresetId ?? KeyboardCornerPresetCatalog.frenchAccents}. Configure per-key corner actions.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: busy ? null : onOpenCornerShortcuts,
          ),
          SwitchListTile(
            value: status?.frenchLanguageEnabled ?? true,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(frenchLanguageEnabled: value),
            title: const Text('French suggestions'),
            subtitle: const Text(
              'Enables the built-in French suggestion dictionary.',
            ),
          ),
          SwitchListTile(
            value: status?.englishLanguageEnabled ?? true,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(englishLanguageEnabled: value),
            title: const Text('English suggestions'),
            subtitle: const Text(
              'Enables the built-in English suggestion dictionary.',
            ),
          ),
          SwitchListTile(
            value: status?.spellingSuggestionsEnabled ?? true,
            onChanged: busy
                ? null
                : (value) =>
                      onPreferenceChanged(spellingSuggestionsEnabled: value),
            title: const Text('Spelling suggestions'),
            subtitle: const Text(
              'Shows candidate words above the native keyboard. Text expansion rules still run separately.',
            ),
          ),
          SwitchListTile(
            value: status?.keyVibrationEnabled ?? true,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(keyVibrationEnabled: value),
            title: const Text('Key vibration'),
            subtitle: const Text('Toggles keyboard haptic feedback.'),
          ),
          SwitchListTile(
            value: status?.keySoundEnabled ?? false,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(keySoundEnabled: value),
            title: const Text('Key sound'),
            subtitle: const Text('Toggles keyboard click sounds.'),
          ),
          SwitchListTile(
            value: status?.specialKeyCornersEnabled ?? false,
            onChanged: busy
                ? null
                : (value) =>
                      onPreferenceChanged(specialKeyCornersEnabled: value),
            title: const Text('Special-key corner gestures'),
            subtitle: const Text(
              'Allows swipe-corner alternates on non-letter keys when corner mode is enabled.',
            ),
          ),
          SwitchListTile(
            value: status?.doubleSpacePeriodEnabled ?? true,
            onChanged: busy
                ? null
                : (value) =>
                      onPreferenceChanged(doubleSpacePeriodEnabled: value),
            title: const Text('Double-space to period'),
            subtitle: const Text(
              'Transforms double space into period-space in standard text fields.',
            ),
          ),
          SwitchListTile(
            value: status?.punctuationAutoSpacingEnabled ?? false,
            onChanged: busy
                ? null
                : (value) =>
                      onPreferenceChanged(punctuationAutoSpacingEnabled: value),
            title: const Text('Punctuation auto-spacing'),
            subtitle: const Text(
              'Adds basic spacing around punctuation for standard text fields.',
            ),
          ),
          SwitchListTile(
            value: status?.debugTouchOverlayEnabled ?? false,
            onChanged: busy
                ? null
                : (value) =>
                      onPreferenceChanged(debugTouchOverlayEnabled: value),
            title: const Text('Keyboard touch debug overlay'),
            subtitle: const Text(
              'Shows key bounds and gesture classifier diagnostics on the native keyboard.',
            ),
          ),
          Padding(
            padding: AppInsets.keyboardPrivacy,
            child: DropdownButtonFormField<KeyboardPrivacyMode>(
              initialValue: status?.privacyMode ?? KeyboardPrivacyMode.auto,
              decoration: const InputDecoration(
                labelText: 'Keyboard privacy mode',
              ),
              items: const [
                DropdownMenuItem(
                  value: KeyboardPrivacyMode.auto,
                  child: Text('Auto: detect sensitive fields'),
                ),
                DropdownMenuItem(
                  value: KeyboardPrivacyMode.strict,
                  child: Text('Strict: private mode everywhere'),
                ),
                DropdownMenuItem(
                  value: KeyboardPrivacyMode.standard,
                  child: Text('Standard: normal fields only'),
                ),
              ],
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(
                      privacyMode: value ?? KeyboardPrivacyMode.auto,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlaySettingsSection extends StatelessWidget {
  const _OverlaySettingsSection({
    required this.status,
    required this.busy,
    required this.onToggle,
    required this.onAppearanceChanged,
    required this.onOpenOverlaySettings,
    required this.onOpenAccessibilitySettings,
    required this.onStart,
    required this.onStop,
    required this.onCancel,
  });

  final AndroidOverlayStatus? status;
  final bool busy;
  final ValueChanged<bool> onToggle;
  final _OverlayAppearanceChanged onAppearanceChanged;
  final VoidCallback onOpenOverlaySettings;
  final VoidCallback onOpenAccessibilitySettings;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Android overlay',
      subtitle: 'Floating bubble permissions, recording runtime, and delivery.',
      leading: const Icon(Icons.bubble_chart_outlined),
      child: Column(
        children: [
          SwitchListTile(
            value: status?.enabled ?? false,
            onChanged: (status?.overlayPermissionGranted ?? false) && !busy
                ? onToggle
                : null,
            title: const Text('Enable Android overlay bridge'),
            subtitle: Text(
              (status?.enabled ?? false)
                  ? 'Overlay bridge enabled. The floating Android bubble should be visible.'
                  : (status?.overlayPermissionGranted ?? false)
                  ? 'Overlay permission granted. Turn this on to show the floating bubble.'
                  : 'Overlay permission required before enabling.',
            ),
          ),
          ListTile(
            title: const Text('Overlay runtime status'),
            subtitle: Text(
              'enabled=${status?.enabled ?? false} | '
              'requested=${status?.requestedEnabled ?? false} | '
              'running=${status?.running ?? false} | '
              'service=${status?.serviceState ?? 'unknown'} | '
              'delivery=${status?.deliveryMode.name ?? 'clipboardOnly'}',
            ),
          ),
          if ((status?.lastNativeEvent ?? 'none') != 'none')
            ListTile(
              title: const Text('Last native overlay event'),
              subtitle: Text(status?.lastNativeEvent ?? 'none'),
            ),
          if (status?.accessibilityPermissionGranted == false)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Accessibility disabled'),
              subtitle: Text(
                'Overlay dictation will deliver clipboard only until accessibility service is enabled.',
              ),
            ),
          Padding(
            padding: AppInsets.keyboardPrivacy,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Bubble size')),
                    Text('${((status?.sizeScale ?? 1) * 100).round()}%'),
                  ],
                ),
                Slider(
                  value: status?.sizeScale ?? AppSliders.overlayDefaultSize,
                  min: AppSliders.overlayBubbleSizeMin,
                  max: AppSliders.overlayBubbleSizeMax,
                  divisions: AppSliders.overlaySizeDivisions,
                  semanticFormatterCallback: (value) =>
                      'Bubble size ${(value * 100).round()} percent',
                  onChanged: busy
                      ? null
                      : (value) => onAppearanceChanged(
                          sizeScale: value,
                          opacity:
                              status?.opacity ??
                              AppSliders.overlayDefaultOpacity,
                        ),
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Bubble opacity')),
                    Text(
                      '${((status?.opacity ?? AppSliders.overlayDefaultOpacity) * 100).round()}%',
                    ),
                  ],
                ),
                Slider(
                  value: status?.opacity ?? AppSliders.overlayDefaultOpacity,
                  min: AppSliders.overlayBubbleOpacityMin,
                  max: AppSliders.overlayBubbleOpacityMax,
                  divisions: AppSliders.overlayOpacityDivisions,
                  semanticFormatterCallback: (value) =>
                      'Bubble opacity ${(value * 100).round()} percent',
                  onChanged: busy
                      ? null
                      : (value) => onAppearanceChanged(
                          sizeScale:
                              status?.sizeScale ??
                              AppSliders.overlayDefaultSize,
                          opacity: value,
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppInsets.keyboardPrivacy,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenOverlaySettings,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Overlay permission'),
                  ),
                ),
                AppGaps.horizontalX2,
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenAccessibilitySettings,
                    icon: const Icon(Icons.accessibility_new),
                    label: const Text('Accessibility settings'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppInsets.overlayControls,
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : onStart,
                    child: const Text('Start'),
                  ),
                ),
                AppGaps.horizontalX2,
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onStop,
                    child: const Text('Stop'),
                  ),
                ),
                AppGaps.horizontalX2,
                Expanded(
                  child: TextButton(
                    onPressed: busy ? null : onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
