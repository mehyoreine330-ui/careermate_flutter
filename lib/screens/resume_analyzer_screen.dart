import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/responsive.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/resume_models.dart';
import '../providers/career_report_provider.dart';
import '../providers/job_matching_provider.dart';
import '../providers/opportunity_provider.dart';
import '../providers/resume_provider.dart';
import 'career_report_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/gradient_progress_ring.dart';
import '../widgets/equal_height_card_row.dart';
import '../widgets/icon_glow_button.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/sleek_text_field.dart';

/// ATS Resume Analyzer & Readiness Score screen: upload a PDF, see an
/// animated "Career Readiness Score" gauge plus ATS Compatibility / Missing
/// Keywords / Formatting Check breakdown cards, then optionally run
/// "Auto-Fix with AI" to get a rewritten, optimized resume.
class ResumeAnalyzerScreen extends ConsumerStatefulWidget {
  const ResumeAnalyzerScreen({super.key});

  @override
  ConsumerState<ResumeAnalyzerScreen> createState() =>
      _ResumeAnalyzerScreenState();
}

class _ResumeAnalyzerScreenState extends ConsumerState<ResumeAnalyzerScreen> {
  final _targetRoleController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _targetRoleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    // `withData: true` is required on Flutter Web — the browser never
    // exposes a real filesystem `path` (it's always null there), only the
    // file's bytes. Requesting bytes on every platform keeps picking and
    // the later upload identical regardless of where the app is running.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    final file = result?.files.single;
    if (file != null && file.bytes != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _analyze() async {
    final l10n = AppLocalizations.of(context);
    final file = _selectedFile;
    final targetRole = _targetRoleController.text.trim();
    if (file == null || targetRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resumeAnalyzerMissingInput)),
      );
      return;
    }
    ref.read(autoFixProvider.notifier).reset();
    await ref
        .read(resumeAnalysisProvider.notifier)
        .analyze(file: file, targetRole: targetRole);

    // Kick off the AI Career Report right after a successful analysis, per
    // the product requirement — fire-and-forget so a slow/failed report
    // generation can never block or break the resume analysis flow above.
    if (ref.read(resumeAnalysisProvider).valueOrNull != null) {
      unawaited(ref.read(careerReportGenerationProvider.notifier).generate());
      // Job Matching / Internships cache their AI scoring for the session
      // (see job_matching_provider.dart) — a new resume changes the
      // candidate context those scores are based on, so invalidate them
      // here rather than on every tab visit.
      ref.invalidate(jobRecommendationsProvider);
      ref.invalidate(opportunityRecommendationsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analysisState = ref.watch(resumeAnalysisProvider);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconGlowButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: l10n.commonBack,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    Text(l10n.resumeAnalyzerTitle,
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: FadeSlideIn(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _UploadCard(
                              targetRoleController: _targetRoleController,
                              selectedFile: _selectedFile,
                              isLoading: analysisState.isLoading,
                              onPickFile: _pickFile,
                              onAnalyze: _analyze,
                            ),
                            const SizedBox(height: 24),
                            analysisState.when(
                              data: (state) => state == null
                                  ? const SizedBox.shrink()
                                  : _ResultSection(
                                      state: state, isDesktop: isDesktop),
                              loading: () => const _LoadingCard(),
                              error: (error, _) => _ErrorCard(
                                message: error is ApiException
                                    ? error.message
                                    : l10n.resumeAnalyzerCouldNotAnalyze,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.targetRoleController,
    required this.selectedFile,
    required this.isLoading,
    required this.onPickFile,
    required this.onAnalyze,
  });

  final TextEditingController targetRoleController;
  final PlatformFile? selectedFile;
  final bool isLoading;
  final VoidCallback onPickFile;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.resumeAnalyzerUploadTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.resumeAnalyzerUploadSubtitle,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SleekTextField(
            controller: targetRoleController,
            label: l10n.resumeAnalyzerTargetRole,
            hint: l10n.resumeAnalyzerTargetRoleHint,
            prefixIcon: Icons.flag_outlined,
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(
                  color: selectedFile != null
                      ? AppColors.accentCyan.withValues(alpha: 0.5)
                      : Colors.white24,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedFile != null
                        ? Icons.picture_as_pdf_rounded
                        : Icons.upload_file_rounded,
                    color: selectedFile != null
                        ? AppColors.accentCyan
                        : Colors.white54,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedFile == null
                          ? l10n.resumeAnalyzerChoosePdf
                          : selectedFile!.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    selectedFile == null
                        ? l10n.resumeAnalyzerBrowse
                        : l10n.resumeAnalyzerChange,
                    style: const TextStyle(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          GlowButton(
            label: l10n.resumeAnalyzerAnalyzeButton,
            icon: Icons.auto_awesome_rounded,
            isLoading: isLoading,
            onPressed: isLoading ? null : onAnalyze,
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton shaped like the real result section — a readiness gauge
/// card plus a couple of breakdown cards — shown while the resume is being
/// analyzed instead of a bare centered spinner.
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerCard(lines: 2, titleWidth: 160),
        SizedBox(height: 16),
        ShimmerCard(lines: 3, titleWidth: 140),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      icon: Icons.error_outline_rounded,
      glowColor: AppColors.danger,
      message: message,
    );
  }
}

class _ResultSection extends ConsumerWidget {
  const _ResultSection({required this.state, required this.isDesktop});

  final ResumeAnalysisState state;
  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final result = state.result;
    final readiness = ((result.atsAnalysis.overallAtsScore +
                result.skillGapAnalysis.readinessScore) /
            2)
        .round();

    final breakdownCards = [
      _AtsCompatibilityCard(ats: result.atsAnalysis),
      _MissingKeywordsCard(keywords: result.atsAnalysis.missingKeywords),
      _FormattingCheckCard(issues: result.atsAnalysis.formattingIssues),
    ];
    final strengthsCards = [
      _StrengthsCard(strengths: result.atsAnalysis.strengths),
      _WeakBulletPointsCard(bulletPoints: result.atsAnalysis.weakBulletPoints),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReadinessGaugeCard(
            score: readiness, nextAction: result.recommendedNextAction),
        const SizedBox(height: 20),
        EqualHeightCardRow(cards: breakdownCards, isDesktop: isDesktop),
        const SizedBox(height: 16),
        EqualHeightCardRow(cards: strengthsCards, isDesktop: isDesktop),
        const SizedBox(height: 8),
        GlowButton(
          label: l10n.resumeAnalyzerAutoFix,
          icon: Icons.auto_fix_high_rounded,
          isLoading: ref.watch(autoFixProvider).isLoading,
          onPressed: () => ref.read(autoFixProvider.notifier).autoFix(),
        ),
        const SizedBox(height: 20),
        ref.watch(autoFixProvider).when(
              data: (fixResult) => fixResult == null
                  ? const SizedBox.shrink()
                  : _AutoFixResultCard(result: fixResult),
              loading: () => const _LoadingCard(),
              error: (error, _) => _ErrorCard(
                message: error is ApiException
                    ? error.message
                    : l10n.resumeAnalyzerAutoFixFailed,
              ),
            ),
        const SizedBox(height: 16),
        const _CareerReportPromptCard(),
      ],
    );
  }
}

class _ReadinessGaugeCard extends StatelessWidget {
  const _ReadinessGaugeCard({required this.score, required this.nextAction});

  final int score;
  final String nextAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      padding: const EdgeInsets.all(28),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GradientProgressRing(
                  progress: score / 100, size: 120, strokeWidth: 11),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  const Text('/ 100',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.resumeAnalyzerReadinessScore,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(nextAction,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard(
      {required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accentCyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AtsCompatibilityCard extends StatelessWidget {
  const _AtsCompatibilityCard({required this.ats});
  final ATSAnalysis ats;

  @override
  Widget build(BuildContext context) {
    return _BreakdownCard(
      icon: Icons.fact_check_outlined,
      title: AppLocalizations.of(context).resumeAnalyzerAtsCompatibility,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ats.overallAtsScore}/100',
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final entry in ats.scoreBreakdown.entries) ...[
            _MiniScoreBar(label: _prettifyKey(entry.key), value: entry.value),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  String _prettifyKey(String key) {
    final withSpaces = key.replaceAll('_', ' ');
    if (withSpaces.isEmpty) return withSpaces;
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }
}

class _MiniScoreBar extends StatelessWidget {
  const _MiniScoreBar({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11.5),
              ),
            ),
            const SizedBox(width: 8),
            Text('$value',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0, 1),
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation(AppColors.accentCyan),
          ),
        ),
      ],
    );
  }
}

class _MissingKeywordsCard extends StatelessWidget {
  const _MissingKeywordsCard({required this.keywords});
  final List<MissingKeyword> keywords;

  Color _importanceColor(String importance) {
    switch (importance) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BreakdownCard(
      icon: Icons.key_outlined,
      title: AppLocalizations.of(context).resumeAnalyzerMissingKeywords,
      child: keywords.isEmpty
          ? Text(
              AppLocalizations.of(context).resumeAnalyzerNoMissingKeywords,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords.map((k) {
                final color = _importanceColor(k.importance);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: color.withValues(alpha: 0.12),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    k.keyword,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _FormattingCheckCard extends StatelessWidget {
  const _FormattingCheckCard({required this.issues});
  final List<FormattingIssue> issues;

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BreakdownCard(
      icon: Icons.rule_rounded,
      title: AppLocalizations.of(context).resumeAnalyzerFormattingCheck,
      child: issues.isEmpty
          ? Text(
              AppLocalizations.of(context).resumeAnalyzerNoFormattingIssues,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: issues.map((issue) {
                final color = _severityColor(issue.severity);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 8, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          issue.issue,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              height: 1.35),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _StrengthsCard extends StatelessWidget {
  const _StrengthsCard({required this.strengths});
  final List<String> strengths;

  @override
  Widget build(BuildContext context) {
    return _BreakdownCard(
      icon: Icons.thumb_up_alt_outlined,
      title: AppLocalizations.of(context).resumeAnalyzerStrengths,
      child: strengths.isEmpty
          ? Text(
              AppLocalizations.of(context).resumeAnalyzerNoStrengths,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: strengths.map((strength) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 15, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strength,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              height: 1.35),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _WeakBulletPointsCard extends StatelessWidget {
  const _WeakBulletPointsCard({required this.bulletPoints});
  final List<WeakBulletPoint> bulletPoints;

  @override
  Widget build(BuildContext context) {
    return _BreakdownCard(
      icon: Icons.edit_note_rounded,
      title: AppLocalizations.of(context).resumeAnalyzerWeakBulletPoints,
      child: bulletPoints.isEmpty
          ? Text(
              AppLocalizations.of(context).resumeAnalyzerNoWeakBulletPoints,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bulletPoints.map((bullet) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bullet.original,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bullet.suggestedRewrite,
                        style: const TextStyle(
                            color: AppColors.accentCyan,
                            fontSize: 12.5,
                            height: 1.35),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _AutoFixResultCard extends StatelessWidget {
  const _AutoFixResultCard({required this.result});
  final AutoFixResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high_rounded,
                  color: AppColors.accentCyan, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.resumeAnalyzerOptimizedResume,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppColors.accentGradient,
                ),
                child: Text(
                  l10n.resumeAnalyzerEstScore(result.estimatedNewAtsScore),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(result.summary,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
          if (result.changesMade.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.resumeAnalyzerWhatChanged,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(height: 8),
            ...result.changesMade.map(
              (change) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withValues(alpha: 0.03),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        change.section,
                        style: const TextStyle(
                            color: AppColors.accentCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(change.reason,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              height: 1.35)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.resumeAnalyzerFullOptimizedText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: result.optimizedResumeText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.resumeAnalyzerCopiedToClipboard)),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text(l10n.commonCopy),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 260),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.25),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SingleChildScrollView(
              child: Text(
                result.optimizedResumeText,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12.5, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Prompts the user into their AI Career Report, generated automatically in
/// the background right after analysis (see _ResumeAnalyzerScreenState._analyze).
/// Entirely non-blocking with respect to the resume analysis above it — a
/// slow or failed report generation only affects this card, never the ATS
/// results already on screen.
class _CareerReportPromptCard extends ConsumerWidget {
  const _CareerReportPromptCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final generation = ref.watch(careerReportGenerationProvider);

    return GlassCard(
      glowColor: AppColors.accentCyan,
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.accentCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.resumeAnalyzerAiCareerReport,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  generation.isLoading
                      ? l10n.resumeAnalyzerGeneratingReport
                      : generation.hasError
                          ? l10n.resumeAnalyzerCouldNotGenerateReport
                          : l10n.resumeAnalyzerReportTeaser,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GlowButton(
            label: generation.hasError
                ? l10n.commonRetry
                : l10n.resumeAnalyzerViewReport,
            expand: false,
            isLoading: generation.isLoading,
            onPressed: generation.isLoading
                ? null
                : () {
                    if (generation.hasError) {
                      ref
                          .read(careerReportGenerationProvider.notifier)
                          .generate();
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CareerReportScreen()),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
