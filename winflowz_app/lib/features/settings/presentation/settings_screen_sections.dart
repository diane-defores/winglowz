part of "settings_screen.dart";

const _mediaStepPercentOptions = <int>[1, 2, 3, 4, 5, 10, 15, 20];

int _mediaStepPercentForSliderValue(double value) {
  final index = value.round().clamp(0, _mediaStepPercentOptions.length - 1);
  return _mediaStepPercentOptions[index];
}

double _mediaStepSliderValue(int percent) {
  final index = _mediaStepPercentOptions.indexOf(percent);
  if (index >= 0) {
    return index.toDouble();
  }
  var nearestIndex = 0;
  var nearestDistance = (percent - _mediaStepPercentOptions.first).abs();
  for (var i = 1; i < _mediaStepPercentOptions.length; i += 1) {
    final distance = (percent - _mediaStepPercentOptions[i]).abs();
    if (distance < nearestDistance) {
      nearestIndex = i;
      nearestDistance = distance;
    }
  }
  return nearestIndex.toDouble();
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({
    required this.themeMode,
    required this.confirmDestructiveActions,
    required this.syncStateLabel,
    required this.syncStateDetail,
    required this.onOpenKeyboardThemeStudio,
    required this.onConfirmDestructiveActionsChanged,
    required this.onChanged,
  });

  final AppThemeMode themeMode;
  final bool confirmDestructiveActions;
  final String syncStateLabel;
  final String syncStateDetail;
  final VoidCallback onOpenKeyboardThemeStudio;
  final ValueChanged<bool> onConfirmDestructiveActionsChanged;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Appearance',
      subtitle:
          'Uses the WinFlowz palette and shared Flowz interface tokens. '
          '$syncStateLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<AppThemeMode>(
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
          AppGaps.x2,
          Text(syncStateDetail, style: Theme.of(context).textTheme.bodySmall),
          AppGaps.x2,
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.delete_outline),
            value: confirmDestructiveActions,
            onChanged: onConfirmDestructiveActionsChanged,
            title: const Text('Confirm before deleting'),
            subtitle: const Text(
              'Ask before deleting history items, snippets and dictionary terms.',
            ),
          ),
          AppGaps.x2,
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onOpenKeyboardThemeStudio,
              icon: const Icon(Icons.palette_outlined),
              label: const Text('Keyboard Theme Studio'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendProviderSection extends StatelessWidget {
  const _BackendProviderSection({
    required this.summary,
    required this.detail,
    required this.diagnosticText,
    required this.onCopyDiagnostic,
    required this.onClearDiagnosticLogs,
  });

  final String summary;
  final String detail;
  final String diagnosticText;
  final VoidCallback onCopyDiagnostic;
  final Future<void> Function() onClearDiagnosticLogs;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Backend provider',
      subtitle: summary,
      leading: const Icon(Icons.storage_outlined),
      stretch: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
          AppGaps.x3,
          Text(
            'Logs & diagnostic',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          AppGaps.x2,
          _DiagnosticLogPanel(diagnosticText: diagnosticText),
          AppGaps.x3,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onCopyDiagnostic,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy diagnostic'),
              ),
              OutlinedButton.icon(
                onPressed: onClearDiagnosticLogs,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear logs'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiagnosticLogPanel extends StatefulWidget {
  const _DiagnosticLogPanel({required this.diagnosticText});

  final String diagnosticText;

  @override
  State<_DiagnosticLogPanel> createState() => _DiagnosticLogPanelState();
}

class _DiagnosticLogPanelState extends State<_DiagnosticLogPanel> {
  final ScrollController _controller = ScrollController(
    keepScrollOffset: false,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.x2),
      ),
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          key: const PageStorageKey<String>('backend_diagnostic_log_scroll'),
          controller: _controller,
          primary: false,
          padding: const EdgeInsets.all(AppSpacing.x2),
          child: SelectableText(
            widget.diagnosticText,
            key: const Key('backend-diagnostic-log-text'),
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              height: 1.35,
            ),
          ),
        ),
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
    required this.onOpenKeyboardThemeStudio,
    required this.onThemeModeChanged,
    required this.onThemePresetChanged,
    required this.onPreferenceChanged,
  });

  final AndroidKeyboardStatus? status;
  final bool busy;
  final VoidCallback onRefresh;
  final VoidCallback onOpenInputSettings;
  final VoidCallback onShowPicker;
  final VoidCallback onOpenCornerShortcuts;
  final VoidCallback onOpenKeyboardThemeStudio;
  final ValueChanged<String> onThemeModeChanged;
  final ValueChanged<String> onThemePresetChanged;
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

  double get _actionRowHeightScale {
    final value = status?.actionRowHeightScale ?? 1;
    if (value < 0.50) {
      return 1 / 3;
    }
    if (value < 0.84) {
      return 2 / 3;
    }
    return 1;
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
              'gestures=${status?.cornerModeEnabled ?? false} | '
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
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: const Text('Recovery diagnostics'),
            subtitle: Text(
              'recoveries=${status?.keyboardRecoveryCount ?? 0} | '
              'last=${status?.lastKeyboardErrorAt ?? 'none'} | '
              'sentry=${SentryBootstrap.isConfigured ? 'configured' : 'disabled'}',
            ),
          ),
          if (status?.lastKeyboardError != null)
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
              ),
              title: const Text('Last keyboard incident'),
              subtitle: const Text('Redacted native diagnostic'),
              children: [
                Padding(
                  padding: AppInsets.keyboardPrivacy,
                  child: SelectableText(status!.lastKeyboardError!),
                ),
              ],
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
          Padding(
            padding: AppInsets.keyboardControls,
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: busy ? null : onOpenKeyboardThemeStudio,
                icon: const Icon(Icons.palette_outlined),
                label: const Text('Keyboard Theme Studio'),
              ),
            ),
          ),
          Padding(
            padding: AppInsets.keyboardControls,
            child: _KeyboardThemeQuickPicker(
              status: status,
              busy: busy,
              onThemeModeChanged: onThemeModeChanged,
              onThemePresetChanged: onThemePresetChanged,
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
              'Opt-in flag for cloud sync of eligible keyboard clipboard items. Local history is handled separately.',
            ),
          ),
          SwitchListTile(
            value: status?.clipboardSensitiveFieldHistoryEnabled ?? false,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(
                    clipboardSensitiveFieldHistoryEnabled: value,
                  ),
            title: const Text('Clipboard history in sensitive fields'),
            subtitle: const Text(
              'Advanced opt-in: copy/cut/paste from password, OTP, or private fields can appear in clipboard history. Off by default.',
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
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Volume step')),
                    Text('${status?.mediaVolumeStepPercent ?? 5}%'),
                  ],
                ),
                Slider(
                  value: _mediaStepSliderValue(
                    status?.mediaVolumeStepPercent ?? 5,
                  ),
                  min: 0,
                  max: (_mediaStepPercentOptions.length - 1).toDouble(),
                  divisions: _mediaStepPercentOptions.length - 1,
                  semanticFormatterCallback: (value) =>
                      'Volume step ${_mediaStepPercentForSliderValue(value)} percent',
                  onChanged: busy
                      ? null
                      : (value) => onPreferenceChanged(
                          mediaVolumeStepPercent:
                              _mediaStepPercentForSliderValue(value),
                        ),
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Brightness step')),
                    Text('${status?.mediaBrightnessStepPercent ?? 10}%'),
                  ],
                ),
                Slider(
                  value: _mediaStepSliderValue(
                    status?.mediaBrightnessStepPercent ?? 10,
                  ),
                  min: 0,
                  max: (_mediaStepPercentOptions.length - 1).toDouble(),
                  divisions: _mediaStepPercentOptions.length - 1,
                  semanticFormatterCallback: (value) =>
                      'Brightness step ${_mediaStepPercentForSliderValue(value)} percent',
                  onChanged: busy
                      ? null
                      : (value) => onPreferenceChanged(
                          mediaBrightnessStepPercent:
                              _mediaStepPercentForSliderValue(value),
                        ),
                ),
              ],
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
            title: const Text('Swipe gestures'),
            subtitle: const Text(
              'When enabled, key swipes can trigger directional and corner shortcuts.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.open_in_full_outlined),
            title: const Text('Gesture shortcuts'),
            subtitle: Text(
              'Preset=${status?.cornerPresetId ?? KeyboardCornerPresetCatalog.frenchAccents}. Configure per-key gesture actions.',
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
          Padding(
            padding: AppInsets.keyboardPrivacy,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Keyboard height')),
                    Text(
                      '${((status?.keyboardHeightScale ?? 1) * 100).round()}%',
                    ),
                  ],
                ),
                Slider(
                  value: (status?.keyboardHeightScale ?? 1).clamp(0.85, 1.2),
                  min: 0.85,
                  max: 1.2,
                  divisions: 12,
                  semanticFormatterCallback: (value) =>
                      'Keyboard height ${(value * 100).round()} percent',
                  onChanged: busy
                      ? null
                      : (value) =>
                            onPreferenceChanged(keyboardHeightScale: value),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppInsets.keyboardPrivacy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Action row height'),
                AppGaps.x1,
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(
                      value: 1,
                      icon: Icon(Icons.crop_16_9_outlined),
                      label: Text('Full'),
                    ),
                    ButtonSegment(
                      value: 2 / 3,
                      icon: Icon(Icons.crop_square_outlined),
                      label: Text('Square'),
                    ),
                    ButtonSegment(
                      value: 1 / 3,
                      icon: Icon(Icons.density_small_outlined),
                      label: Text('Mini'),
                    ),
                  ],
                  selected: {_actionRowHeightScale},
                  onSelectionChanged: busy
                      ? null
                      : (selection) => onPreferenceChanged(
                          actionRowHeightScale: selection.single,
                        ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            value: status?.compactModeEnabled ?? false,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(compactModeEnabled: value),
            title: const Text('Compact keyboard mode'),
            subtitle: const Text(
              'Uses three dense typing rows when you need the lowest keyboard height.',
            ),
          ),
          SwitchListTile(
            value: status?.autoCloseModesEnabled ?? true,
            onChanged: busy
                ? null
                : (value) => onPreferenceChanged(autoCloseModesEnabled: value),
            title: const Text('Auto-close modes'),
            subtitle: const Text(
              'Returns to ABC after one key in numbers, symbols, accents, or emoji mode.',
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
            title: const Text('Special-key gesture shortcuts'),
            subtitle: const Text(
              'Allows swipe gesture shortcuts on non-letter keys when swipe gestures are enabled.',
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

class _KeyboardThemeQuickPicker extends StatelessWidget {
  const _KeyboardThemeQuickPicker({
    required this.status,
    required this.busy,
    required this.onThemeModeChanged,
    required this.onThemePresetChanged,
  });

  final AndroidKeyboardStatus? status;
  final bool busy;
  final ValueChanged<String> onThemeModeChanged;
  final ValueChanged<String> onThemePresetChanged;

  String get _selectedMode {
    final mode = status?.themeMode ?? 'system';
    return switch (mode) {
      'light' || 'dark' => mode,
      _ => 'system',
    };
  }

  Brightness _previewBrightness(BuildContext context) {
    return switch (_selectedMode) {
      'dark' => Brightness.dark,
      'light' => Brightness.light,
      _ => Theme.of(context).brightness,
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedPresetId = _normalizedPresetId(
      status?.themePresetId ?? KeyboardThemePresetCatalog.system,
    );
    final brightness = _previewBrightness(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Keyboard theme', style: Theme.of(context).textTheme.titleSmall),
        AppGaps.x2,
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'system',
              icon: Icon(Icons.brightness_auto_outlined),
              label: Text('System'),
            ),
            ButtonSegment(
              value: 'light',
              icon: Icon(Icons.light_mode_outlined),
              label: Text('Light'),
            ),
            ButtonSegment(
              value: 'dark',
              icon: Icon(Icons.dark_mode_outlined),
              label: Text('Dark'),
            ),
          ],
          selected: {_selectedMode},
          onSelectionChanged: busy
              ? null
              : (selection) => onThemeModeChanged(selection.single),
        ),
        AppGaps.x2,
        LayoutBuilder(
          builder: (context, constraints) {
            const columns = 3;
            const spacing = AppSpacing.x1;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final preset in KeyboardThemePresetCatalog.presets)
                  SizedBox(
                    width: itemWidth,
                    child: _KeyboardThemePresetChip(
                      preset: preset,
                      brightness: brightness,
                      selected: selectedPresetId == preset.id,
                      enabled: !busy,
                      onPressed: () => onThemePresetChanged(preset.id),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _KeyboardThemePresetChip extends StatelessWidget {
  const _KeyboardThemePresetChip({
    required this.preset,
    required this.brightness,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final KeyboardThemePreset preset;
  final Brightness brightness;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final config = KeyboardThemePresetCatalog.configFor(
      preset.id,
      brightness: brightness,
    );
    final labelColor = _themePreviewTextColor(config.keyColor);
    final borderColor = selected
        ? Color(config.activeKeyColor)
        : Theme.of(context).colorScheme.outlineVariant;
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(AppSpacing.x1),
        foregroundColor: labelColor,
        backgroundColor: Color(config.keyColor),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: borderColor, width: selected ? 2 : 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.x1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KeyboardThemeSwatch(config: config),
          const SizedBox(height: 3),
          Text(
            preset.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: selected
                  ? AppFontWeights.bold
                  : AppFontWeights.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardThemeSwatch extends StatelessWidget {
  const _KeyboardThemeSwatch({required this.config});

  final KeyboardThemeConfig config;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.x1),
      child: SizedBox(
        height: 22,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(config.backgroundStartColor),
                gradient: config.useGradient
                    ? LinearGradient(
                        colors: [
                          Color(config.backgroundStartColor),
                          Color(config.backgroundEndColor),
                        ],
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  _KeyboardThemeMiniKey(color: Color(config.keyColor)),
                  const SizedBox(width: 3),
                  _KeyboardThemeMiniKey(color: Color(config.specialKeyColor)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(config.activeKeyColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyboardThemeMiniKey extends StatelessWidget {
  const _KeyboardThemeMiniKey({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _OnDeviceSpeechSection extends StatelessWidget {
  const _OnDeviceSpeechSection({
    required this.state,
    required this.keyboardStatus,
    required this.onRefresh,
    required this.onAllowCloudFallbackChanged,
    required this.onInstall,
    required this.onRetryInstall,
    required this.onMarkUpdateAvailable,
    required this.onMarkCorrupted,
    required this.onRemove,
  });

  final LanguagePackCatalogState state;
  final AndroidKeyboardStatus? keyboardStatus;
  final VoidCallback onRefresh;
  final ValueChanged<bool> onAllowCloudFallbackChanged;
  final Future<bool> Function(LanguagePackCatalogEntry entry) onInstall;
  final Future<bool> Function(LanguagePackCatalogEntry entry) onRetryInstall;
  final bool Function(LanguagePackCatalogEntry entry) onMarkUpdateAvailable;
  final bool Function(LanguagePackCatalogEntry entry) onMarkCorrupted;
  final ValueChanged<LanguagePackCatalogEntry> onRemove;

  @override
  Widget build(BuildContext context) {
    final entries = state.catalog.entries;
    return AppSectionCard(
      title: 'On-device speech',
      subtitle:
          'Install only the local packs you need. Android or cloud fallback is always labeled explicitly.',
      leading: const Icon(Icons.record_voice_over_outlined),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Runtime status'),
            subtitle: Text(
              'runtime=${keyboardStatus?.voiceRuntimeMode ?? 'unavailable'} | '
              'language=${keyboardStatus?.voiceLanguageTag ?? 'und'} | '
              'pack=${keyboardStatus?.voicePackId ?? 'none'} | '
              'engine=${keyboardStatus?.voiceEngine ?? 'unavailable'} | '
              'fallback=${keyboardStatus?.voiceFallbackReason ?? 'unsupported_language'}',
            ),
            trailing: IconButton(
              tooltip: 'Refresh speech catalog',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.allowCloudFallback,
            onChanged: onAllowCloudFallbackChanged,
            title: const Text('Allow cloud fallback'),
            subtitle: const Text(
              'When off, WinFlowz must show unavailable instead of sending speech to cloud fallback.',
            ),
          ),
          if (state.hasError || state.isStale)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text(
                state.isStale ? 'Catalog stale' : 'Catalog unavailable',
              ),
              subtitle: Text(
                state.lastErrorMessage ?? 'Retry loading the local catalog.',
              ),
            ),
          AppGaps.x2,
          for (final entry in entries) ...[
            _LanguagePackTile(
              entry: entry,
              installed: state.installedStateFor(entry),
              allowCloudFallback: state.allowCloudFallback,
              retriesUsed: state.retryCounts[entry.packId] ?? 0,
              onInstall: () => onInstall(entry),
              onRetryInstall: () => onRetryInstall(entry),
              onMarkUpdateAvailable: () => onMarkUpdateAvailable(entry),
              onMarkCorrupted: () => onMarkCorrupted(entry),
              onRemove: () => onRemove(entry),
            ),
            AppGaps.x2,
          ],
        ],
      ),
    );
  }
}

class _LanguagePackTile extends StatelessWidget {
  const _LanguagePackTile({
    required this.entry,
    required this.installed,
    required this.allowCloudFallback,
    required this.retriesUsed,
    required this.onInstall,
    required this.onRetryInstall,
    required this.onMarkUpdateAvailable,
    required this.onMarkCorrupted,
    required this.onRemove,
  });

  final LanguagePackCatalogEntry entry;
  final InstalledLanguagePack installed;
  final bool allowCloudFallback;
  final int retriesUsed;
  final Future<bool> Function() onInstall;
  final Future<bool> Function() onRetryInstall;
  final bool Function() onMarkUpdateAvailable;
  final bool Function() onMarkCorrupted;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLine = [
      'engine=${entry.engine.wireName}',
      'quality=${entry.qualityTier.wireName}',
      'runtime=${entry.runtimeMode.wireName}',
      'fallback=${entry.fallbackPolicy.wireName}',
      'license=${entry.licenseId}',
      'download=${entry.downloadSizeMb}MB',
      'installed=${entry.installedSizeMb}MB',
      'state=${installed.installState.wireName}',
    ].join(' | ');
    final canRemove =
        installed.installState != InstalledLanguagePackState.notInstalled &&
        installed.installState != InstalledLanguagePackState.removed;
    final removeLabel =
        installed.installState == InstalledLanguagePackState.removed
        ? 'Removed'
        : installed.installState == InstalledLanguagePackState.notInstalled
        ? 'Not installed'
        : 'Remove';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.x2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.displayName,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                _SpeechPill(label: entry.qualityTier.wireName),
              ],
            ),
            AppGaps.x1,
            Text(statusLine, style: theme.textTheme.bodySmall),
            AppGaps.x1,
            Text(
              'benchmark=${entry.benchmarkStatus.wireName} | offline=${entry.supportsOffline} | cloud_auto_allowed=$allowCloudFallback',
              style: theme.textTheme.bodySmall,
            ),
            AppGaps.x1,
            Text(
              'progress=${installed.downloadProgress}% | retries=$retriesUsed/3 | checksum=${installed.checksumVerified}',
              style: theme.textTheme.bodySmall,
            ),
            if (installed.installState ==
                InstalledLanguagePackState.blockedInsufficientStorage) ...[
              AppGaps.x1,
              Text(
                'Storage blocked: required=${installed.requiredMb}MB, available=${installed.availableMb}MB.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (installed.installState ==
                InstalledLanguagePackState.blockedIncompatibleDevice) ...[
              AppGaps.x1,
              Text(
                'Device blocked: ${installed.lastErrorCode}. This pack cannot be queued on the current device profile.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (installed.installState ==
                InstalledLanguagePackState.updateAvailable) ...[
              AppGaps.x1,
              Text(
                'Update available: reinstall this pack to refresh local model files.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            if (installed.installState ==
                InstalledLanguagePackState.corrupted) ...[
              AppGaps.x1,
              Text(
                'Corrupted pack detected: retry install to recover local runtime.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (!entry.isInstallable) ...[
              AppGaps.x1,
              Text(
                'Status-only row: this language has no downloadable local pack in the current catalog.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            AppGaps.x2,
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                OutlinedButton.icon(
                  onPressed: entry.isInstallable
                      ? () async {
                          await onInstall();
                        }
                      : null,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Install now'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      installed.installState ==
                              InstalledLanguagePackState.failedDownload ||
                          installed.installState ==
                              InstalledLanguagePackState.failedVerification ||
                          installed.installState ==
                              InstalledLanguagePackState
                                  .blockedInsufficientStorage ||
                          installed.installState ==
                              InstalledLanguagePackState
                                  .pausedInsufficientStorage ||
                          installed.installState ==
                              InstalledLanguagePackState.corrupted
                      ? () async {
                          await onRetryInstall();
                        }
                      : null,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Retry'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      installed.installState ==
                          InstalledLanguagePackState.installed
                      ? () {
                          onMarkUpdateAvailable();
                        }
                      : null,
                  icon: const Icon(Icons.system_update_alt_outlined),
                  label: const Text('Mark update'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      installed.installState ==
                              InstalledLanguagePackState.installed ||
                          installed.installState ==
                              InstalledLanguagePackState.updateAvailable
                      ? () {
                          onMarkCorrupted();
                        }
                      : null,
                  icon: const Icon(Icons.warning_amber_outlined),
                  label: const Text('Mark corrupted'),
                ),
                OutlinedButton.icon(
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(removeLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeechPill extends StatelessWidget {
  const _SpeechPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x1,
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

String _normalizedPresetId(String presetId) {
  return switch (presetId) {
    KeyboardThemePresetCatalog.winflowzLight ||
    KeyboardThemePresetCatalog.winflowzDark =>
      KeyboardThemePresetCatalog.winflowz,
    _ => presetId,
  };
}

Color _themePreviewTextColor(int backgroundColor) {
  final color = Color(backgroundColor);
  return color.computeLuminance() > .45 ? Colors.black : Colors.white;
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
