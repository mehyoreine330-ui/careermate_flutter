import 'package:flutter/foundation.dart' show kReleaseMode;

class AppConfig {
  const AppConfig._();

  static const String _rawApiBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  static final String apiBaseUrl =
      _rawApiBaseUrl.isEmpty ? 'http://localhost:8000' : _rawApiBaseUrl;

  static const String _rawWsBaseUrl =
      String.fromEnvironment('WS_BASE_URL');

  static final String wsBaseUrl =
      _rawWsBaseUrl.isEmpty ? 'ws://localhost:8000' : _rawWsBaseUrl;

  static const String _rawSupabaseUrl =
      String.fromEnvironment('SUPABASE_URL');

  static final String supabaseUrl =
      _rawSupabaseUrl.isEmpty
          ? 'https://bvkigncosefeugtqqnpl.supabase.co'
          : _rawSupabaseUrl;

  static const String _rawSupabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static final String supabaseAnonKey =
      _rawSupabaseAnonKey.isEmpty
          ? 'sb_publishable_FVNUeh7AGw0P3DPwNrmPoA_rin14_u-'
          : _rawSupabaseAnonKey;

  static String get appBaseUrl {
    final uri = Uri.base;
    final path = uri.path.endsWith('/')
        ? uri.path
        : '${uri.path}/';

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: path,
    ).toString();
  }

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL / SUPABASE_ANON_KEY were not provided.',
      );
    }

    if (kReleaseMode &&
        (apiBaseUrl.contains('localhost') ||
            wsBaseUrl.contains('localhost'))) {
      throw StateError(
        'Release build is using localhost API URLs.',
      );
    }
  }
}
