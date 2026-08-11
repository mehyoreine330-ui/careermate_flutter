import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

const _employerJobIdPrefix = 'employer-';

/// Whether a Job Matching card's JobPosting.id refers to a real,
/// employer-posted job (as opposed to Adzuna/sample-sourced) — see
/// careermate-backend's services/employer_job_conversion.py, the single
/// source of truth for what "employer-{id}" means.
bool isEmployerSourcedJob(String jobPostingId) => jobPostingId.startsWith(_employerJobIdPrefix);

/// Reverses the "employer-{id}" JobPosting id back to the real
/// employer_jobs.id — null if this posting isn't employer-sourced.
String? employerJobIdFromPostingId(String jobPostingId) {
  if (!isEmployerSourcedJob(jobPostingId)) return null;
  return jobPostingId.substring(_employerJobIdPrefix.length);
}

/// Real employer_jobs ids (not the "employer-" prefixed JobPosting id) the
/// current candidate has already applied to — used to show "Applied"
/// instead of "Apply" on Job Matching cards. Plain CRUD, RLS-protected
/// direct-to-Supabase read (same rationale as profile_provider.dart).
final myAppliedEmployerJobIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return {};

  final supabase = ref.watch(supabaseClientProvider);
  final rows = await supabase.from('employer_job_applications').select('job_id').eq('candidate_user_id', userId);

  return (rows as List).map((row) => row['job_id'] as String).toSet();
});

/// Applying to a real employer job — a plain RLS-protected insert (the
/// "Candidates can apply to jobs" policy only allows a candidate to insert
/// a row for themselves), same direct-to-Supabase pattern as everywhere
/// else plain CRUD lives in this app.
class CandidateApplyController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> apply(String employerJobId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError(StateError('Not authenticated.'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('employer_job_applications').insert({
        'job_id': employerJobId,
        'candidate_user_id': user.id,
      });
      ref.invalidate(myAppliedEmployerJobIdsProvider);
    });
  }
}

final candidateApplyControllerProvider =
    AsyncNotifierProvider<CandidateApplyController, void>(CandidateApplyController.new);
