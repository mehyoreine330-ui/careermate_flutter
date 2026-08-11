import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/opportunity_models.dart';
import 'resume_provider.dart';

/// Every scored internship/graduate-program recommendation, sorted by match
/// score (server-side).
///
/// Deliberately NOT autoDispose — same rationale as jobRecommendationsProvider
/// (job_matching_provider.dart): scoring every sample opportunity is a real
/// AI call, so it's cached for the rest of the app session rather than
/// re-run on every visit. Invalidated after a new resume analysis completes.
final opportunityRecommendationsProvider = FutureProvider<List<OpportunityRecommendation>>((ref) {
  return ref.watch(apiServiceProvider).getInternshipRecommendations();
});

/// Distinct countries/fields present in the current recommendations, for
/// the filter dropdowns — derived, not a separate API call.
final availableOpportunityCountriesProvider = Provider.autoDispose<List<String>>((ref) {
  final recommendations = ref.watch(opportunityRecommendationsProvider).valueOrNull ?? const [];
  final countries = recommendations.map((r) => r.opportunity.country).toSet().toList()..sort();
  return countries;
});

final availableOpportunityFieldsProvider = Provider.autoDispose<List<String>>((ref) {
  final recommendations = ref.watch(opportunityRecommendationsProvider).valueOrNull ?? const [];
  final fields = recommendations.map((r) => r.opportunity.field).toSet().toList()..sort();
  return fields;
});

class OpportunityFilterState {
  const OpportunityFilterState({
    this.country,
    this.fieldOfStudy,
    this.internship = false,
    this.graduateProgram = false,
    this.remote = false,
    this.hybrid = false,
    this.onsite = false,
    this.paid = false,
    this.unpaid = false,
  });

  final String? country;
  final String? fieldOfStudy;
  final bool internship;
  final bool graduateProgram;
  final bool remote;
  final bool hybrid;
  final bool onsite;
  final bool paid;
  final bool unpaid;

  bool get hasActiveFilters =>
      country != null ||
      fieldOfStudy != null ||
      internship ||
      graduateProgram ||
      remote ||
      hybrid ||
      onsite ||
      paid ||
      unpaid;

  OpportunityFilterState copyWith({
    String? country,
    bool clearCountry = false,
    String? fieldOfStudy,
    bool clearFieldOfStudy = false,
    bool? internship,
    bool? graduateProgram,
    bool? remote,
    bool? hybrid,
    bool? onsite,
    bool? paid,
    bool? unpaid,
  }) {
    return OpportunityFilterState(
      country: clearCountry ? null : (country ?? this.country),
      fieldOfStudy: clearFieldOfStudy ? null : (fieldOfStudy ?? this.fieldOfStudy),
      internship: internship ?? this.internship,
      graduateProgram: graduateProgram ?? this.graduateProgram,
      remote: remote ?? this.remote,
      hybrid: hybrid ?? this.hybrid,
      onsite: onsite ?? this.onsite,
      paid: paid ?? this.paid,
      unpaid: unpaid ?? this.unpaid,
    );
  }
}

/// Filters apply client-side over the already-scored recommendation list —
/// re-running the AI scoring call on every filter toggle would be slow and
/// wasteful for no benefit, same rationale as Job Matching.
class OpportunityFilterController extends Notifier<OpportunityFilterState> {
  @override
  OpportunityFilterState build() => const OpportunityFilterState();

  void setCountry(String? country) {
    state = country == null ? state.copyWith(clearCountry: true) : state.copyWith(country: country);
  }

  void setFieldOfStudy(String? field) {
    state = field == null ? state.copyWith(clearFieldOfStudy: true) : state.copyWith(fieldOfStudy: field);
  }

  void toggleInternship() => state = state.copyWith(internship: !state.internship);
  void toggleGraduateProgram() => state = state.copyWith(graduateProgram: !state.graduateProgram);
  void toggleRemote() => state = state.copyWith(remote: !state.remote);
  void toggleHybrid() => state = state.copyWith(hybrid: !state.hybrid);
  void toggleOnsite() => state = state.copyWith(onsite: !state.onsite);
  void togglePaid() => state = state.copyWith(paid: !state.paid);
  void toggleUnpaid() => state = state.copyWith(unpaid: !state.unpaid);

  void clear() => state = const OpportunityFilterState();
}

final opportunityFilterProvider =
    NotifierProvider<OpportunityFilterController, OpportunityFilterState>(OpportunityFilterController.new);

List<OpportunityRecommendation> _applyOpportunityFilters(
  List<OpportunityRecommendation> recommendations,
  OpportunityFilterState filters,
) {
  final kindFilters = <String>[
    if (filters.internship) 'internship',
    if (filters.graduateProgram) 'graduate_program',
  ];
  final arrangementFilters = <String>[
    if (filters.remote) 'remote',
    if (filters.hybrid) 'hybrid',
    if (filters.onsite) 'onsite',
  ];
  final paidFilters = <bool>[
    if (filters.paid) true,
    if (filters.unpaid) false,
  ];

  return recommendations.where((rec) {
    final opportunity = rec.opportunity;
    if (filters.country != null && opportunity.country != filters.country) return false;
    if (filters.fieldOfStudy != null && opportunity.field != filters.fieldOfStudy) return false;
    if (kindFilters.isNotEmpty && !kindFilters.contains(opportunity.kind)) return false;
    if (arrangementFilters.isNotEmpty && !arrangementFilters.contains(opportunity.workArrangement)) return false;
    if (paidFilters.isNotEmpty && !paidFilters.contains(opportunity.isPaid)) return false;
    return true;
  }).toList();
}

/// The list the screen actually renders: recommendations with the current
/// filters applied. Stays an [AsyncValue] so loading/error states pass
/// through untouched from [opportunityRecommendationsProvider].
final filteredOpportunityRecommendationsProvider = Provider.autoDispose<AsyncValue<List<OpportunityRecommendation>>>((ref) {
  final recommendationsAsync = ref.watch(opportunityRecommendationsProvider);
  final filters = ref.watch(opportunityFilterProvider);
  return recommendationsAsync.whenData((recs) => _applyOpportunityFilters(recs, filters));
});
