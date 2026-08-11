import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resume_models.dart';
import '../services/api_service.dart';
import 'locale_provider.dart';

/// Single shared ApiService instance for the whole app. Disposed
/// automatically when the provider container is torn down (e.g. hot
/// restart in dev, or app shutdown).
final apiServiceProvider = Provider<ApiService>((ref) {
  final service = ApiService();
  ref.onDispose(service.dispose);
  return service;
});

/// Bundles the uploaded file + target role alongside the analysis result so
/// a later "Auto-Fix with AI" call can resend the exact same PDF without
/// asking the user to re-upload it.
class ResumeAnalysisState {
  const ResumeAnalysisState({
    required this.file,
    required this.targetRole,
    required this.result,
  });

  final PlatformFile file;
  final String targetRole;
  final ResumeAnalysisResult result;
}

/// Holds the most recent resume analysis (plus the file/role it came from).
/// `null` means "nothing analyzed yet" — screens (dashboard, resume
/// analyzer) branch on that to show empty-state UI instead of a fake score.
class ResumeAnalysisController extends AsyncNotifier<ResumeAnalysisState?> {
  @override
  FutureOr<ResumeAnalysisState?> build() => null;

  Future<void> analyze({required PlatformFile file, required String targetRole}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final language = ref.read(localeProvider).languageCode;
      final result = await ref
          .read(apiServiceProvider)
          .analyzeResume(file: file, targetRole: targetRole, language: language);
      return ResumeAnalysisState(file: file, targetRole: targetRole, result: result);
    });
  }

  void reset() => state = const AsyncData(null);
}

final resumeAnalysisProvider =
    AsyncNotifierProvider<ResumeAnalysisController, ResumeAnalysisState?>(
  ResumeAnalysisController.new,
);

/// "Auto-Fix with AI". Kept as its own AsyncNotifier (rather than folded
/// into ResumeAnalysisController) so its loading/error state doesn't
/// clobber the original analysis already shown on screen.
class AutoFixController extends AsyncNotifier<AutoFixResult?> {
  @override
  FutureOr<AutoFixResult?> build() => null;

  Future<void> autoFix() async {
    final analysisState = ref.read(resumeAnalysisProvider).valueOrNull;
    if (analysisState == null) {
      state = AsyncError(
        StateError('Analyze a resume before using Auto-Fix.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    final language = ref.read(localeProvider).languageCode;
    state = await AsyncValue.guard(
      () => ref.read(apiServiceProvider).autoFixResume(
            file: analysisState.file,
            targetRole: analysisState.targetRole,
            priorAnalysis: analysisState.result,
            language: language,
          ),
    );
  }

  void reset() => state = const AsyncData(null);
}

final autoFixProvider = AsyncNotifierProvider<AutoFixController, AutoFixResult?>(
  AutoFixController.new,
);

/// Lightweight summary of the user's most recently analyzed resume — drives
/// the Dashboard's "Latest Resume ATS Score" card and the "resume uploaded"
/// empty-state check, independent of whether a Career Report exists yet.
final latestResumeSummaryProvider = FutureProvider.autoDispose<ResumeSummary?>((ref) {
  return ref.watch(apiServiceProvider).getLatestResumeSummary();
});
