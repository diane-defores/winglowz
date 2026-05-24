class AppBuildInfo {
  AppBuildInfo._();

  static const sha = String.fromEnvironment(
    'WINFLOWZ_APP_BUILD_SHA',
    defaultValue: 'local',
  );
  static const runId = String.fromEnvironment(
    'WINFLOWZ_APP_BUILD_RUN_ID',
    defaultValue: 'local',
  );
  static const refName = String.fromEnvironment(
    'WINFLOWZ_APP_BUILD_REF',
    defaultValue: 'local',
  );

  static String get shortSha {
    if (sha.length <= 7) {
      return sha;
    }
    return sha.substring(0, 7);
  }

  static String get diagnosticSummary =>
      'sha=$shortSha | run=$runId | ref=$refName';
}
