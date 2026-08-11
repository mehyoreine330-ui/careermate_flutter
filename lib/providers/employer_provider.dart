import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employer_models.dart';
import 'auth_provider.dart';
import 'resume_provider.dart';

/// Fetches the current user's `companies` row straight from Supabase
/// Postgres — plain CRUD governed by Row Level Security, same rationale as
/// userProfileProvider (profile_provider.dart): the backend is reserved for
/// AI-driven logic, not simple table reads/writes.
///
/// `null` means no company row exists for this account — either a
/// candidate account, or an employer who hasn't finished signing up yet.
/// app.dart's account-type gate uses this to decide candidate vs. employer
/// routing.
final companyProfileProvider = FutureProvider.autoDispose<Company?>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return null;

  final supabase = ref.watch(supabaseClientProvider);
  final row = await supabase.from('companies').select().eq('id', userId).maybeSingle();

  if (row == null) return null;
  return Company.fromJson(row);
});

/// Saves company profile edits (and creates the initial row at employer
/// sign-up) — a plain field upsert, same RLS-protected direct-to-Supabase
/// pattern as ProfileEditController.
class CompanyProfileController extends AsyncNotifier<void> {
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
      await supabase.from('companies').upsert({
        'id': user.id,
        'email': user.email ?? '',
        ...fields,
      });
      ref.invalidate(companyProfileProvider);
    });
  }
}

final companyProfileControllerProvider =
    AsyncNotifierProvider<CompanyProfileController, void>(CompanyProfileController.new);

/// Every job the current company has posted, most recent first — plain
/// CRUD, RLS-protected, direct-to-Supabase (same rationale as above).
final employerJobsProvider = FutureProvider.autoDispose<List<EmployerJob>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];

  final supabase = ref.watch(supabaseClientProvider);
  final rows = await supabase
      .from('employer_jobs')
      .select()
      .eq('company_id', userId)
      .order('created_at', ascending: false);

  return (rows as List).map((row) => EmployerJob.fromJson(row as Map<String, dynamic>)).toList();
});

/// Create / edit / delete / archive a job posting — plain CRUD, RLS
/// enforces a company can only ever touch its own jobs.
class EmployerJobController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createJob(EmployerJob job) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('employer_jobs').insert(job.toUpsertJson());
      ref.invalidate(employerJobsProvider);
    });
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> fields) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('employer_jobs').update(fields).eq('id', jobId);
      ref.invalidate(employerJobsProvider);
    });
  }

  Future<void> archiveJob(String jobId) => updateJob(jobId, {'status': 'archived'});

  Future<void> reactivateJob(String jobId) => updateJob(jobId, {'status': 'active'});

  Future<void> deleteJob(String jobId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('employer_jobs').delete().eq('id', jobId);
      ref.invalidate(employerJobsProvider);
    });
  }
}

final employerJobControllerProvider =
    AsyncNotifierProvider<EmployerJobController, void>(EmployerJobController.new);

/// Total/active job + application/interview counts — the one thing worth
/// asking the backend for rather than doing client-side, since it's a
/// convenience aggregation the FastAPI layer already computes.
final employerDashboardProvider = FutureProvider.autoDispose<EmployerDashboardStats>((ref) {
  return ref.watch(apiServiceProvider).getEmployerDashboard();
});

/// A lightweight per-job applicant count for the Jobs list card — plain
/// CRUD (a row count, not AI scoring), so it's a direct RLS-protected
/// Supabase read rather than a call to the applicants-scoring endpoint.
final jobApplicantCountProvider = FutureProvider.autoDispose.family<int, String>((ref, jobId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final rows = await supabase.from('employer_job_applications').select('id').eq('job_id', jobId);
  return (rows as List).length;
});

/// Every applicant to one job, each scored by the same AI Job Matching
/// engine used for candidates — a real backend call (services/
/// employer_applicant_service.py), not client-side Supabase, since RLS
/// otherwise blocks a company from ever reading a candidate's resume/
/// career report/profile.
final jobApplicantsProvider =
    FutureProvider.autoDispose.family<List<ApplicantRecommendation>, String>((ref, jobId) {
  return ref.watch(apiServiceProvider).getJobApplicants(jobId);
});

/// Shortlist / Reject / Mark Interview / Hire.
class ApplicationStatusController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateStatus({
    required String jobId,
    required String applicationId,
    required String newStatus,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiServiceProvider).updateApplicationStatus(applicationId, newStatus);
      ref.invalidate(jobApplicantsProvider(jobId));
      ref.invalidate(employerDashboardProvider);
    });
  }
}

final applicationStatusControllerProvider =
    AsyncNotifierProvider<ApplicationStatusController, void>(ApplicationStatusController.new);
