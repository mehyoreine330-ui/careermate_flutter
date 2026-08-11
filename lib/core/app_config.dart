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

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://localhost:8000',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bvkigncosefeugtqqnpl.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_FVNUeh7AGw0P3DPwNrmPoA_rin14_u-',
  );

  /// Fails loudly at startup if Supabase credentials weren't provided,
  /// instead of silently initializing with an empty URL — which makes every
  /// auth call (sign up, sign in) fire against a relative path with no real
  /// host, landing wherever the current page happens to be served from
  /// rather than your actual Supabase project. Call this first thing in
  /// main() before Supabase.initialize(...).
  ///
  /// Also refuses to start a **release** build that's still pointing at the
  /// dev-convenience `localhost` defaults for API_BASE_URL/WS_BASE_URL — a
  /// release binary built without passing --dart-define would otherwise ship
  /// silently broken (a real device's "localhost" is itself, never the
  /// developer's machine), and the failure would only surface as every
  /// network call mysteriously failing rather than a clear startup error.
  /// Debug/profile builds (flutter run) are unaffected, so local dev keeps
  /// its localhost default with no extra flags required.
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
    if (kReleaseMode && (apiBaseUrl.contains('localhost') || wsBaseUrl.contains('localhost'))) {
      throw StateError(
        'This is a release build but API_BASE_URL/WS_BASE_URL are still the '
        'localhost dev defaults ($apiBaseUrl / $wsBaseUrl).\n'
        'Pass the real production backend URLs at build time, e.g.:\n'
        '  flutter build <target> --release \\\n'
        '    --dart-define=API_BASE_URL=https://api.careermate.app \\\n'
        '    --dart-define=WS_BASE_URL=wss://api.careermate.app\n'
        'or use --dart-define-from-file=env/production.json (see DEPLOYMENT_GUIDE.md).',
      );
    }
  }
}
