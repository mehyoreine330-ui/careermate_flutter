import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/responsive.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/career_report_models.dart';
import '../providers/career_report_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/equal_height_card_row.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_progress_ring.dart';
import '../widgets/icon_glow_button.dart';
import '../widgets/shimmer_loading.dart';

/// AI Career Report: a personalized synthesis shown right after a resume
/// analysis (or reachable any time from the dashboard) — career readiness,
/// estimated hiring score, strengths/weaknesses, recommended paths,
/// certifications, courses, a week-by-week roadmap, and next steps. Reuses
/// the same glassmorphic design system as every other screen.
class CareerReportScreen extends ConsumerWidget {
  const CareerReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reportAsync = ref.watch(latestCareerReportProvider);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 18, vertical: 18),
            child: FadeSlideIn(
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
                      Text(l10n.careerReportTitle,
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: reportAsync.when(
                          data: (report) => report == null
                              ? const _NoReportYet()
                              : _ReportBody(
                                  report: report, isDesktop: isDesktop),
                          loading: () => _LoadingReport(isDesktop: isDesktop),
                          error: (error, _) => _ErrorState(
                            message: error is ApiException
                                ? error.message
                                : l10n.careerReportCouldNotLoad,
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
      ),
    );
  }
}

class _NoReportYet extends ConsumerWidget {
  const _NoReportYet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final generation = ref.watch(careerReportGenerationProvider);

    ref.listen(careerReportGenerationProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is ApiException
                  ? error.message
                  : l10n.careerReportCouldNotGenerate,
            ),
          ),
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: EmptyStateCard(
        icon: Icons.auto_awesome_rounded,
        title: l10n.careerReportNoneYetTitle,
        message: l10n.careerReportNoneYetBody,
        actionLabel: l10n.careerReportGenerate,
        isLoading: generation.isLoading,
        onAction: () =>
            ref.read(careerReportGenerationProvider.notifier).generate(),
      ),
    );
  }
}

/// Shimmer skeleton shaped like the real report — a score row plus a couple
/// of section cards — shown while the report is being fetched/generated so
/// the loading state occupies roughly the same layout as the eventual
/// content instead of a bare centered spinner.
class _LoadingReport extends StatelessWidget {
  const _LoadingReport({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EqualHeightCardRow(
            isDesktop: isDesktop,
            cards: const [
              ShimmerCard(lines: 1, titleWidth: 100),
              ShimmerCard(lines: 1, titleWidth: 100),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerCard(lines: 3, titleWidth: 140),
          const SizedBox(height: 16),
          const ShimmerCard(lines: 4, titleWidth: 160),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: EmptyStateCard(
        icon: Icons.error_outline_rounded,
        glowColor: AppColors.danger,
        message: message,
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.isDesktop});

  final CareerReport report;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScoreRow(report: report, isDesktop: isDesktop),
        const SizedBox(height: 16),
        EqualHeightCardRow(
          isDesktop: isDesktop,
          cards: [
            _ChecklistCard(
              icon: Icons.check_circle_outline_rounded,
              title: l10n.careerReportStrengths,
              items: report.strengths,
              itemIcon: Icons.check_circle,
              itemIconColor: AppColors.success,
              emptyText: l10n.resumeAnalyzerNoStrengths,
            ),
            _ChecklistCard(
              icon: Icons.trending_up_rounded,
              title: l10n.careerReportAreasToImprove,
              items: report.weaknesses,
              itemIcon: Icons.warning_amber_rounded,
              itemIconColor: AppColors.warning,
              emptyText: l10n.careerReportNoSkillGaps,
            ),
          ],
        ),
        const SizedBox(height: 16),
        EqualHeightCardRow(
          isDesktop: isDesktop,
          cards: [
            _BulletListCard(
              icon: Icons.alt_route_rounded,
              title: l10n.careerReportRecommendedPaths,
              items: report.recommendedCareerPaths,
            ),
            _BulletListCard(
              icon: Icons.workspace_premium_outlined,
              title: l10n.careerReportRecommendedCerts,
              items: report.recommendedCertifications,
            ),
            _BulletListCard(
              icon: Icons.menu_book_outlined,
              title: l10n.careerReportRecommendedCourses,
              items: report.recommendedCourses,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _RoadmapCard(roadmap: report.learningRoadmap),
        const SizedBox(height: 16),
        _BulletListCard(
          icon: Icons.checklist_rounded,
          title: l10n.careerReportNextSteps,
          items: report.nextSteps,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.report, required this.isDesktop});

  final CareerReport report;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = [
      _ScoreCard(
        label: l10n.careerReportCareerReadiness,
        score: report.careerReadiness,
        description: l10n.careerReportReadinessDesc,
      ),
      _ScoreCard(
        label: l10n.careerReportHiringScore,
        score: report.estimatedHiringScore,
        description: l10n.careerReportHiringScoreDesc,
      ),
    ];
    return EqualHeightCardRow(isDesktop: isDesktop, cards: cards);
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard(
      {required this.label, required this.score, required this.description});

  final String label;
  final int score;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GradientProgressRing(
                  progress: score / 100, size: 84, strokeWidth: 8),
              Text(
                '$score%',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
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

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.itemIcon,
    required this.itemIconColor,
    required this.emptyText,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final IconData itemIcon;
  final Color itemIconColor;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: icon,
      title: title,
      child: items.isEmpty
          ? Text(emptyText,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(itemIcon, size: 15, color: itemIconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
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

class _BulletListCard extends StatelessWidget {
  const _BulletListCard(
      {required this.icon, required this.title, required this.items});

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: icon,
      title: title,
      child: items.isEmpty
          ? Text(
              AppLocalizations.of(context).careerReportNothingToShow,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle,
                          size: 6, color: AppColors.accentCyan),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
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

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({required this.roadmap});

  final List<RoadmapWeek> roadmap;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.timeline_rounded,
      title: AppLocalizations.of(context).careerReportLearningRoadmap,
      child: roadmap.isEmpty
          ? Text(
              AppLocalizations.of(context).careerReportNoRoadmap,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < roadmap.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: i == roadmap.length - 1 ? 0 : 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.accentGradient,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                roadmap[i].week,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                roadmap[i].focus,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
