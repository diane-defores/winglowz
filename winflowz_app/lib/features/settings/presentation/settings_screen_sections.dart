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

class _AccountCloudSection extends StatelessWidget {
  const _AccountCloudSection({
    required this.authAsync,
    required this.cloudSyncOverview,
    required this.postAuthMessage,
    required this.remoteAuthConfigured,
    required this.onConnectCloudAccount,
    required this.onSignOut,
  });

  final AsyncValue<AuthSessionSnapshot> authAsync;
  final CloudSyncOverview cloudSyncOverview;
  final String? postAuthMessage;
  final bool remoteAuthConfigured;
  final VoidCallback onConnectCloudAccount;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    const syncRelevantCategories = <CloudSyncCategory>{
      CloudSyncCategory.settings,
      CloudSyncCategory.clipboard,
      CloudSyncCategory.snippets,
      CloudSyncCategory.dictionary,
      CloudSyncCategory.transcriptions,
      CloudSyncCategory.keyboardProfile,
    };

    final syncRelevantStatuses = cloudSyncOverview.categories
        .where((status) => syncRelevantCategories.contains(status.category))
        .toList(growable: false);

    final syncedCategories = syncRelevantStatuses
        .where((status) => status.isRemoteVisible)
        .toList(growable: false);
    final localCategories = syncRelevantStatuses
        .where((status) => !status.isRemoteVisible)
        .toList(growable: false);

    final localOnlyCategories = cloudSyncOverview.categories
        .where((status) => status.category == CloudSyncCategory.localKeys)
        .toList(growable: false);

    final requiresAttention = cloudSyncOverview.categories
        .where((status) => status.requiresAttention)
        .map((status) => status.title)
        .join(', ');
    final accountStatus = cloudSyncOverview.categories.firstWhere(
      (status) => status.category == CloudSyncCategory.account,
    );
    final suiteStatus = cloudSyncOverview.categories.firstWhere(
      (status) => status.category == CloudSyncCategory.suiteAccess,
    );

    final isRemoteSignedIn = authAsync.maybeWhen(
      data: (session) => session.isSignedIn && !session.isLocalFallback,
      orElse: () => false,
    );

