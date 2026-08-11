import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/responsive.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/career_roadmap_models.dart';
import '../providers/career_roadmap_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/equal_height_card_row.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/icon_glow_button.dart';
import '../widgets/shimmer_loading.dart';

/// AI Career Roadmap: an ongoing, profession-agnostic development plan
/// generated automatically the first time this screen is opened after at
/// least one resume has been analyzed — current career level, missing
/// skills, a phased learning plan, certifications, learning resources,
/// projects/practical experience, an estimated timeline, and a milestone
/// checklist the candidate tracks progress against. Regenerates
/// automatically whenever a newer resume analysis exists; a manual
/// "Regenerate" action is also available on demand.
class CareerRoadmapScreen extends ConsumerWidget {
  const CareerRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final roadmapAsync = ref.watch(autoCareerRoadmapProvider);
    final regeneration = ref.watch(careerRoadmapRegenerateProvider);
    final isDesktop = Responsive.isDesktop(context);

    ref.listen(careerRoadmapRegenerateProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is ApiException
                  ? error.message
                  : l10n.careerRoadmapCouldNotRegenerate,
            ),
          ),
        ),
        data: (roadmap) {
          if (roadmap != null) ref.invalidate(autoCareerRoadmapProvider);
        },
      );
    });

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
                      Expanded(
                        child: Text(l10n.careerRoadmapTitle,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      roadmapAsync.maybeWhen(
                        data: (roadmap) => roadmap == null
                            ? const SizedBox.shrink()
                            : GlowButton(
                                label: l10n.careerRoadmapRegenerate,
                                icon: Icons.refresh_rounded,
                                expand: false,
                                isLoading: regeneration.isLoading,
                                onPressed: regeneration.isLoading
                                    ? null
                                    : () => ref
                                        .read(careerRoadmapRegenerateProvider
                                            .notifier)
                                        .regenerate(),
                              ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: roadmapAsync.when(
                          data: (roadmap) => roadmap == null
                              ? const _NoResumeYet()
                              : _RoadmapBody(
                                  roadmap: roadmap, isDesktop: isDesktop),
                          loading: () => const _LoadingRoadmap(),
                          error: (error, _) => _ErrorState(
                            message: error is ApiException
                                ? error.message
                                : l10n.careerRoadmapCouldNotLoad,
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

class _NoResumeYet extends StatelessWidget {
  const _NoResumeYet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: EmptyStateCard(
        icon: Icons.route_rounded,
        title: l10n.careerRoadmapNoneYetTitle,
        message: l10n.careerRoadmapNoneYetBody,
      ),
    );
  }
}

/// Shimmer skeleton shaped like the real roadmap — a summary card, a
/// progress card, and a couple of list sections — instead of a bare
/// centered spinner while the roadmap is generated.
class _LoadingRoadmap extends StatelessWidget {
  const _LoadingRoadmap();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(lines: 2, titleWidth: 160),
          SizedBox(height: 16),
          ShimmerCard(lines: 3, titleWidth: 120),
          SizedBox(height: 16),
          ShimmerCard(lines: 4, titleWidth: 140),
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

class _RoadmapBody extends ConsumerWidget {
  const _RoadmapBody({required this.roadmap, required this.isDesktop});

  final CareerRoadmap roadmap;
  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(roadmap: roadmap),
        const SizedBox(height: 16),
        _ProgressCard(roadmap: roadmap),
        const SizedBox(height: 16),
        _BulletListCard(
          icon: Icons.trending_up_rounded,
          title: l10n.careerRoadmapMissingSkills,
          items: roadmap.missingSkills,
          emptyText: l10n.careerRoadmapNoMissingSkills,
        ),
        const SizedBox(height: 16),
        _LearningPlanCard(steps: roadmap.learningPlan),
        const SizedBox(height: 16),
        EqualHeightCardRow(
          isDesktop: isDesktop,
          cards: [
            _BulletListCard(
              icon: Icons.workspace_premium_outlined,
              title: l10n.careerRoadmapRecommendedCerts,
              items: roadmap.recommendedCertifications,
              emptyText: l10n.careerRoadmapNoCerts,
            ),
            _BulletListCard(
              icon: Icons.menu_book_outlined,
              title: l10n.careerRoadmapRecommendedResources,
              items: roadmap.recommendedResources,
              emptyText: l10n.careerRoadmapNoResources,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _BulletListCard(
          icon: Icons.construction_rounded,
          title: l10n.careerRoadmapProjects,
          items: roadmap.recommendedProjects,
          emptyText: l10n.careerRoadmapNoProjects,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.roadmap});

  final CareerRoadmap roadmap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.careerRoadmapCurrentLevel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            roadmap.currentCareerLevel.isEmpty
                ? l10n.careerRoadmapNotAvailable
                : roadmap.currentCareerLevel,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 16, color: AppColors.accentCyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  roadmap.estimatedTimeline.isEmpty
                      ? l10n.careerRoadmapTimelineNotAvailable
                      : l10n.careerRoadmapEstimatedTimeline(
                          roadmap.estimatedTimeline),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13.5, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends ConsumerWidget {
  const _ProgressCard({required this.roadmap});

  final CareerRoadmap roadmap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progressState = ref.watch(roadmapProgressControllerProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded,
                  size: 18, color: AppColors.accentCyan),
              const SizedBox(width: 10),
              Text(
                l10n.careerRoadmapProgress,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${roadmap.completedMilestoneCount}/${roadmap.milestones.length}',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: roadmap.progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.accentCyan),
            ),
          ),
          const SizedBox(height: 16),
          if (roadmap.milestones.isEmpty)
            Text(
              l10n.careerRoadmapNoMilestones,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            for (final milestone in roadmap.milestones)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: progressState.isLoading
                      ? null
                      : () => ref
                          .read(roadmapProgressControllerProvider.notifier)
                          .toggleMilestone(
                            roadmapId: roadmap.id,
                            milestoneId: milestone.id,
                            completed: !milestone.completed,
                          ),
                  child: Row(
                    children: [
                      Icon(
                        milestone.completed
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: milestone.completed
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          milestone.title,
                          style: TextStyle(
                            color: milestone.completed
                                ? AppColors.textSecondary
                                : Colors.white,
                            fontSize: 13.5,
                            decoration: milestone.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _LearningPlanCard extends StatelessWidget {
  const _LearningPlanCard({required this.steps});

  final List<RoadmapLearningStep> steps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined,
                  size: 18, color: AppColors.accentCyan),
              const SizedBox(width: 10),
              Text(
                l10n.careerRoadmapLearningPlan,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (steps.isEmpty)
            Text(
              l10n.careerRoadmapNoLearningPlan,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            for (final step in steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentIndigo.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step.phase,
                        style: const TextStyle(
                          color: AppColors.accentCyan,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.focus,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13.5, height: 1.4),
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

class _BulletListCard extends StatelessWidget {
  const _BulletListCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.emptyText,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accentCyan),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(emptyText,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13))
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.circle,
                          size: 6, color: AppColors.accentCyan),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              height: 1.4)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
