import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/language_pack_state_repository.dart';
import '../domain/language_pack_catalog.dart';

enum LanguagePackCatalogLoadState { loading, success, error, stale }

class LanguagePackCatalogState {
  const LanguagePackCatalogState({
    required this.loadState,
    required this.catalog,
    required this.installedPacks,
    required this.retryCounts,
    required this.allowCloudFallback,
    this.lastErrorCode,
    this.lastErrorMessage,
  });

  final LanguagePackCatalogLoadState loadState;
  final LanguagePackCatalog catalog;
  final Map<String, InstalledLanguagePack> installedPacks;
  final Map<String, int> retryCounts;
  final bool allowCloudFallback;
  final String? lastErrorCode;
  final String? lastErrorMessage;

  bool get hasError => loadState == LanguagePackCatalogLoadState.error;
  bool get isStale => loadState == LanguagePackCatalogLoadState.stale;

  InstalledLanguagePack installedStateFor(LanguagePackCatalogEntry entry) {
    return installedPacks[entry.packId] ??
        InstalledLanguagePack.notInstalled(entry);
  }

  LanguagePackCatalogState copyWith({
    LanguagePackCatalogLoadState? loadState,
    LanguagePackCatalog? catalog,
    Map<String, InstalledLanguagePack>? installedPacks,
    Map<String, int>? retryCounts,
    bool? allowCloudFallback,
    String? lastErrorCode,
    String? lastErrorMessage,
  }) {
    return LanguagePackCatalogState(
      loadState: loadState ?? this.loadState,
      catalog: catalog ?? this.catalog,
      installedPacks: installedPacks ?? this.installedPacks,
      retryCounts: retryCounts ?? this.retryCounts,
      allowCloudFallback: allowCloudFallback ?? this.allowCloudFallback,
      lastErrorCode: lastErrorCode,
      lastErrorMessage: lastErrorMessage,
    );
  }
}

final languagePackCatalogStateRepositoryProvider =
    Provider<LanguagePackCatalogStateRepository>((ref) {
      return InMemoryLanguagePackCatalogStateRepository();
    });

final languagePackCatalogProvider =
    NotifierProvider<LanguagePackCatalogNotifier, LanguagePackCatalogState>(
      LanguagePackCatalogNotifier.new,
    );

class LanguagePackCatalogNotifier extends Notifier<LanguagePackCatalogState> {
  static const int _maxAutoRetries = 3;

