import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_matching_models.dart';
import '../models/saved_job_models.dart';
import 'auth_provider.dart';

/// Every job the current candidate has bookmarked, most recently saved
/// first. Plain CRUD, RLS-protected, direct-to-Supabase — same rationale
/// as everywhere else plain CRUD lives in this app.
final savedJobsProvider = FutureProvider.autoDispose<List<SavedJob>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];

  final supabase = ref.watch(supabaseClientProvider);
  final rows = await supabase
      .from('saved_jobs')
      .select()
      .eq('candidate_user_id', userId)
      .order('saved_at', ascending: false);

  return (rows as List).map((row) => SavedJob.fromJson(row as Map<String, dynamic>)).toList();
});

/// Derived from savedJobsProvider — which JobPosting.id values are
/// currently saved, for the bookmark icon's filled/outline state on Job
/// Matching cards.
final savedJobPostingIdsProvider = Provider.autoDispose<Set<String>>((ref) {
  final saved = ref.watch(savedJobsProvider).valueOrNull ?? const [];
  return saved.map((s) => s.jobPostingId).toSet();
});

class SavedJobsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(JobPosting job, {int? matchScore}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError(StateError('Not authenticated.'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('saved_jobs').insert({
        'candidate_user_id': user.id,
        'job_posting_id': job.id,
        'job_snapshot': job.toJson(),
        'match_score': matchScore,
      });
      ref.invalidate(savedJobsProvider);
    });
  }

  Future<void> unsave(String jobPostingId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError(StateError('Not authenticated.'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase
          .from('saved_jobs')
          .delete()
          .eq('candidate_user_id', user.id)
          .eq('job_posting_id', jobPostingId);
      ref.invalidate(savedJobsProvider);
    });
  }
}

final savedJobsControllerProvider = AsyncNotifierProvider<SavedJobsController, void>(SavedJobsController.new);
