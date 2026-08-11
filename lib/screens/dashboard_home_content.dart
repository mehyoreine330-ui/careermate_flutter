import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/responsive.dart';
import '../core/time_ago.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/career_report_models.dart';
import '../models/resume_models.dart';
import '../providers/career_report_provider.dart';
import '../providers/resume_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_progress_ring.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/responsive_card_grid.dart';
import '../widgets/shimmer_loading.dart';
import 'career_report_screen.dart';
import 'resume_analyzer_screen.dart';

/// The Dashboard's content — CareerMate's main home page inside AppShellScreen.
/// Pulls real, persisted data from the latest analyzed resume and latest
/// career report (no client-side placeholders); degrades gracefully with the
/// specified empty-state copy when either is missing.
///
/// [onNavigate] switches the shell's content-swap tab (used by the Quick
/// Actions that point at other shell pages rather than a pushed screen).
class DashboardHomeContent extends ConsumerWidget {
  const DashboardHomeContent({super.key, required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final resumeAsync = ref.watch(latestResumeSummaryProvider);
    final reportAsync = ref.watch(latestCareerReportProvider);
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dashboardTitle,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              l10n.dashboardSubtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13.5),
            ),
            const SizedBox(height: 24),
            resumeAsync.when(
              data: (resume) => reportAsync.when(
                data: (report) => _DashboardBody(
                    resume: resume, report: report, isDesktop: isDesktop),
                loading: () => const _LoadingBlock(),
                error: (_, __) => _DashboardBody(
                    resume: resume, report: null, isDesktop: isDesktop),
              ),
              loading: () => const _LoadingBlock(),
              error: (_, __) => _DashboardBody(
                  resume: null, report: null, isDesktop: isDesktop),
            ),
            const SizedBox(height: 32),
            Text(l10n.dashboardQuickActions,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _QuickActionsRow(onNavigate: onNavigate),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return ResponsiveCardGrid(
      columnsForWidth: (w) => w >= 900 ? 4 : (w >= 560 ? 2 : 1),
      cards: const [
        ShimmerCard(lines: 1, titleWidth: 60),
        ShimmerCard(lines: 1, titleWidth: 60),
        ShimmerCard(lines: 1, titleWidth: 60),
        ShimmerCard(lines: 2, titleWidth: 100),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody(
      {required this.resume, required this.report, required this.isDesktop});

  final ResumeSummary? resume;
  final CareerReport? report;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (resume == null) {
      return EmptyStateCard(
        icon: Icons.upload_file_rounded,
        message: l10n.dashboardUploadResumeCta,
        actionLabel: l10n.dashboardAnalyzeResume,
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ResumeAnalyzerScreen()),
        ),
      );
    }

    final topRecommendation =
        report != null && report!.recommendedCareerPaths.isNotEmpty
            ? report!.recommendedCareerPaths.first
            : (report != null && report!.recommendedCourses.isNotEmpty
                ? report!.recommendedCourses.first
                : null);
    final todaysMission = report != null && report!.nextSteps.isNotEmpty
        ? report!.nextSteps.first
        : (report != null && report!.learningRoadmap.isNotEmpty
            ? report!.learningRoadmap.first.focus
            : null);
    final roadmapProgress = report != null && report!.learningRoadmap.isNotEmpty
        ? '${report!.learningRoadmap.first.week}: ${report!.learningRoadmap.first.focus}'
        : null;

    final cards = <Widget>[
      _ScoreStatCard(
        label: l10n.dashboardCareerReadiness,
        score: report?.careerReadiness,
      ),
      _ScoreStatCard(
        label: l10n.dashboardHiringScore,
        score: report?.estimatedHiringScore,
      ),
      _ScoreStatCard(
        label: l10n.dashboardLatestAtsScore,
        score: resume!.atsScore,
      ),
      _InfoCard(
        icon: Icons.auto_awesome_rounded,
        title: l10n.dashboardLatestCareerReport,
        body: report != null
            ? l10n.dashboardReportFor(report!.targetRole.isEmpty
                ? l10n.dashboardGeneralRole
                : report!.targetRole)
            : null,
        emptyText: l10n.dashboardNoCareerReport,
        onTap: report != null
            ? () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CareerReportScreen()))
            : null,
        ctaLabel: report == null
            ? l10n.dashboardGenerateReport
            : l10n.dashboardViewFullReport,
      ),
      _InfoCard(
        icon: Icons.flag_rounded,
        title: l10n.dashboardTodaysMission,
        body: todaysMission,
        emptyText: l10n.dashboardNoCareerReport,
      ),
      _InfoCard(
        icon: Icons.lightbulb_outline_rounded,
        title: l10n.dashboardTopRecommendation,
        body: topRecommendation,
        emptyText: l10n.dashboardNoCareerReport,
      ),
      _InfoCard(
        icon: Icons.timeline_rounded,
        title: l10n.dashboardLatestRoadmapProgress,
        body: roadmapProgress,
        emptyText: l10n.dashboardNoCareerReport,
      ),
      _RecentActivityCard(resume: resume, report: report),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (report == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EmptyStateCard(
              icon: Icons.auto_awesome_rounded,
              message: l10n.dashboardNoCareerReport,
              actionLabel: l10n.dashboardGenerateCareerReport,
              onAction: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const CareerReportScreen())),
            ),
          ),
        ResponsiveCardGrid(
          cards: cards,
          columnsForWidth: (w) => w >= 900 ? 4 : (w >= 560 ? 2 : 1),
        ),
      ],
    );
  }
}

