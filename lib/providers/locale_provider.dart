import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import 'auth_provider.dart';

/// Every language CareerMate ships with, in the order they appear in the
/// Settings language picker. Adding a new language later is just: drop
/// lib/l10n/app_<code>.arb next to the existing ones, then add one Locale
/// here — l10n.yaml/AppLocalizations regenerates the rest, no other code
/// changes needed anywhere in the app.
const List<Locale> kSupportedLocales = [
  Locale('en'),
  Locale('ar'),
  Locale('fr'),
  Locale('es'),
  Locale('de'),
  Locale('it'),
  Locale('pt'),
  Locale('tr'),
  Locale('ru'),
  Locale('uk'),
  Locale('zh'),
  Locale('ja'),
  Locale('ko'),
  Locale('hi'),
  Locale('id'),
  Locale('nl'),
  Locale('pl'),
  Locale('sv'),
];

const Locale kDefaultLocale = Locale('en');

/// Display names for the Settings language picker, each written in its own
/// language/script (not translated) so a user can always find their own
/// language regardless of whatever language the UI currently happens to be
/// displaying in.
const Map<String, String> kLocaleNativeNames = {
  'en': 'English',
  'ar': 'العربية',
  'fr': 'Français',
  'es': 'Español',
  'de': 'Deutsch',
  'it': 'Italiano',
  'pt': 'Português',
  'tr': 'Türkçe',
  'ru': 'Русский',
  'uk': 'Українська',
  'zh': '简体中文',
  'ja': '日本語',
  'ko': '한국어',
  'hi': 'हिन्दी',
  'id': 'Bahasa Indonesia',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'sv': 'Svenska',
};

Locale _deviceDefaultLocale() {
  final deviceLocale = PlatformDispatcher.instance.locale;
  final match = kSupportedLocales.where((l) => l.languageCode == deviceLocale.languageCode);
  return match.isEmpty ? kDefaultLocale : match.first;
}

/// Mirrors [localeProvider]'s current value for the handful of plain Dart
/// classes (e.g. ApiService) that are deliberately kept decoupled from
/// Riverpod/BuildContext but still need to localize the odd user-facing
/// string (like a request-timeout message). Kept in sync by
/// [LocaleController] on every build/restore/switch — read-only elsewhere.
Locale currentAppLocale = kDefaultLocale;

/// The app's current display language — a single Riverpod-watched value
/// that MaterialApp's `locale:` reads directly, so changing it triggers a
/// normal widget rebuild across the whole app with no restart involved.
///
/// Starts from the device's locale (or English) so the UI never has to
/// wait on a network round-trip to render in *some* language. Once a
/// signed-in user's saved preference loads from `user_preferences` (see
/// [_restoreForUser]), state updates in place — restoring their choice
/// automatically after login, per the product requirement.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    ref.listen<User?>(currentUserProvider, (previous, next) {
      if (next != null && next.id != previous?.id) {
        _restoreForUser(next.id);
      }
    });

    final user = ref.read(currentUserProvider);
    if (user != null) {
      // ref.listen above only fires on *changes* — a user who already has
      // a session when this provider first builds (app reopened with an
      // existing login) needs this explicit kick to load their saved
      // language too.
      Future.microtask(() => _restoreForUser(user.id));
    }
    final initial = _deviceDefaultLocale();
    currentAppLocale = initial;
    return initial;
  }

  Future<void> _restoreForUser(String userId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final row = await supabase
          .from('user_preferences')
          .select('preferred_language')
          .eq('user_id', userId)
          .maybeSingle();
      final code = row?['preferred_language'] as String?;
      if (code == null) return;
      final match = kSupportedLocales.where((l) => l.languageCode == code);
      if (match.isNotEmpty) {
        state = match.first;
        currentAppLocale = match.first;
      }
    } catch (_) {
      // Best-effort restore — a failed/offline read just leaves whatever
      // locale is already showing rather than blocking the app on it.
    }
  }

  /// Switches the UI language instantly (this state change is what
  /// MaterialApp's `locale:` watches, so every screen rebuilds immediately —
  /// no app restart) and persists the choice to Supabase in the background
  /// so it's restored automatically on the next login.
  Future<void> setLocale(Locale locale) async {
    state = locale;
    currentAppLocale = locale;
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('user_preferences').upsert({
        'user_id': userId,
        'preferred_language': locale.languageCode,
      });
    } catch (_) {
      // A failed persist shouldn't revert the language already applied to
      // the UI — worst case it simply doesn't stick for the next login.
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
