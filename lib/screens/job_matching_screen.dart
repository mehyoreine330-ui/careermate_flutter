import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/job_matching_models.dart';
import '../providers/candidate_application_provider.dart';
import '../providers/job_matching_provider.dart';
import '../providers/saved_jobs_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/employer_apply_button.dart';
import '../widgets/gradient_progress_ring.dart';
import '../widgets/icon_glow_button.dart';
import '../widgets/insight_bullets.dart';
import '../widgets/insight_section.dart';
import '../widgets/pill_tag.dart';
import '../widgets/responsive_card_grid.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/toggle_filter_chip.dart';

/// Below this match score, a job isn't worth showing as a "recommendation" —
/// drives the "no suitable jobs yet" empty state independent of filters.
const int _kLowMatchThreshold = 35;

/// Job Matching — AI-scored recommendations from the sample job repository
/// (services/job_repository.py on the backend; swappable for a real job-board
/// API later without any UI changes). Rendered inside AppShellScreen's
/// content-swap area, same as Dashboard/Profile/Settings.
class JobMatchingContent extends ConsumerWidget {
  const JobMatchingContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final baseAsync = ref.watch(jobRecommendationsProvider);

    return SingleChildScrollView(
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGradient),
                  child: const Icon(Icons.work_outline_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Text(l10n.jobMatchingTitle,
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Text(
                l10n.jobMatchingSubtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            baseAsync.when(
              data: (baseRecommendations) {
                final hasSuitableJobs = baseRecommendations
                    .any((r) => r.analysis.matchScore >= _kLowMatchThreshold);

                if (baseRecommendations.isEmpty || !hasSuitableJobs) {
                  return const _NoSuitableJobsState();
                }

                return Consumer(
                  builder: (context, ref, _) {
                    final filtered = ref
                            .watch(filteredJobRecommendationsProvider)
                            .valueOrNull ??
                        const [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FilterBar(),
                        const SizedBox(height: 18),
                        if (filtered.isEmpty)
                          const _NoFilterMatchState()
                        else
                          ResponsiveCardGrid(
                            cards: [
                              for (final rec in filtered)
                                _JobCard(recommendation: rec)
                            ],
                            columnsForWidth: (w) => w >= 900 ? 2 : 1,
                          ),
                      ],
                    );
                  },
                );
              },
              loading: () => const _JobListSkeleton(),
              error: (error, _) => EmptyStateCard(
                icon: Icons.error_outline_rounded,
                glowColor: AppColors.danger,
                message: error is ApiException
                    ? error.message
                    : l10n.jobMatchingCouldNotLoad,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// A couple of job-card-shaped shimmer placeholders shown while
/// recommendations are being scored, instead of a bare centered spinner.
class _JobListSkeleton extends StatelessWidget {
  const _JobListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ResponsiveCardGrid(
      columnsForWidth: _columns,
      cards: [
        ShimmerCard(lines: 3, titleWidth: 180),
        ShimmerCard(lines: 3, titleWidth: 180),
      ],
    );
  }

  static int _columns(double w) => w >= 900 ? 2 : 1;
}

class _NoSuitableJobsState extends StatelessWidget {
  const _NoSuitableJobsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateCard(
      icon: Icons.work_off_outlined,
      title: l10n.jobMatchingNoMatchesTitle,
      message: l10n.jobMatchingNoMatchesBody,
    );
  }
}

class _NoFilterMatchState extends ConsumerWidget {
  const _NoFilterMatchState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateCard(
      icon: Icons.filter_alt_off_outlined,
      title: l10n.jobMatchingNoFilterMatchTitle,
      message: l10n.internshipsNoFilterMatchBody,
      actionLabel: l10n.commonClearFilters,
      onAction: () => ref.read(jobFilterProvider.notifier).clear(),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filters = ref.watch(jobFilterProvider);
    final countries = ref.watch(availableJobCountriesProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.filtersTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5),
              ),
              const Spacer(),
              if (filters.hasActiveFilters)
                GestureDetector(
                  onTap: () => ref.read(jobFilterProvider.notifier).clear(),
                  child: Text(
                    l10n.commonClearAll,
                    style: const TextStyle(
                        color: AppColors.accentCyan,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _CountryDropdown(countries: countries, value: filters.country),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ToggleFilterChip(
                label: l10n.filtersRemote,
                selected: filters.remote,
                onTap: () =>
                    ref.read(jobFilterProvider.notifier).toggleRemote(),
              ),
              ToggleFilterChip(
                label: l10n.filtersHybrid,
                selected: filters.hybrid,
                onTap: () =>
                    ref.read(jobFilterProvider.notifier).toggleHybrid(),
              ),
              ToggleFilterChip(
                label: l10n.filtersOnsite,
                selected: filters.onsite,
                onTap: () =>
                    ref.read(jobFilterProvider.notifier).toggleOnsite(),
              ),
              ToggleFilterChip(
                label: l10n.filtersInternship,
                selected: filters.internship,
                onTap: () =>
                    ref.read(jobFilterProvider.notifier).toggleInternship(),
              ),
              ToggleFilterChip(
                label: l10n.filtersFullTime,
                selected: filters.fullTime,
                onTap: () =>
                    ref.read(jobFilterProvider.notifier).toggleFullTime(),
              ),
              ToggleFilterChip(
                label: l10n.filtersPartTime,
                selected: filters.partTime,
                onTap: () =>
                    ref.read(jobFilterProvider.notifier).togglePartTime(),
              ),
              ToggleFilterChip(
                label: l10n.filtersEntryLevel,
                selected: filters.entryLevel,
                onTap: () =>
                    ref.read(jobFilterProvider.notifier).toggleEntryLevel(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryDropdown extends ConsumerWidget {
  const _CountryDropdown({required this.countries, required this.value});

  final List<String> countries;
  final String? value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          hint: Text(l10n.filtersAllCountries,
              style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.textSecondary),
          items: [
            DropdownMenuItem<String?>(
                value: null, child: Text(l10n.filtersAllCountries)),
            for (final country in countries)
              DropdownMenuItem<String?>(value: country, child: Text(country)),
          ],
          onChanged: (country) =>
              ref.read(jobFilterProvider.notifier).setCountry(country),
        ),
      ),
    );
  }
}

String _titleCase(String snakeCase) {
  return snakeCase
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join('-');
}

class _JobCard extends ConsumerStatefulWidget {
  const _JobCard({required this.recommendation});

  final JobRecommendation recommendation;

  @override
  ConsumerState<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends ConsumerState<_JobCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final job = widget.recommendation.job;
    final analysis = widget.recommendation.analysis;
    final employerJobId = employerJobIdFromPostingId(job.id);

    return GlassCard(
      glowColor: analysis.matchScore >= 70
          ? AppColors.success
          : AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  GradientProgressRing(
                      progress: analysis.matchScore / 100,
                      size: 56,
                      strokeWidth: 5),
                  Text(
                    '${analysis.matchScore}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.company,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${job.location}, ${job.country}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _SaveJobButton(job: job, matchScore: analysis.matchScore),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (employerJobId != null)
                PillTag(
                    label: l10n.jobMatchingCareerMateEmployer, accent: true),
              PillTag(label: _titleCase(job.employmentType)),
              PillTag(label: _titleCase(job.workArrangement)),
              PillTag(label: _titleCase(job.experienceLevel)),
            ],
          ),
          if (job.salaryRange != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.payments_outlined,
                    size: 14, color: AppColors.accentCyan),
                const SizedBox(width: 6),
                Text(job.salaryRange!,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 12.5)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Text(
                  _expanded
                      ? l10n.jobMatchingHideInsights
                      : l10n.jobMatchingViewInsights,
                  style: const TextStyle(
                      color: AppColors.accentCyan,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600),
                ),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.accentCyan,
                  size: 18,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            InsightSection(
                title: l10n.insightWhyMatch, body: analysis.whyMatch),
            if (analysis.strengths.isNotEmpty)
              InsightBullets(
                  title: l10n.insightStrengths,
                  items: analysis.strengths,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success),
            if (analysis.missingSkills.isNotEmpty)
              InsightBullets(
                  title: l10n.insightMissingSkills,
                  items: analysis.missingSkills,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning),
            if (analysis.suggestedImprovements.isNotEmpty)
              InsightBullets(
                  title: l10n.insightSuggestedImprovements,
                  items: analysis.suggestedImprovements,
                  icon: Icons.trending_up_rounded,
                  color: AppColors.accentCyan),
            if (analysis.certifications.isNotEmpty)
              InsightBullets(
                  title: l10n.insightCertsToObtain,
                  items: analysis.certifications,
                  icon: Icons.workspace_premium_outlined,
                  color: AppColors.accentIndigo),
            if (analysis.interviewTips.isNotEmpty)
              InsightBullets(
                  title: l10n.insightInterviewTips,
                  items: analysis.interviewTips,
                  icon: Icons.record_voice_over_outlined,
                  color: AppColors.accentCyan),
          ],
          const SizedBox(height: 14),
          if (employerJobId == null)
            GlowButton(
              label: l10n.commonApply,
              icon: Icons.open_in_new_rounded,
              expand: false,
              onPressed: () => _showApplyPlaceholder(context, job.title),
            )
          else
            EmployerApplyButton(employerJobId: employerJobId),
        ],
      ),
    );
  }

