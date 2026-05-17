import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winflowz_app/features/voice/application/language_pack_catalog_provider.dart';
import 'package:winflowz_app/features/voice/data/language_pack_state_repository.dart';
import 'package:winflowz_app/features/voice/domain/language_pack_catalog.dart';

void main() {
  test('LanguagePackCatalogEntry round-trips stable data contract fields', () {
    final entry = LanguagePackCatalogEntry.fromMap(_validLocalPack());

    expect(entry.packId, 'sherpa_onnx.fr-fr.whisper.2026_05_15');
    expect(entry.engine, LanguagePackEngine.sherpaOnnx);
    expect(entry.qualityTier, LanguagePackQualityTier.experimental);
    expect(entry.runtimeMode, LanguagePackRuntimeMode.local);
    expect(entry.toMap(), containsPair('fallback_policy', 'prefer_local'));
  });

  test('invalid catalog entry is rejected as catalog_invalid_entry', () {
    final invalid = _validLocalPack()..remove('signature');

    expect(
      () => LanguagePackCatalogEntry.fromMap(invalid),
      throwsA(
        isA<CatalogValidationException>().having(
          (error) => error.code,
          'code',
          'catalog_invalid_entry',
        ),
      ),
    );
  });

  test(
    'recommended pack requires commercial license and benchmark evidence',
    () {
      final invalid = _validLocalPack()
        ..['quality_tier'] = 'recommended'
        ..['benchmark_status'] = 'passed'
        ..['benchmark_evidence'] = 'shipflow_data/workflow/benchmarks/fr.md';

      expect(
        () => LanguagePackCatalogEntry.fromMap(invalid),
        throwsA(isA<CatalogValidationException>()),
      );
    },
  );

  test(
    'storage policy blocks packs above capacity or free-space threshold',
    () {
      final entry = LanguagePackCatalogEntry.fromMap(_validLocalPack());
      final decision = LanguagePackStoragePolicy.evaluate(
        entry: entry,
        totalCapacityMb: 4096,
        freeSpaceMb: 512,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, LanguagePackFallbackReason.insufficientStorage);
      expect(decision.requiredMb, 1684);
      expect(decision.availableMb, 512);
    },
  );

  test('catalog provider defaults cloud fallback to explicit opt-in', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(languagePackCatalogProvider);

    expect(state.loadState, LanguagePackCatalogLoadState.success);
    expect(state.allowCloudFallback, isFalse);
    expect(state.catalog.entries, isNotEmpty);
  });

  test('install state machine does not mark installed before verification', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(languagePackCatalogProvider.notifier);
    final entry = _firstInstallableEntry(container);

    notifier.markInstalled(entry);
    expect(
      container
          .read(languagePackCatalogProvider)
          .installedStateFor(entry)
          .installState,
      InstalledLanguagePackState.notInstalled,
    );

    notifier.queueInstall(entry);
    notifier.startDownload(entry);
    notifier.updateDownloadProgress(entry, 99);
    notifier.markInstalled(entry);
    expect(
      container
          .read(languagePackCatalogProvider)
          .installedStateFor(entry)
          .installState,
      InstalledLanguagePackState.downloading,
    );

    notifier.updateDownloadProgress(entry, 100);
    expect(
      container
          .read(languagePackCatalogProvider)
          .installedStateFor(entry)
          .installState,
      InstalledLanguagePackState.verifying,
    );
    notifier.markInstalled(entry);

    final installed = container
        .read(languagePackCatalogProvider)
        .installedStateFor(entry);
    expect(installed.installState, InstalledLanguagePackState.installed);
    expect(installed.runtimeMode, LanguagePackRuntimeMode.local);
    expect(installed.checksumVerified, isTrue);
  });

  test('queue install is idempotent for in-flight installs', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(languagePackCatalogProvider.notifier);
    final entry = _firstInstallableEntry(container);

    notifier.queueInstall(entry);
    final first = container
        .read(languagePackCatalogProvider)
        .installedStateFor(entry);
    notifier.queueInstall(entry);
    final second = container
        .read(languagePackCatalogProvider)
        .installedStateFor(entry);

    expect(first.installState, InstalledLanguagePackState.queued);
    expect(second.installState, InstalledLanguagePackState.queued);
    expect(second.downloadProgress, first.downloadProgress);
  });

  test('retry limit is capped at three attempts', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(languagePackCatalogProvider.notifier);
    final entry = _firstInstallableEntry(container);

    notifier.queueInstall(entry);
    notifier.startDownload(entry);
    notifier.failDownload(entry);

    expect(notifier.retryInstall(entry), isTrue);
    notifier.startDownload(entry);
    notifier.failDownload(entry);
    expect(notifier.retryInstall(entry), isTrue);
    notifier.startDownload(entry);
    notifier.failDownload(entry);
    expect(notifier.retryInstall(entry), isTrue);
    notifier.startDownload(entry);
    notifier.failDownload(entry);
    expect(notifier.retryInstall(entry), isFalse);

    final state = container.read(languagePackCatalogProvider);
    expect(state.retryCounts[entry.packId], 3);
    expect(state.installedStateFor(entry).lastErrorCode, 'retry_limit_reached');
  });

  test('state repository persists installed packs and cloud fallback', () {
    final repository = InMemoryLanguagePackCatalogStateRepository();

    final firstContainer = ProviderContainer(
      overrides: [
        languagePackCatalogStateRepositoryProvider.overrideWithValue(
          repository,
        ),
      ],
    );
    final entry = _firstInstallableEntry(firstContainer);
    final firstNotifier = firstContainer.read(
      languagePackCatalogProvider.notifier,
    );

    firstNotifier.setAllowCloudFallback(true);
    firstNotifier.queueInstall(entry);
    firstNotifier.startDownload(entry);
    firstNotifier.updateDownloadProgress(entry, 100);
    firstNotifier.markInstalled(entry);
    firstContainer.dispose();

    final secondContainer = ProviderContainer(
      overrides: [
        languagePackCatalogStateRepositoryProvider.overrideWithValue(
          repository,
        ),
      ],
    );
    addTearDown(secondContainer.dispose);
    final secondState = secondContainer.read(languagePackCatalogProvider);
    final installed = secondState.installedStateFor(entry);

    expect(secondState.allowCloudFallback, isTrue);
    expect(installed.installState, InstalledLanguagePackState.installed);
    expect(installed.checksumVerified, isTrue);
  });
}