class _ScoreStatCard extends StatelessWidget {
  const _ScoreStatCard({required this.label, required this.score});

  final String label;
  final int? score;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GradientProgressRing(
                  progress: (score ?? 0) / 100, size: 60, strokeWidth: 6),
              Text(
                score == null ? '--' : '$score',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.emptyText,
    this.onTap,
    this.ctaLabel,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String emptyText;
  final VoidCallback? onTap;
  final String? ctaLabel;

  @override
  Widget build(BuildContext context) {
    final card = GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.accentCyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body ?? emptyText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: body == null ? AppColors.textMuted : Colors.white,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );

    return onTap == null ? card : GestureDetector(onTap: onTap, child: card);
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.resume, required this.report});

  final ResumeSummary? resume;
  final CareerReport? report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <MapEntry<DateTime, String>>[
      if (resume != null)
        MapEntry(
            resume!.createdAt, l10n.dashboardAnalyzedResume(resume!.title)),
      if (report != null)
        MapEntry(report!.createdAt, l10n.dashboardGeneratedReport),
    ]..sort((a, b) => b.key.compareTo(a.key));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded,
                  size: 16, color: AppColors.accentCyan),
              const SizedBox(width: 8),
              Text(
                l10n.dashboardRecentActivity,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Text(
              l10n.dashboardNoRecentActivity,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            )
          else
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  l10n.dashboardTimeAgoLine(e.value, timeAgo(l10n, e.key)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final actions = [
          QuickActionCard(
            icon: Icons.description_outlined,
            label: l10n.dashboardQaAnalyzeResumeLabel,
            subtitle: l10n.dashboardQaAnalyzeResumeSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResumeAnalyzerScreen()),
            ),
          ),
          QuickActionCard(
            icon: Icons.auto_awesome_rounded,
            label: l10n.dashboardQaViewReportLabel,
            subtitle: l10n.dashboardQaViewReportSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CareerReportScreen()),
            ),
          ),
          QuickActionCard(
            icon: Icons.school_outlined,
            label: l10n.dashboardQaFindInternshipsLabel,
            subtitle: l10n.dashboardQaFindInternshipsSubtitle,
            onTap: () => onNavigate('internships'),
          ),
          QuickActionCard(
            icon: Icons.support_agent_rounded,
            label: l10n.dashboardQaTalkToCoachLabel,
            subtitle: l10n.dashboardQaTalkToCoachSubtitle,
            onTap: () => onNavigate('ai_career_coach'),
          ),
          QuickActionCard(
            icon: Icons.person_outline_rounded,
            label: l10n.dashboardQaUpdateProfileLabel,
            subtitle: l10n.dashboardQaUpdateProfileSubtitle,
            onTap: () => onNavigate('profile'),
          ),
        ];

        final columns = constraints.maxWidth >= 900
            ? 3
            : (constraints.maxWidth >= 480 ? 2 : 1);
        const spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final action in actions)
              SizedBox(width: itemWidth, child: action),
          ],
        );
      },
    );
  }
}
