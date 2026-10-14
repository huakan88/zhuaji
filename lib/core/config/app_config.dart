enum AppEnv { local, staging, prod }

/// API base URL for the current build.
///
/// Switch with `--dart-define=API_ENV=local|staging|prod`.
/// A full override wins: `--dart-define=API_BASE_URL=http://10.0.2.2:8094`.
class AppConfig {
  const AppConfig({this.env = AppEnv.local, this.baseUrlOverride});

  factory AppConfig.fromEnvironment() {
    const envName = String.fromEnvironment('API_ENV', defaultValue: 'local');
    const override = String.fromEnvironment('API_BASE_URL');
    return AppConfig(
      env: parseAppEnv(envName),
      baseUrlOverride: override.isEmpty ? null : override,
    );
  }

  final AppEnv env;
  final String? baseUrlOverride;

  String get apiBaseUrl {
    final override = baseUrlOverride;
    if (override != null && override.isNotEmpty) {
      return override.endsWith('/')
          ? override.substring(0, override.length - 1)
          : override;
    }
    return switch (env) {
      AppEnv.local => 'http://10.0.2.2:8094',
      AppEnv.staging => 'https://staging-api.zhuaji.local',
      AppEnv.prod => 'https://api.zhuaji.local',
    };
  }
}

AppEnv parseAppEnv(String raw) {
  return switch (raw) {
    'staging' => AppEnv.staging,
    'prod' => AppEnv.prod,
    _ => AppEnv.local,
  };
}
