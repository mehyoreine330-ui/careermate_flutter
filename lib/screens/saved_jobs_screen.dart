import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/saved_job_models.dart';
import '../providers/candidate_application_provider.dart';
import '../providers/saved_jobs_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/employer_apply_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/gradient_progress_ring.dart';
import '../widgets/pill_tag.dart';
import '../widgets/responsive_card_grid.dart';

String _titleCase(String snakeCase) {
  return snakeCase
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join('-');
}

/// Every job the candidate has bookmarked from Job Matching. Each card is a
/// self-contained snapshot (see saved_jobs_provider.dart) so it keeps
/// rendering correctly even if the original Job Matching result set has
/// since changed.
class SavedJobsContent extends ConsumerWidget {
  const SavedJobsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final savedAsync = ref.watch(savedJobsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.accentGradient),
                child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Text(l10n.savedJobsTitle, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Text(
              l10n.savedJobsSubtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          savedAsync.when(
            data: (saved) {
              if (saved.isEmpty) {
                return const _NoSavedJobsState();
              }
              return ResponsiveCardGrid(
                cards: [for (final savedJob in saved) _SavedJobCard(savedJob: savedJob)],
                columnsForWidth: (w) => w >= 900 ? 2 : 1,
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => GlassCard(
              glowColor: AppColors.danger,
              child: Text(
                error is ApiException ? error.message : l10n.savedJobsCouldNotLoad,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSavedJobsState extends StatelessWidget {
  const _NoSavedJobsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.savedJobsNoneYetTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.savedJobsNoneYetBody,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _SavedJobCard extends ConsumerWidget {
  const _SavedJobCard({required this.savedJob});

  final SavedJob savedJob;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final job = savedJob.job;
    final employerJobId = employerJobIdFromPostingId(job.id);
    final matchScore = savedJob.matchScore;

    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (matchScore != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    GradientProgressRing(progress: matchScore / 100, size: 56, strokeWidth: 5),
                    Text(
                      '$matchScore%',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              if (matchScore != null) const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(job.company, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${job.location}, ${job.country}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_remove_outlined, color: AppColors.textSecondary, size: 20),
                tooltip: l10n.commonUnsave,
                onPressed: () => ref.read(savedJobsControllerProvider.notifier).unsave(job.id),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (employerJobId != null) PillTag(label: l10n.jobMatchingCareerMateEmployer, accent: true),
              PillTag(label: _titleCase(job.employmentType)),
              PillTag(label: _titleCase(job.workArrangement)),
              PillTag(label: _titleCase(job.experienceLevel)),
            ],
          ),
          if (job.salaryRange != null && job.salaryRange!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 14, color: AppColors.accentCyan),
                const SizedBox(width: 6),
                Text(job.salaryRange!, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          if (employerJobId != null)
            EmployerApplyButton(employerJobId: employerJobId)
          else
            GlowButton(
              label: l10n.savedJobsViewInMatching,
              icon: Icons.open_in_new_rounded,
              expand: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.savedJobsViewInMatchingSnackbar)),
                );
              },
            ),
        ],
      ),
    );
  }
}
