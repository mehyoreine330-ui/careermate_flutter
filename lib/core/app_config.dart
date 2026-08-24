import 'package:flutter/foundation.dart' show kReleaseMode;

/// Central place for environment-dependent configuration.
///
/// Values are injected at build/run time via --dart-define, e.g.:
///   flutter run \
///     --dart-define=API_BASE_URL=https://api.careermate.app \
///     --dart-define=WS_BASE_URL=wss://api.careermate.app \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// Never hardcode real keys here — the Supabase anon key is safe to ship
/// client-side (RLS enforces access), but keep it out of source control
/// via --dart-define or a generated dart-define file per environment.
class AppConfig {
  const AppConfig._();

  // String.fromEnvironment's defaultValue only applies when the
  // --dart-define flag is completely absent.
  //
  // GitHub Actions may pass an empty value when a secret is missing.
  // Therefore, explicitly fall back whenever the raw value is empty.

  static const String _rawApiBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  static const String apiBaseUrl =
      _rawApiBaseUrl.isEmpty ? 'http://localhost:8000' : _rawApiBaseUrl;

  static const String _rawWsBaseUrl =
      String.fromEnvironment('WS_BASE_URL');

  static const String wsBaseUrl =
      _rawWsBaseUrl.isEmpty ? 'ws://localhost:8000' : _rawWsBaseUrl;

  static const String _rawSupabaseUrl =
      String.fromEnvironment('SUPABASE_URL');

  static const String supabaseUrl = _rawSupabaseUrl.isEmpty
      ? 'https://bvkigncosefeugtqqnpl.supabase.co'
      : _rawSupabaseUrl;

  static const String _rawSupabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String supabaseAnonKey = _rawSupabaseAnonKey.isEmpty
      ? 'sb_publishable_FVNUeh7AGw0P3DPwNrmPoA_rin14_u-'
      : _rawSupabaseAnonKey;

  /// The base URL this app is currently running from,
  /// including the GitHub Pages path.
  static String get appBaseUrl {
    final uri = Uri.base;

    final path =
        uri.path.endsWith('/') ? uri.path : '${uri.path}/';

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: path,
    ).toString();
  }

  /// Validates the configuration before the app starts.
  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL / SUPABASE_ANON_KEY were not provided at build time.\n'
        'Run with, e.g.:\n'
        '  flutter run -d chrome \\\n'
        '    --dart-define=SUPABASE_URL=https://xxxx.supabase.co \\\n'
        '    --dart-define=SUPABASE_ANON_KEY=eyJ...\n'
        'Find both values in Supabase Dashboard -> Project Settings -> API.',
      );
    }

    if (kReleaseMode &&
        (apiBaseUrl.contains('localhost') ||
            wsBaseUrl.contains('localhost'))) {
      throw StateError(
        'This is a release build but API_BASE_URL/WS_BASE_URL are still '
        'the localhost dev defaults '
        '($apiBaseUrl / $wsBaseUrl).\n'
        'Pass the real production backend URLs at build time, e.g.:\n'
        '  flutter build <target> --release \\\n'
        '    --dart-define=API_BASE_URL=https://api.careermate.app \\\n'
        '    --dart-define=WS_BASE_URL=wss://api.careermate.app\n'
        'or use --dart-define-from-file=env/production.json.',
      );
    }
  }
}
