import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_models.dart';
import 'auth_provider.dart';

/// Fetches the current user's profile row straight from Supabase Postgres.
/// This is plain CRUD governed by Row Level Security, so it deliberately
/// bypasses FastAPI — the backend is reserved for AI-driven logic (Claude/
/// OpenAI calls), not simple table reads/writes the Supabase client can do
/// directly and safely.
///
/// `null` means the row doesn't exist yet — a brand-new user who hasn't
/// completed onboarding. The auth gate in app.dart uses that to route here.
final userProfileProvider = FutureProvider.autoDispose<OnboardingProfile?>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return null;

  final supabase = ref.watch(supabaseClientProvider);
  final row = await supabase.from('profiles').select().eq('id', userId).maybeSingle();

  if (row == null) return null;
  return OnboardingProfile.fromJson(row);
});

/// Saves edits made on the My Profile screen — a plain field upsert, same
/// RLS-protected direct-to-Supabase pattern as the rest of profile writes.
class ProfileEditController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateFields(Map<String, dynamic> fields) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError(StateError('Not authenticated.'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email ?? '',
        ...fields,
      });
      ref.invalidate(userProfileProvider);
    });
  }
}

final profileEditControllerProvider =
    AsyncNotifierProvider<ProfileEditController, void>(ProfileEditController.new);