Map<Object?, Object?> _validLocalPack() => {
  'pack_id': 'sherpa_onnx.fr-fr.whisper.2026_05_15',
  'language_tag': 'fr-FR',
  'display_name': 'French (France)',
  'engine': 'sherpa_onnx',
  'engine_version': 'candidate',
  'model_version': 'whisper-candidate',
  'quality_tier': 'experimental',
  'runtime_mode': 'local',
  'fallback_policy': 'prefer_local',
  'download_url': 'https://downloads.winflowz.local/fr.zip',
  'download_size_mb': 82,
  'installed_size_mb': 148,
  'sha256': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  'signature': 'winflowz-dev-signature',
  'license_id': 'MIT-review-required',
  'commercial_distribution_allowed': false,
  'min_android_sdk': 26,
  'supported_abis': ['arm64-v8a'],
  'min_ram_mb': 4096,
  'requires_streaming': true,
  'supports_offline': true,
  'benchmark_status': 'candidate',
  'benchmark_evidence':
      'shipflow_data/workflow/specs/on-device-asr-free-options-research.md',
  'updated_at': '2026-05-15T19:19:39Z',
};

LanguagePackCatalogEntry _firstInstallableEntry(ProviderContainer container) {
  return container
      .read(languagePackCatalogProvider)
      .catalog
      .entries
      .firstWhere((entry) => entry.isInstallable);
}
