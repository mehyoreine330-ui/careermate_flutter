import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/generated/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/employer_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/ai_welcome_screen.dart';
import 'screens/app_shell_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/employer/employer_shell_screen.dart';
import 'screens/landing_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_background.dart';

class CareerMateApp extends ConsumerWidget {
  const CareerMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'CareerMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // dark by design, not just a fallback
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _AuthGate(),
    );
  }
}

/// Routes to account-type resolution/login when a Supabase session exists,
/// login otherwise. Watches the auth stream directly (rather than a
/// one-shot check) so a token refresh or sign-out anywhere in the app
/// updates this immediately.
///
/// A `passwordRecovery` event (the user followed a reset-password email
/// link) always wins over the normal session check — Supabase establishes
/// a session for the recovery flow too, but it must land on
/// ResetPasswordScreen, not the account-type/onboarding gates below.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordScreen();
        }
        return state.session != null ? const _AccountTypeGate() : const LandingScreen();
      },
      loading: () => const _LoadingScaffold(),
      error: (error, _) => const LoginScreen(),
    );
  }
}

/// First gate reached after authentication: an account is an employer
/// purely by having a `companies` row (same implicit-typing convention
/// `profiles` uses for candidates) — the Employer Portal and the candidate
/// app are fully separate experiences that never mix in one session.
class _AccountTypeGate extends ConsumerWidget {
  const _AccountTypeGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyAsync = ref.watch(companyProfileProvider);

    return companyAsync.when(
      data: (company) => company != null ? const EmployerShellScreen() : const _OnboardingGate(),
      loading: () => const _LoadingScaffold(),
      // Fail open to the candidate flow rather than lock the user out
      // entirely if the companies-row check errors transiently.
      error: (error, _) => const _OnboardingGate(),
    );
  }
}

/// Second gate, only reached for candidate accounts (no `companies` row):
/// routes to the AI Welcome onboarding chat if the user has no `profiles`
/// row yet or hasn't finished it (`onboarding_completed` is false),
/// dashboard otherwise.
class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) => (profile == null || !profile.onboardingCompleted)
          ? const AiWelcomeScreen()
          : const AppShellScreen(),
      loading: () => const _LoadingScaffold(),
      // Fail open to onboarding rather than lock the user out entirely if
      // the profile fetch errors (e.g. transient network issue).
      error: (error, _) => const AiWelcomeScreen(),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
