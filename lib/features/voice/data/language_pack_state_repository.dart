import '../domain/language_pack_catalog.dart';

class LanguagePackCatalogLocalState {
  const LanguagePackCatalogLocalState({
    this.installedPacks = const <String, InstalledLanguagePack>{},
    this.retryCounts = const <String, int>{},
    this.allowCloudFallback = false,
  });

  final Map<String, InstalledLanguagePack> installedPacks;
  final Map<String, int> retryCounts;
  final bool allowCloudFallback;
}

abstract class LanguagePackCatalogStateRepository {
  LanguagePackCatalogLocalState read();

  void write(LanguagePackCatalogLocalState state);
}

class InMemoryLanguagePackCatalogStateRepository
    implements LanguagePackCatalogStateRepository {
  LanguagePackCatalogLocalState _state = const LanguagePackCatalogLocalState();

  @override
  LanguagePackCatalogLocalState read() {
    return LanguagePackCatalogLocalState(
      installedPacks: Map<String, InstalledLanguagePack>.of(
        _state.installedPacks,
      ),
      retryCounts: Map<String, int>.of(_state.retryCounts),
      allowCloudFallback: _state.allowCloudFallback,
    );
  }

  @override
  void write(LanguagePackCatalogLocalState state) {
    _state = LanguagePackCatalogLocalState(
      installedPacks: Map<String, InstalledLanguagePack>.of(
        state.installedPacks,
      ),
      retryCounts: Map<String, int>.of(state.retryCounts),
      allowCloudFallback: state.allowCloudFallback,
    );
  }
}