    return AppSectionCard(
      title: 'Compte & cloud',
      subtitle: remoteAuthConfigured
          ? 'État vérifié du compte, de l’accès et des données synchronisables.'
          : 'L’authentification distante n’est pas configurée sur cette version.',
      leading: const Icon(Icons.cloud_sync_outlined),
      stretch: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusCard(
            icon: accountStatus.icon,
            title: accountStatus.title,
            subtitle: '${accountStatus.stateLabel} · ${accountStatus.detail}',
            trailing: authAsync.when(
              loading: () => const SizedBox.square(
                dimension: AppIconMetrics.sm,
                child: CircularProgressIndicator(
                  strokeWidth: AppIconMetrics.progressStroke,
                ),
              ),
              error: (error, _) => IconButton(
                tooltip: 'Erreur de compte cloud',
                onPressed: null,
                icon: const Icon(Icons.error_outline),
              ),
              data: (_) => null,
            ),
          ),
          AppGaps.x1,
          AppStatusCard(
            icon: suiteStatus.icon,
            title: suiteStatus.title,
            subtitle: '${suiteStatus.stateLabel} · ${suiteStatus.detail}',
          ),
          if (postAuthMessage != null) ...[
            AppGaps.x3,
            AppBannerCard(
              key: const Key('settings-cloud-post-auth-feedback'),
              icon: Icons.verified_user_outlined,
              title: 'Retour de connexion',
              message: postAuthMessage!,
            ),
          ],
          if (requiresAttention.isNotEmpty) ...[
            AppGaps.x3,
            AppBannerCard(
              key: const Key('settings-cloud-attention-required'),
              icon: Icons.warning_amber_outlined,
              title: 'Action requise',
              message:
                  'Synchronisation en attente d’attention: $requiresAttention',
              accentColor: Theme.of(context).colorScheme.error,
            ),
          ],
          AppGaps.x3,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const Key('settings-connect-cloud-account'),
                onPressed: remoteAuthConfigured && !isRemoteSignedIn
                    ? onConnectCloudAccount
                    : null,
                icon: const Icon(Icons.login_outlined),
                label: const Text('Connecter le compte cloud'),
              ),
              if (isRemoteSignedIn)
                OutlinedButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Se déconnecter'),
                ),
            ],
          ),
          AppGaps.x3,
          const Text(
            'Ce qui est synchronisé',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          AppGaps.x2,
          if (syncedCategories.isEmpty)
            const Text('Aucune donnée synchronisée pour le moment.')
          else
            ...syncedCategories.map(
              (status) => AppStatusCard(
                icon: status.icon,
                title: status.title,
                subtitle: '${status.stateLabel} · ${status.detail}',
              ),
            ),
          AppGaps.x3,
          const Text(
            'Ce qui reste local',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          AppGaps.x2,
          ...localCategories.map(
            (status) => AppStatusCard(
              icon: status.icon,
              title: status.title,
              subtitle: '${status.stateLabel} · ${status.detail}',
            ),
          ),
          if (localOnlyCategories.isNotEmpty) ...[
            AppGaps.x2,
            ...localOnlyCategories.map(
              (status) => AppStatusCard(
                icon: status.icon,
                title: status.title,
                subtitle: '${status.stateLabel} · ${status.detail}',
              ),
            ),
          ],
          AppGaps.x3,
          const Text(
            'Profil clavier Android',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          AppGaps.x2,
          const KeyboardSyncPanel(),
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({
    required this.themeMode,
    required this.confirmDestructiveActions,
    required this.syncStateLabel,
    required this.syncStateDetail,
    required this.syncActionStatus,
    required this.onOpenKeyboardThemeStudio,
    required this.onSyncOrRefresh,
    required this.onConfirmDestructiveActionsChanged,
    required this.onChanged,
  });

  final AppThemeMode themeMode;
  final bool confirmDestructiveActions;
  final String syncStateLabel;
  final String syncStateDetail;
  final AppSyncStatus syncActionStatus;
  final VoidCallback onOpenKeyboardThemeStudio;
  final VoidCallback onSyncOrRefresh;
  final ValueChanged<bool> onConfirmDestructiveActionsChanged;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Apparence',
      subtitle:
          'Utilise la palette WinFlowz et les tokens d’interface partagés. '
          '$syncStateLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(
                value: AppThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined),
                label: Text('Système'),
              ),
              ButtonSegment(
                value: AppThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Clair'),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Sombre'),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) => onChanged(selection.single),
          ),
          AppGaps.x2,
          Text(syncStateDetail, style: Theme.of(context).textTheme.bodySmall),
          AppGaps.x2,
          AppSyncStatusAction(
            key: const Key('settings-appearance-sync-action'),
            status: syncActionStatus,
            onPressed: onSyncOrRefresh,
          ),
          AppGaps.x2,
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.delete_outline),
            value: confirmDestructiveActions,
            onChanged: onConfirmDestructiveActionsChanged,
            title: const Text('Confirmer avant suppression'),
            subtitle: const Text(
              'Demander confirmation avant de supprimer l’historique, les snippets et les termes du dictionnaire.',
            ),
          ),
          AppGaps.x2,
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onOpenKeyboardThemeStudio,
              icon: const Icon(Icons.palette_outlined),
              label: const Text('Studio de thème clavier'),
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
      title: 'Fournisseur backend',
      subtitle: summary,
      leading: const Icon(Icons.storage_outlined),
      stretch: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
          AppGaps.x3,
          Text(
            'Journaux et diagnostic',
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
                label: const Text('Copier diagnostic'),
              ),
              OutlinedButton.icon(
                onPressed: onClearDiagnosticLogs,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Effacer journaux'),
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
    required this.syncStatus,
    required this.onSave,
    required this.onRetrySync,
    required this.onSignOut,
  });

  final AsyncValue<SecretStorageStatus> storageStatusAsync;
  final TextEditingController openAiController;
  final TextEditingController anthropicController;
  final String? message;
  final bool saving;
  final AppSyncStatus syncStatus;
  final VoidCallback onSave;
  final VoidCallback onRetrySync;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Clés IA locales',
      subtitle:
          'Stockées sur cet appareil et exclues des préférences synchronisées.',
      leading: const Icon(Icons.key_outlined),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          storageStatusAsync.when(
            data: (status) {
              if (status == SecretStorageStatus.available) {
                return const ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Stockage sécurisé local disponible'),
                );
              }
              return const ListTile(
                leading: Icon(Icons.warning_amber_outlined),
                title: Text('Stockage sécurisé dégradé'),
                subtitle: Text(
                  'Web/Linux peut ne pas offrir les mêmes garanties de keystore/keychain. '
                  'Le mode IA cloud est considéré comme dégradé tant qu’aucune confirmation explicite n’a été faite.',
                ),
              );
            },
            loading: () => const ListTile(
              title: Text('Vérification des capacités de stockage...'),
            ),
            error: (error, stack) =>
                ListTile(title: Text('Erreur de statut du stockage : $error')),
          ),
          AppGaps.x3,
          TextField(
            controller: openAiController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Clé API OpenAI'),
          ),
          AppGaps.x3,
          TextField(
            controller: anthropicController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Clé API Anthropic'),
          ),
          if (message != null) ...[AppGaps.x3, Text(message!)],
          AppGaps.x2,
          AppSyncStatusAction(
            key: const Key('settings-secrets-sync-action'),
            status: syncStatus,
            onPressed: onRetrySync,
          ),
          AppGaps.x4,
          AppActionRail(
            children: [
              FilledButton(
                onPressed: saving ? null : onSave,
                child: const Text('Enregistrer les clés locales'),
              ),
              OutlinedButton(
                onPressed: saving ? null : onSignOut,
                child: const Text('Se déconnecter'),
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
          'Plateforme détectée: ${PlatformCapabilities.currentPlatformLabel}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        AppGaps.x1,
        Text(
          'Capacités de la plateforme',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        AppGaps.x2,
        AppStatusCard(
          icon: Icons.mic_none,
          title: PlatformCapabilities.localSpeechSupported
              ? 'Dictée locale disponible'
              : 'Dictée locale indisponible sur ${PlatformCapabilities.currentPlatformLabel}',
          subtitle: PlatformCapabilities.localSpeechSupported
              ? 'Le moteur local de la plateforme peut être utilisé.'
              : '${PlatformCapabilities.localSpeechUnavailableReason} WinFlowz bascule vers l’enregistrement avancé et Whisper.',
        ),
        AppStatusCard(
          icon: Icons.bubble_chart_outlined,
          title: PlatformCapabilities.overlaySupported
              ? 'Overlay Android pris en charge'
              : 'Overlay Android indisponible sur ${PlatformCapabilities.currentPlatformLabel}',
          subtitle: PlatformCapabilities.overlaySupported
              ? 'La bulle native Android peut être utilisée.'
              : PlatformCapabilities.overlayUnavailableReason,
        ),
        AppStatusCard(
          icon: Icons.keyboard_outlined,
          title: PlatformCapabilities.keyboardImeSupported
              ? 'IME clavier Android pris en charge'
              : 'Clavier Android indisponible sur ${PlatformCapabilities.currentPlatformLabel}',
          subtitle: PlatformCapabilities.keyboardImeSupported
              ? 'Le clavier WinFlowz fonctionne comme méthode de saisie native Android.'
              : PlatformCapabilities.keyboardImeUnavailableReason,
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
    required this.onThemePresetChanged,
    required this.onReliefChanged,
    required this.onPreferenceChanged,
  });

  static const _controlPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.x1,
    vertical: AppSpacing.x1,
  );
  static const _tilePadding = EdgeInsets.symmetric(horizontal: AppSpacing.x1);

  final AndroidKeyboardStatus? status;
  final bool busy;
  final VoidCallback onRefresh;
  final VoidCallback onOpenInputSettings;
  final VoidCallback onShowPicker;
  final VoidCallback onOpenCornerShortcuts;
  final VoidCallback onOpenKeyboardThemeStudio;
  final ValueChanged<String> onThemePresetChanged;
  final ValueChanged<bool> onReliefChanged;
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
    if (value <= 0.56) {
      return 0.56;
    }
    if (value < 0.84) {
      return 2 / 3;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Clavier WinFlowz',
      subtitle:
          'Statut de la méthode de saisie Android, disposition, gestes et confidentialité.',
      leading: const Icon(Icons.keyboard_outlined),
      child: ListTileTheme.merge(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: _tilePadding,
        minLeadingWidth: AppIconMetrics.sm,
        horizontalTitleGap: AppSpacing.x2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: const Text('État d’exécution'),
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
                      tooltip: 'Actualiser l’état du clavier',
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                    ),
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety_outlined),
              title: const Text('Diagnostics de reprise'),
              subtitle: Text(
                'recoveries=${status?.keyboardRecoveryCount ?? 0} | '
                'last=${status?.lastKeyboardErrorAt ?? 'none'} | '
                'sentry=${SentryBootstrap.isConfigured ? 'configured' : 'disabled'}',
              ),
            ),
            if (status?.lastKeyboardError != null)
              ExpansionTile(
                tilePadding: _tilePadding,
                childrenPadding: _controlPadding,
                title: const Text('Dernier incident clavier'),
                subtitle: const Text('Diagnostic natif masqué'),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(status!.lastKeyboardError!),
                  ),
                ],
              ),
            if (status?.enabled == false)
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Clavier non activé'),
                subtitle: Text(
                  'Activez le clavier WinFlowz dans les paramètres de méthode de saisie Android, puis sélectionnez-le depuis n’importe quel champ texte.',
                ),
              ),
            Padding(
              padding: _controlPadding,
              child: _KeyboardSettingsActions(
                busy: busy,
                onOpenInputSettings: onOpenInputSettings,
                onShowPicker: onShowPicker,
                onOpenKeyboardThemeStudio: onOpenKeyboardThemeStudio,
              ),
            ),
            Padding(
              padding: _controlPadding,
              child: _KeyboardThemeQuickPicker(
                status: status,
                busy: busy,
                onThemePresetChanged: onThemePresetChanged,
              ),
            ),
            SwitchListTile(
              value: status?.themeKeyReliefEnabled ?? false,
              onChanged: busy ? null : onReliefChanged,
              title: const Text('Relief clavier'),
              subtitle: const Text(
                'Ajoute un contour de touche et une sensation de touche enfoncée au clavier natif.',
              ),
            ),
            SwitchListTile(
              value: status?.voiceEnabled ?? true,
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(voiceEnabled: value),
              title: const Text('Dictée clavier'),
              subtitle: const Text(
                'Utilise la reconnaissance vocale Android de l’IME quand la permission micro est accordée.',
              ),
            ),
            SwitchListTile(
              value: status?.clipboardSyncDesired ?? false,
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(clipboardSyncDesired: value),
              title: const Text('Synchronisation clavier presse-papiers'),
              subtitle: const Text(
                'Option de synchronisation cloud des éléments éligibles du presse-papiers clavier. L’historique local est géré séparément.',
              ),
            ),
            SwitchListTile(
              value: status?.clipboardSensitiveFieldHistoryEnabled ?? false,
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(
                      clipboardSensitiveFieldHistoryEnabled: value,
                    ),
              title: const Text('Historique dans champs sensibles'),
              subtitle: const Text(
                'Option avancée : le copier/coller des champs mot de passe, OTP ou privés peut apparaître dans l’historique du presse-papiers. Désactivé par défaut.',
              ),
            ),
            SwitchListTile(
              value: status?.mediaControlsEnabled ?? true,
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(mediaControlsEnabled: value),
              title: const Text('Lecture/pause média clavier'),
              subtitle: const Text(
                'Envoie une touche média Android générique sans lire les métadonnées.',
              ),
            ),
            Padding(
              padding: _controlPadding,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('Pas de volume')),
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
                        'Pas de volume ${_mediaStepPercentForSliderValue(value)} pourcentage',
                    onChanged: busy
                        ? null
                        : (value) => onPreferenceChanged(
                            mediaVolumeStepPercent:
                                _mediaStepPercentForSliderValue(value),
                          ),
                  ),
                  Row(
                    children: [
                      const Expanded(child: Text('Pas de luminosité')),
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
                        'Pas de luminosité ${_mediaStepPercentForSliderValue(value)} pourcentage',
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
              padding: _controlPadding,
              child: DropdownButtonFormField<KeyboardLayoutProfile>(
                initialValue:
                    status?.layoutProfile ?? KeyboardLayoutProfile.qwerty,
                decoration: const InputDecoration(
                  labelText: 'Disposition des lettres',
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
              title: const Text('Gestes de glissement'),
              subtitle: const Text(
                'Quand activé, les glissements sur les touches déclenchent des raccourcis directionnels et d’angle.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_full_outlined),
              title: const Text('Raccourcis de gestes'),
              subtitle: Text(
                'Préréglage=${status?.cornerPresetId ?? KeyboardCornerPresetCatalog.frenchAccents}. Configurez les actions par touche.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: busy ? null : onOpenCornerShortcuts,
            ),
            SwitchListTile(
              value: status?.frenchLanguageEnabled ?? true,
              onChanged: busy
                  ? null
                  : (value) =>
                        onPreferenceChanged(frenchLanguageEnabled: value),
              title: const Text('Suggestions françaises'),
              subtitle: const Text(
                'Active le dictionnaire de suggestions français intégré.',
              ),
            ),
            SwitchListTile(
              value: status?.englishLanguageEnabled ?? true,
              onChanged: busy
                  ? null
                  : (value) =>
                        onPreferenceChanged(englishLanguageEnabled: value),
              title: const Text('Suggestions anglaises'),
              subtitle: const Text(
                'Active le dictionnaire de suggestions anglais intégré.',
              ),
            ),
            SwitchListTile(
              value: status?.spellingSuggestionsEnabled ?? true,
              onChanged: busy
                  ? null
                  : (value) =>
                        onPreferenceChanged(spellingSuggestionsEnabled: value),
              title: const Text('Suggestions orthographiques'),
              subtitle: const Text(
                'Affiche des candidats de mots au-dessus du clavier natif. Les règles d’extension de texte restent séparées.',
              ),
            ),
            Padding(
              padding: _controlPadding,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('Hauteur du clavier')),
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
                        'Hauteur du clavier ${(value * 100).round()} pourcentage',
                    onChanged: busy
                        ? null
                        : (value) =>
                              onPreferenceChanged(keyboardHeightScale: value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: _controlPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hauteur de la rangée d’action'),
                  AppGaps.x1,
                  SegmentedButton<double>(
                    segments: const [
                      ButtonSegment(
                        value: 1,
                        icon: Icon(Icons.crop_16_9_outlined),
                        label: Text('Pleine'),
                      ),
                      ButtonSegment(
                        value: 2 / 3,
                        icon: Icon(Icons.crop_square_outlined),
                        label: Text('Carrée'),
                      ),
                      ButtonSegment(
                        value: 0.56,
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
              title: const Text('Mode clavier compact'),
              subtitle: const Text(
                'Utilise trois lignes de saisie denses lorsque vous avez besoin de la hauteur clavier la plus faible.',
              ),
            ),
            SwitchListTile(
              value: status?.autoCloseModesEnabled ?? true,
              onChanged: busy
                  ? null
                  : (value) =>
                        onPreferenceChanged(autoCloseModesEnabled: value),
              title: const Text('Fermeture automatique des modes'),
              subtitle: const Text(
                'Revient à ABC après une touche en mode chiffres, symboles, accents ou émoji.',
              ),
            ),
            SwitchListTile(
              value: status?.keyVibrationEnabled ?? true,
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(keyVibrationEnabled: value),
              title: const Text('Vibration des touches'),
              subtitle: const Text(
                'Active/désactive le retour haptique du clavier.',
              ),
            ),
            SwitchListTile(
              value: status?.keySoundEnabled ?? false,
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(keySoundEnabled: value),
              title: const Text('Son des touches'),
              subtitle: const Text(
                'Active/désactive le clic sonore des touches.',
              ),
            ),
            SwitchListTile(
              value: status?.specialKeyCornersEnabled ?? false,
              onChanged: busy
                  ? null
                  : (value) =>
                        onPreferenceChanged(specialKeyCornersEnabled: value),
              title: const Text(
                'Raccourcis par glissement de touches spéciales',
              ),
              subtitle: const Text(
                'Autorise les raccourcis de glissement sur les touches non alphabétiques quand les gestes de glissement sont activés.',
              ),
            ),
            SwitchListTile(
              value: status?.doubleSpacePeriodEnabled ?? true,
              onChanged: busy
                  ? null
                  : (value) =>
                        onPreferenceChanged(doubleSpacePeriodEnabled: value),
              title: const Text('Double espace vers point'),
              subtitle: const Text(
                'Transforme le double espace en point-espace dans les champs texte standards.',
              ),
            ),
            SwitchListTile(
              value: status?.punctuationAutoSpacingEnabled ?? false,
              onChanged: busy
                  ? null
                  : (value) => onPreferenceChanged(
                      punctuationAutoSpacingEnabled: value,
                    ),
              title: const Text('Espacement automatique de ponctuation'),
              subtitle: const Text(
                'Ajoute un espacement basique autour de la ponctuation pour les champs texte standards.',
              ),
            ),
            SwitchListTile(
              value: status?.debugTouchOverlayEnabled ?? false,
              onChanged: busy
                  ? null
                  : (value) =>
                        onPreferenceChanged(debugTouchOverlayEnabled: value),
              title: const Text('Overlay de débogage tactile clavier'),
              subtitle: const Text(
                'Affiche les limites des touches et les diagnostics de classification des gestes sur le clavier natif.',
              ),
            ),
            Padding(
              padding: _controlPadding,
              child: DropdownButtonFormField<KeyboardPrivacyMode>(
                initialValue: status?.privacyMode ?? KeyboardPrivacyMode.auto,
                decoration: const InputDecoration(
                  labelText: 'Mode confidentialité clavier',
                ),
                items: const [
                  DropdownMenuItem(
                    value: KeyboardPrivacyMode.auto,
                    child: Text('Auto : détecter les champs sensibles'),
                  ),
                  DropdownMenuItem(
                    value: KeyboardPrivacyMode.strict,
                    child: Text('Strict : mode privé partout'),
                  ),
                  DropdownMenuItem(
                    value: KeyboardPrivacyMode.standard,
                    child: Text('Standard : champs normaux uniquement'),
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
      ),
    );
  }
}

class _KeyboardSettingsActions extends StatelessWidget {
  const _KeyboardSettingsActions({
    required this.busy,
    required this.onOpenInputSettings,
    required this.onShowPicker,
    required this.onOpenKeyboardThemeStudio,
  });

  final bool busy;
  final VoidCallback onOpenInputSettings;
  final VoidCallback onShowPicker;
  final VoidCallback onOpenKeyboardThemeStudio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 360.0;
        final columns = maxWidth >= 560
            ? 3
            : maxWidth >= 360
            ? 2
            : 1;
        const spacing = AppSpacing.x1;
        final itemWidth = (maxWidth - spacing * (columns - 1)) / columns;
        final fullWidthLastAction = columns == 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: OutlinedButton.icon(
                onPressed: busy ? null : onOpenInputSettings,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Paramètres'),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: FilledButton.icon(
                onPressed: busy ? null : onShowPicker,
                icon: const Icon(Icons.keyboard),
                label: const Text('Changer'),
              ),
            ),
            SizedBox(
              width: fullWidthLastAction ? maxWidth : itemWidth,
              child: OutlinedButton.icon(
                onPressed: busy ? null : onOpenKeyboardThemeStudio,
                icon: const Icon(Icons.palette_outlined),
                label: const Text('Thème'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KeyboardThemeQuickPicker extends StatelessWidget {
  const _KeyboardThemeQuickPicker({
    required this.status,
    required this.busy,
    required this.onThemePresetChanged,
  });

  final AndroidKeyboardStatus? status;
  final bool busy;
  final ValueChanged<String> onThemePresetChanged;

  @override
  Widget build(BuildContext context) {
    final selectedPresetId = _normalizedPresetId(
      status?.themePresetId ?? KeyboardThemePresetCatalog.system,
    );
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thème clavier', style: Theme.of(context).textTheme.titleSmall),
        AppGaps.x2,
        Text(
          'Le thème clavier suit le paramètre d’apparence global ci-dessus.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        AppGaps.x2,
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 320.0;
            final columns = maxWidth >= 520
                ? 3
                : maxWidth >= 280
                ? 2
                : 1;
            const spacing = AppSpacing.x1;
            final itemWidth = (maxWidth - spacing * (columns - 1)) / columns;
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
      title: 'Reconnaissance vocale locale',
      subtitle:
          'Installez uniquement les packs locaux dont vous avez besoin. Le fallback Android ou cloud est toujours explicitement indiqué.',
      leading: const Icon(Icons.record_voice_over_outlined),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('État d’exécution'),
            subtitle: Text(
              'runtime=${keyboardStatus?.voiceRuntimeMode ?? 'unavailable'} | '
              'language=${keyboardStatus?.voiceLanguageTag ?? 'und'} | '
              'pack=${keyboardStatus?.voicePackId ?? 'none'} | '
              'engine=${keyboardStatus?.voiceEngine ?? 'unavailable'} | '
              'fallback=${keyboardStatus?.voiceFallbackReason ?? 'unsupported_language'}',
            ),
            trailing: IconButton(
              tooltip: 'Actualiser le catalogue vocal',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.allowCloudFallback,
            onChanged: onAllowCloudFallbackChanged,
            title: const Text('Autoriser fallback cloud'),
            subtitle: const Text(
              'Quand il est désactivé, WinFlowz affiche indisponible au lieu d’envoyer la dictée au fallback cloud.',
            ),
          ),
          if (state.hasError || state.isStale)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text(
                state.isStale ? 'Catalogue obsolète' : 'Catalogue indisponible',
              ),
              subtitle: Text(
                state.lastErrorMessage ??
                    'Réessayez de charger le catalogue local.',
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
        ? 'Supprimé'
        : installed.installState == InstalledLanguagePackState.notInstalled
        ? 'Non installé'
        : 'Supprimer';
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
                'Stockage bloqué : requis=${installed.requiredMb}Mo, disponible=${installed.availableMb}Mo.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (installed.installState ==
                InstalledLanguagePackState.blockedIncompatibleDevice) ...[
              AppGaps.x1,
              Text(
                'Appareil bloqué : ${installed.lastErrorCode}. Ce pack ne peut pas être mis en file sur le profil d’appareil actuel.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (installed.installState ==
                InstalledLanguagePackState.updateAvailable) ...[
              AppGaps.x1,
              Text(
                'Mise à jour disponible : réinstallez ce pack pour actualiser les fichiers locaux du modèle.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            if (installed.installState ==
                InstalledLanguagePackState.corrupted) ...[
              AppGaps.x1,
              Text(
                'Pack corrompu détecté : réessayez l’installation pour restaurer le runtime local.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (!entry.isInstallable) ...[
              AppGaps.x1,
              Text(
                'Ligne état uniquement : cette langue n’a pas de pack local téléchargeable dans le catalogue actuel.',
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
                  label: const Text('Installer maintenant'),
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
                  label: const Text('Réessayer'),
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
                  label: const Text('Marquer mise à jour'),
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
                  label: const Text('Marquer corrompu'),
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
      title: 'Overlay Android',
      subtitle:
          'Permissions de bulle flottante, exécution d’enregistrement et mode de livraison.',
      leading: const Icon(Icons.bubble_chart_outlined),
      child: Column(
        children: [
          SwitchListTile(
            value: status?.enabled ?? false,
            onChanged: (status?.overlayPermissionGranted ?? false) && !busy
                ? onToggle
                : null,
            title: const Text('Activer le pont overlay Android'),
            subtitle: Text(
              (status?.enabled ?? false)
                  ? 'Le pont overlay est actif. La bulle flottante Android devrait être visible.'
                  : (status?.overlayPermissionGranted ?? false)
                  ? 'Permission overlay accordée. Activez-la pour afficher la bulle flottante.'
                  : 'Permission overlay requise avant activation.',
            ),
          ),
          ListTile(
            title: const Text('État d’exécution de l’overlay'),
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
              title: const Text('Dernier évènement overlay natif'),
              subtitle: Text(status?.lastNativeEvent ?? 'none'),
            ),
          if (status?.accessibilityPermissionGranted == false)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Accessibilité désactivée'),
              subtitle: Text(
                'La dictée overlay ne transmettra que le presse-papiers tant que le service d’accessibilité n’est pas activé.',
              ),
            ),
          Padding(
            padding: AppInsets.keyboardPrivacy,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Taille de bulle')),
                    Text('${((status?.sizeScale ?? 1) * 100).round()}%'),
                  ],
                ),
                Slider(
                  value: status?.sizeScale ?? AppSliders.overlayDefaultSize,
                  min: AppSliders.overlayBubbleSizeMin,
                  max: AppSliders.overlayBubbleSizeMax,
                  divisions: AppSliders.overlaySizeDivisions,
                  semanticFormatterCallback: (value) =>
                      'Taille de bulle ${(value * 100).round()} pourcentage',
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
                    const Expanded(child: Text('Opacité de bulle')),
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
                      'Opacité de bulle ${(value * 100).round()} pourcentage',
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
            child: AppActionRail(
              spacing: AppSpacing.x1,
              minActionWidth: 230,
              children: [
                OutlinedButton.icon(
                  onPressed: onOpenOverlaySettings,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Permission overlay'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenAccessibilitySettings,
                  icon: const Icon(Icons.accessibility_new),
                  label: const Text('Paramètres d’accessibilité'),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppInsets.overlayControls,
            child: AppActionRail(
              spacing: AppSpacing.x1,
              minActionWidth: 130,
              children: [
                FilledButton(
                  onPressed: busy ? null : onStart,
                  child: const Text('Démarrer'),
                ),
                OutlinedButton(
                  onPressed: busy ? null : onStop,
                  child: const Text('Arrêter'),
                ),
                TextButton(
                  onPressed: busy ? null : onCancel,
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
