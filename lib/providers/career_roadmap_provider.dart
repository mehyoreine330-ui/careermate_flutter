import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/career_roadmap_models.dart';
import 'locale_provider.dart';
import 'resume_provider.dart';

/// Fetches (or transparently generates) the user's Career Roadmap for their
/// *current* latest resume — this is what makes generation "automatic after
/// Resume Analysis" without touching Resume Analyzer's own files at all:
/// this provider only ever *reads* the existing, unmodified
/// [latestResumeSummaryProvider] as a signal.
///
/// Logic: no analyzed resume yet -> null (screen shows an empty state
/// pointing at Resume Analyzer). A resume exists but no roadmap, or the
/// existing roadmap's `resumeId` no longer matches the latest resume (the
/// user re-analyzed a newer CV) -> generate one immediately, no button, no
/// extra click. Otherwise the existing up-to-date roadmap is returned as-is.
final autoCareerRoadmapProvider = FutureProvider.autoDispose<CareerRoadmap?>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final latestResume = await ref.watch(latestResumeSummaryProvider.future);
  if (latestResume == null) return null;

  final existing = await api.getLatestCareerRoadmap();
  if (existing != null && existing.resumeId == latestResume.id) {
    return existing;
  }
  final language = ref.read(localeProvider).languageCode;
  return api.generateCareerRoadmap(language: language);
});

/// Drives the explicit "Regenerate" action (once a roadmap already exists,
/// the user may want to force a fresh one against the same resume, e.g.
/// after editing their profile) — kept separate so its loading/error state
/// doesn't clobber the roadmap already on screen, same pattern as
/// CareerReportGenerationController.
class CareerRoadmapRegenerateController extends AsyncNotifier<CareerRoadmap?> {
  @override
  FutureOr<CareerRoadmap?> build() => null;

  Future<void> regenerate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final language = ref.read(localeProvider).languageCode;
      final roadmap = await ref.read(apiServiceProvider).generateCareerRoadmap(language: language);
      ref.invalidate(autoCareerRoadmapProvider);
      return roadmap;
    });
  }
}

final careerRoadmapRegenerateProvider =
    AsyncNotifierProvider<CareerRoadmapRegenerateController, CareerRoadmap?>(
  CareerRoadmapRegenerateController.new,
);

/// Toggling a single milestone's completed state (progress tracking).
class RoadmapProgressController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> toggleMilestone({
    required String roadmapId,
    required String milestoneId,
    required bool completed,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiServiceProvider).updateRoadmapProgress(
            roadmapId: roadmapId,
            milestoneId: milestoneId,
            completed: completed,
          );
      ref.invalidate(autoCareerRoadmapProvider);
    });
  }
}

final roadmapProgressControllerProvider =
    AsyncNotifierProvider<RoadmapProgressController, void>(RoadmapProgressController.new);