  @override
  LanguagePackCatalogState build() {
    final persisted = ref
        .read(languagePackCatalogStateRepositoryProvider)
        .read();
    return LanguagePackCatalogState(
      loadState: LanguagePackCatalogLoadState.success,
      catalog: LanguagePackCatalog(entries: _defaultCatalogEntries()),
      installedPacks: persisted.installedPacks,
      retryCounts: persisted.retryCounts,
      allowCloudFallback: persisted.allowCloudFallback,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(loadState: LanguagePackCatalogLoadState.loading);
    try {
      state = state.copyWith(
        loadState: LanguagePackCatalogLoadState.success,
        catalog: LanguagePackCatalog(entries: _defaultCatalogEntries()),
      );
    } on CatalogValidationException catch (error) {
      state = state.copyWith(
        loadState: state.catalog.entries.isEmpty
            ? LanguagePackCatalogLoadState.error
            : LanguagePackCatalogLoadState.stale,
        lastErrorCode: error.code,
        lastErrorMessage: error.message,
      );
    }
    _persistState();
  }

  void setAllowCloudFallback(bool value) {
    state = state.copyWith(allowCloudFallback: value);
    _persistState();
  }

  void markInstallBlockedByStorage({
    required LanguagePackCatalogEntry entry,
    required int requiredMb,
    required int availableMb,
  }) {
    final current = _stateFor(entry);
    if (current.installState == InstalledLanguagePackState.installed) {
      return;
    }
    _setPackState(
      entry,
      current.copyWith(
        installState: InstalledLanguagePackState.blockedInsufficientStorage,
        runtimeMode: LanguagePackRuntimeMode.unavailable,
        fallbackReason: LanguagePackFallbackReason.insufficientStorage,
        requiredMb: requiredMb,
        availableMb: availableMb,
        lastErrorAt: DateTime.now().toUtc(),
        lastErrorCode: 'blocked_insufficient_storage',
      ),
    );
  }

  void queueInstall(LanguagePackCatalogEntry entry) {
    if (!entry.isInstallable) {
      return;
    }
    final current = _stateFor(entry);
    if (_isInstallInFlight(current.installState) ||
        current.installState == InstalledLanguagePackState.installed) {
      return;
    }
    _setPackState(
      entry,
      current.copyWith(
        installState: InstalledLanguagePackState.queued,
        runtimeMode: LanguagePackRuntimeMode.unavailable,
        fallbackReason: LanguagePackFallbackReason.missingPack,
        downloadProgress: 0,
        requiredMb: entry.installedSizeMb,
        lastErrorCode: 'none',
      ),
    );
  }

  void startDownload(LanguagePackCatalogEntry entry) {
    final current = _stateFor(entry);
    if (current.installState == InstalledLanguagePackState.installed) {
      return;
    }
    if (current.installState != InstalledLanguagePackState.queued &&
        current.installState != InstalledLanguagePackState.failedDownload &&
        current.installState !=
            InstalledLanguagePackState.pausedInsufficientStorage &&
        current.installState != InstalledLanguagePackState.failedVerification) {
      return;
    }
    _setPackState(
      entry,
      current.copyWith(
        installState: InstalledLanguagePackState.downloading,
        runtimeMode: LanguagePackRuntimeMode.unavailable,
        fallbackReason: LanguagePackFallbackReason.missingPack,
        lastErrorCode: 'none',
      ),
    );
  }

  void updateDownloadProgress(LanguagePackCatalogEntry entry, int progress) {
    final current = _stateFor(entry);
    final clamped = progress.clamp(0, 100);
    if (current.installState != InstalledLanguagePackState.downloading &&
        current.installState != InstalledLanguagePackState.queued) {
      return;
    }
    final nextState = clamped >= 100
        ? InstalledLanguagePackState.verifying
        : InstalledLanguagePackState.downloading;
    _setPackState(
      entry,
      current.copyWith(
        installState: nextState,
        runtimeMode: LanguagePackRuntimeMode.unavailable,
        fallbackReason: LanguagePackFallbackReason.missingPack,
        downloadProgress: clamped,
        checksumVerified: false,
      ),
    );
  }

  void failDownload(
    LanguagePackCatalogEntry entry, {
    String code = 'download_failed',
  }) {
    final current = _stateFor(entry);
    if (current.installState != InstalledLanguagePackState.downloading &&
        current.installState != InstalledLanguagePackState.queued) {
      return;
    }
    _setPackState(
      entry,
      current.copyWith(
        installState: InstalledLanguagePackState.failedDownload,
        runtimeMode: LanguagePackRuntimeMode.unavailable,
        fallbackReason: LanguagePackFallbackReason.missingPack,
        lastErrorAt: DateTime.now().toUtc(),
        lastErrorCode: code,
      ),
    );
  }

  void failVerification(
    LanguagePackCatalogEntry entry, {
    String code = 'failed_verification',
  }) {
    final current = _stateFor(entry);
    if (current.installState != InstalledLanguagePackState.verifying) {
      return;
    }
    _setPackState(
      entry,
      current.copyWith(
        installState: InstalledLanguagePackState.failedVerification,
        runtimeMode: LanguagePackRuntimeMode.unavailable,
        fallbackReason: LanguagePackFallbackReason.verificationFailed,
        checksumVerified: false,
        lastErrorAt: DateTime.now().toUtc(),
        lastErrorCode: code,
      ),
    );
  }

  bool retryInstall(LanguagePackCatalogEntry entry) {
    final current = _stateFor(entry);
    if (current.installState != InstalledLanguagePackState.failedDownload &&
        current.installState != InstalledLanguagePackState.failedVerification &&
        current.installState !=
            InstalledLanguagePackState.pausedInsufficientStorage &&
        current.installState !=
            InstalledLanguagePackState.blockedInsufficientStorage) {
      return false;
    }
    final usedRetries = state.retryCounts[entry.packId] ?? 0;
    if (usedRetries >= _maxAutoRetries) {
      _setPackState(
        entry,
        current.copyWith(
          lastErrorAt: DateTime.now().toUtc(),
          lastErrorCode: 'retry_limit_reached',
        ),
      );
      return false;
    }
    final retries = Map<String, int>.of(state.retryCounts);
    retries[entry.packId] = usedRetries + 1;
    state = state.copyWith(
      retryCounts: retries,
      installedPacks: {
        ...state.installedPacks,
        entry.packId: current.copyWith(
          installState: InstalledLanguagePackState.queued,
          runtimeMode: LanguagePackRuntimeMode.unavailable,
          fallbackReason: LanguagePackFallbackReason.missingPack,
          lastErrorCode: 'none',
        ),
      },
    );
    _persistState();
    return true;
  }

  void markInstalled(LanguagePackCatalogEntry entry) {
    final current = _stateFor(entry);
    if (current.installState != InstalledLanguagePackState.verifying ||
        current.downloadProgress < 100) {
      return;
    }
    _setPackState(
      entry,
      current.copyWith(
        installState: InstalledLanguagePackState.installed,
        runtimeMode: LanguagePackRuntimeMode.local,
        fallbackReason: LanguagePackFallbackReason.none,
        installedSizeMb: entry.installedSizeMb,
        checksumVerified: true,
        installedAt: DateTime.now().toUtc(),
        lastVerifiedAt: DateTime.now().toUtc(),
        lastErrorCode: 'none',
      ),
    );
  }

  void remove(LanguagePackCatalogEntry entry) {
    final retries = Map<String, int>.of(state.retryCounts)
      ..remove(entry.packId);
    state = state.copyWith(
      retryCounts: retries,
      installedPacks: {
        ...state.installedPacks,
        entry.packId: InstalledLanguagePack.notInstalled(entry).copyWith(
          installState: InstalledLanguagePackState.removed,
          runtimeMode: LanguagePackRuntimeMode.unavailable,
          fallbackReason: LanguagePackFallbackReason.missingPack,
          lastErrorCode: 'none',
        ),
      },
    );
    _persistState();
  }

  InstalledLanguagePack _stateFor(LanguagePackCatalogEntry entry) {
    return state.installedPacks[entry.packId] ??
        InstalledLanguagePack.notInstalled(entry);
  }

  static bool _isInstallInFlight(InstalledLanguagePackState value) {
    return value == InstalledLanguagePackState.queued ||
        value == InstalledLanguagePackState.downloading ||
        value == InstalledLanguagePackState.verifying;
  }

  void _setPackState(
    LanguagePackCatalogEntry entry,
    InstalledLanguagePack nextPack,
  ) {
    state = state.copyWith(
      installedPacks: {...state.installedPacks, entry.packId: nextPack},
    );
    _persistState();
  }

  void _persistState() {
    ref
        .read(languagePackCatalogStateRepositoryProvider)
        .write(
          LanguagePackCatalogLocalState(
            installedPacks: state.installedPacks,
            retryCounts: state.retryCounts,
            allowCloudFallback: state.allowCloudFallback,
          ),
        );
  }
}

List<LanguagePackCatalogEntry> _defaultCatalogEntries() {
  final updatedAt = DateTime.utc(2026, 5, 15, 19, 19, 39);
  return [
    LanguagePackCatalogEntry.fromMap({
      'pack_id': 'sherpa_onnx.fr-fr.whisper_candidate.2026_05_15',
      'language_tag': 'fr-FR',
      'display_name': 'French (France)',
      'engine': 'sherpa_onnx',
      'engine_version': 'candidate',
      'model_version': 'whisper-multilingual-candidate',
      'quality_tier': 'experimental',
      'runtime_mode': 'local',
      'fallback_policy': 'android_then_cloud_auto',
      'download_url':
          'https://downloads.winflowz.local/asr/fr-fr-placeholder.zip',
      'download_size_mb': 82,
      'installed_size_mb': 148,
      'sha256':
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'signature': 'winflowz-catalog-dev-signature',
      'license_id': 'MIT-model-license-review-required',
      'commercial_distribution_allowed': false,
      'min_android_sdk': 26,
      'supported_abis': ['arm64-v8a'],
      'min_ram_mb': 4096,
      'requires_streaming': true,
      'supports_offline': true,
      'benchmark_status': 'candidate',
      'benchmark_evidence':
          'shipflow_data/workflow/specs/on-device-asr-free-options-research.md',
      'updated_at': updatedAt.toIso8601String(),
    }),
    LanguagePackCatalogEntry.fromMap({
      'pack_id': 'android_speech_recognizer.en-us.system.2026_05_15',
      'language_tag': 'en-US',
      'display_name': 'English (United States)',
      'engine': 'android_speech_recognizer',
      'engine_version': 'unknown',
      'model_version': 'none',
      'quality_tier': 'fallbackOnly',
      'runtime_mode': 'android_fallback',
      'fallback_policy': 'android_then_cloud_auto',
      'download_url': 'none',
      'download_size_mb': 0,
      'installed_size_mb': 0,
      'sha256': 'none',
      'signature': 'none',
      'license_id': 'android-system-service',
      'commercial_distribution_allowed': false,
      'min_android_sdk': 23,
      'supported_abis': ['arm64-v8a', 'armeabi-v7a', 'x86_64'],
      'min_ram_mb': 0,
      'requires_streaming': false,
      'supports_offline': false,
      'benchmark_status': 'unbenchmarked',
      'benchmark_evidence': 'none',
      'updated_at': updatedAt.toIso8601String(),
    }),
    LanguagePackCatalogEntry.fromMap({
      'pack_id': 'unavailable.hi-in.local.none.2026_05_15',
      'language_tag': 'hi-IN',
      'display_name': 'Hindi (India)',
      'engine': 'unavailable',
      'engine_version': 'none',
      'model_version': 'none',
      'quality_tier': 'fallbackOnly',
      'runtime_mode': 'unavailable',
      'fallback_policy': 'unavailable',
      'download_url': 'none',
      'download_size_mb': 0,
      'installed_size_mb': 0,
      'sha256': 'none',
      'signature': 'none',
      'license_id': 'none',
      'commercial_distribution_allowed': false,
      'min_android_sdk': 23,
      'supported_abis': ['arm64-v8a', 'armeabi-v7a', 'x86_64'],
      'min_ram_mb': 0,
      'requires_streaming': false,
      'supports_offline': false,
      'benchmark_status': 'unbenchmarked',
      'benchmark_evidence': 'none',
      'updated_at': updatedAt.toIso8601String(),
    }),
  ];
}
