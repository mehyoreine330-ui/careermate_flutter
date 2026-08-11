import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_matching_models.dart';
import 'resume_provider.dart';

/// Every scored job recommendation, sorted by match score (server-side).
///
/// Deliberately NOT autoDispose: scoring every sample job is a real AI call
/// (real cost + ~15-25s latency), so the result is cached for the rest of
/// the app session once fetched, instead of re-running on every visit to
/// the Job Matching tab. resume_analyzer_screen.dart invalidates this after
/// a new resume analysis completes, since a changed resume changes matches.
final jobRecommendationsProvider = FutureProvider<List<JobRecommendation>>((ref) {
  return ref.watch(apiServiceProvider).getJobRecommendations();
});

/// Distinct countries present in the current recommendations, for the
/// Country filter dropdown — derived, not a separate API call.
final availableJobCountriesProvider = Provider.autoDispose<List<String>>((ref) {
  final recommendations = ref.watch(jobRecommendationsProvider).valueOrNull ?? const [];
  final countries = recommendations.map((r) => r.job.country).toSet().toList()..sort();
  return countries;
});

class JobFilterState {
  const JobFilterState({
    this.country,
    this.remote = false,
    this.hybrid = false,
    this.onsite = false,
    this.internship = false,
    this.fullTime = false,
    this.partTime = false,
    this.entryLevel = false,
  });

  final String? country;
  final bool remote;
  final bool hybrid;
  final bool onsite;
  final bool internship;
  final bool fullTime;
  final bool partTime;
  final bool entryLevel;

  bool get hasActiveFilters =>
      country != null || remote || hybrid || onsite || internship || fullTime || partTime || entryLevel;

  JobFilterState copyWith({
    String? country,
    bool clearCountry = false,
    bool? remote,
    bool? hybrid,
    bool? onsite,
    bool? internship,
    bool? fullTime,
    bool? partTime,
    bool? entryLevel,
  }) {
    return JobFilterState(
      country: clearCountry ? null : (country ?? this.country),
      remote: remote ?? this.remote,
      hybrid: hybrid ?? this.hybrid,
      onsite: onsite ?? this.onsite,
      internship: internship ?? this.internship,
      fullTime: fullTime ?? this.fullTime,
      partTime: partTime ?? this.partTime,
      entryLevel: entryLevel ?? this.entryLevel,
    );
  }
}

/// Filters apply client-side over the already-scored recommendation list —
/// re-running the AI scoring call on every filter toggle would be slow and
/// wasteful for no benefit, since the job set is small and already scored.
class JobFilterController extends Notifier<JobFilterState> {
  @override
  JobFilterState build() => const JobFilterState();

  void setCountry(String? country) {
    state = country == null ? state.copyWith(clearCountry: true) : state.copyWith(country: country);
  }

  void toggleRemote() => state = state.copyWith(remote: !state.remote);
  void toggleHybrid() => state = state.copyWith(hybrid: !state.hybrid);
  void toggleOnsite() => state = state.copyWith(onsite: !state.onsite);
  void toggleInternship() => state = state.copyWith(internship: !state.internship);
  void toggleFullTime() => state = state.copyWith(fullTime: !state.fullTime);
  void togglePartTime() => state = state.copyWith(partTime: !state.partTime);
  void toggleEntryLevel() => state = state.copyWith(entryLevel: !state.entryLevel);

  void clear() => state = const JobFilterState();
}

final jobFilterProvider = NotifierProvider<JobFilterController, JobFilterState>(JobFilterController.new);

List<JobRecommendation> _applyJobFilters(List<JobRecommendation> recommendations, JobFilterState filters) {
  final arrangementFilters = <String>[
    if (filters.remote) 'remote',
    if (filters.hybrid) 'hybrid',
    if (filters.onsite) 'onsite',
  ];
  final typeFilters = <String>[
    if (filters.internship) 'internship',
    if (filters.fullTime) 'full_time',
    if (filters.partTime) 'part_time',
  ];

  return recommendations.where((rec) {
    final job = rec.job;
    if (filters.country != null && job.country != filters.country) return false;
    if (arrangementFilters.isNotEmpty && !arrangementFilters.contains(job.workArrangement)) return false;
    if (typeFilters.isNotEmpty && !typeFilters.contains(job.employmentType)) return false;
    if (filters.entryLevel && job.experienceLevel != 'entry') return false;
    return true;
  }).toList();
}

/// The list the screen actually renders: recommendations with the current
/// filters applied. Stays an [AsyncValue] so loading/error states pass
/// through untouched from [jobRecommendationsProvider].
final filteredJobRecommendationsProvider = Provider.autoDispose<AsyncValue<List<JobRecommendation>>>((ref) {
  final recommendationsAsync = ref.watch(jobRecommendationsProvider);
  final filters = ref.watch(jobFilterProvider);
  return recommendationsAsync.whenData((recs) => _applyJobFilters(recs, filters));
});
