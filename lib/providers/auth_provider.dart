import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_config.dart';

/// The Supabase client is the single source of truth for identity —
/// FastAPI never issues or validates sessions itself, it just verifies
/// the token Supabase already signed. Everything auth-related in the
/// app should go through this client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Live stream of auth state changes (sign in, sign out, token refresh).
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

/// The current user, derived from the auth stream but falling back to
/// the synchronously available session so the very first frame isn't
/// stuck showing "logged out" while the stream provider is still loading.
final currentUserProvider = Provider<User?>((ref) {
  final streamed = ref.watch(authStateChangesProvider).valueOrNull;
  return streamed?.session?.user ?? ref.watch(supabaseClientProvider).auth.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Handles sign in / sign up / sign out. Exposed as AsyncNotifier so the
/// login screen can show a spinner and surface errors via `state.hasError`
/// without any manual try/catch boilerplate in the widget.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial async work — auth state itself is tracked by
    // authStateChangesProvider above.
  }

  /// Returns the signed-in user directly from the auth response (or null if
  /// the call failed — check `state.hasError` for the actual error).
  /// Callers that need the user's id right away (e.g. to write a row keyed
  /// on it in the same flow, see EmployerLoginScreen) should use this
  /// return value rather than reading currentUserProvider immediately
  /// afterward — the auth-state-change stream that provider derives from
  /// can lag a beat behind the call actually resolving.
  Future<User?> signInWithPassword({required String email, required String password}) async {
    state = const AsyncLoading();
    User? signedInUser;
    state = await AsyncValue.guard(() async {
      final response = await ref.read(supabaseClientProvider).auth.signInWithPassword(
            email: email,
            password: password,
          );
      signedInUser = response.user;
    });
    return signedInUser;
  }

  /// See signInWithPassword's doc comment — same rationale for the returned user.
  Future<User?> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    User? createdUser;
    state = await AsyncValue.guard(() async {
      final response = await ref.read(supabaseClientProvider).auth.signUp(email: email, password: password);
      createdUser = response.user;
    });
    return createdUser;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseClientProvider).auth.signOut();
    });
  }

  /// Sends a password-reset email via Supabase Auth's built-in flow. The
  /// link redirects back to wherever this app is actually running —
  /// AppConfig.appBaseUrl, not just Uri.base.origin, so this round-trips
  /// correctly on a GitHub Pages project subpath too (Flutter Web only for
  /// now — a native build needs a registered deep-link scheme, which isn't
  /// configured yet). On arrival, onAuthStateChange fires
  /// AuthChangeEvent.passwordRecovery and app.dart's _AuthGate shows
  /// ResetPasswordScreen — this requires the target URL to also be listed
  /// in Supabase Dashboard -> Authentication -> URL Configuration ->
  /// Redirect URLs, or Supabase silently ignores it and falls back to the
  /// dashboard's default Site URL instead.
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseClientProvider).auth.resetPasswordForEmail(
            email,
            redirectTo: AppConfig.appBaseUrl,
          );
    });
  }

  /// Sets a new password during the recovery flow — requires the recovery
  /// session established by the reset-email link to still be active.
  Future<void> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseClientProvider).auth.updateUser(
            UserAttributes(password: newPassword),
          );
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);
