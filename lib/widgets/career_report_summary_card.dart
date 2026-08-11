import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/career_report_provider.dart';
import '../screens/career_report_screen.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

/// Dashboard-only summary of the user's latest AI Career Report. Renders
/// nothing at all if no report has been generated yet — additive to the
/// dashboard, never a required section — per the product requirement to
/// leave the rest of the dashboard exactly as it was.
class CareerReportSummaryCard extends ConsumerWidget {
  const CareerReportSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reportAsync = ref.watch(latestCareerReportProvider);

    return reportAsync.when(
      data: (report) {
        if (report == null) return const SizedBox.shrink();

        final topRecommendation = report.recommendedCareerPaths.isNotEmpty
            ? report.recommendedCareerPaths.first
            : (report.recommendedCourses.isNotEmpty ? report.recommendedCourses.first : null);
        final todaysMission = report.nextSteps.isNotEmpty
            ? report.nextSteps.first
            : (report.learningRoadmap.isNotEmpty ? report.learningRoadmap.first.focus : null);
        final roadmapProgress = report.learningRoadmap.isNotEmpty
            ? '${report.learningRoadmap.first.week}: ${report.learningRoadmap.first.focus}'
            : null;

        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CareerReportScreen()),
            ),
            child: GlassCard(
              glowColor: AppColors.accentCyan,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accentCyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.resumeAnalyzerAiCareerReport,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBlock(label: l10n.dashboardCareerReadiness, value: '${report.careerReadiness}%'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBlock(label: l10n.dashboardHiringScore, value: '${report.estimatedHiringScore}%'),
                      ),
                    ],
                  ),
                  if (todaysMission != null) ...[
                    const SizedBox(height: 14),
                    _InfoLine(label: l10n.dashboardTodaysMission, value: todaysMission),
                  ],
                  if (topRecommendation != null) ...[
                    const SizedBox(height: 10),
                    _InfoLine(label: l10n.dashboardTopRecommendation, value: topRecommendation),
                  ],
                  if (roadmapProgress != null) ...[
                    const SizedBox(height: 10),
                    _InfoLine(label: l10n.dashboardLatestRoadmapProgress, value: roadmapProgress),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
        ),
      ],
    );
  }
}