  void _showApplyPlaceholder(BuildContext context, String jobTitle) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.jobMatchingApplyPlaceholder(jobTitle)),
      ),
    );
  }
}

/// Bookmark toggle — saves/unsaves this job (see saved_jobs_provider.dart).
class _SaveJobButton extends ConsumerWidget {
  const _SaveJobButton({required this.job, required this.matchScore});

  final JobPosting job;
  final int matchScore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final savedIds = ref.watch(savedJobPostingIdsProvider);
    final saved = savedIds.contains(job.id);

    // Bookmark save/unsave writes straight to Supabase (saved_jobs_provider)
    // with no return value the button itself renders — without this, a
    // failed write (RLS denial, network blip) left the icon simply not
    // changing with zero feedback. Surface it as a snackbar instead.
    ref.listen(savedJobsControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.jobMatchingCouldNotSave)),
        );
      }
    });

    return IconGlowButton(
      icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
      tooltip: saved ? l10n.jobMatchingUnsaveJob : l10n.jobMatchingSaveJob,
      onTap: () => _toggle(ref, saved),
    );
  }

  Future<void> _toggle(WidgetRef ref, bool saved) async {
    final controller = ref.read(savedJobsControllerProvider.notifier);
    if (saved) {
      await controller.unsave(job.id);
    } else {
      await controller.save(job, matchScore: matchScore);
    }
  }
}
