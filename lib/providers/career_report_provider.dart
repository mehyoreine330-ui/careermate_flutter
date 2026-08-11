import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/career_report_models.dart';
import 'locale_provider.dart';
import 'resume_provider.dart';

/// The user's most recent career report, or null if they haven't generated
/// one yet. `autoDispose` so it refetches whenever a screen watching it
/// (Dashboard, Career Report screen) is revisited rather than caching a
/// stale result for the app's lifetime.
final latestCareerReportProvider = FutureProvider.autoDispose<CareerReport?>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getLatestCareerReport();
});

/// Every career report the user has generated, most recent first.
final careerReportHistoryProvider = FutureProvider.autoDispose<List<CareerReport>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getCareerReportHistory();
});

/// Drives "Generate Career Report" — kept separate from
/// [latestCareerReportProvider] (same pattern as ResumeAnalysisController vs.
/// AutoFixController) so a fresh generation's loading/error state doesn't
/// clobber whatever report is already on screen.
class CareerReportGenerationController extends AsyncNotifier<CareerReport?> {
  @override
  FutureOr<CareerReport?> build() => null;

  Future<void> generate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final language = ref.read(localeProvider).languageCode;
      final report = await ref.read(apiServiceProvider).generateCareerReport(language: language);
      // Refresh the cached "latest" so the Dashboard and Career Report
      // screen pick up the new report immediately.
      ref.invalidate(latestCareerReportProvider);
      ref.invalidate(careerReportHistoryProvider);
      return report;
    });
  }

  void reset() => state = const AsyncData(null);
}

final careerReportGenerationProvider =
    AsyncNotifierProvider<CareerReportGenerationController, CareerReport?>(
  CareerReportGenerationController.new,
);
