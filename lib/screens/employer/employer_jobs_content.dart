import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/employer_models.dart';
import '../../providers/employer_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/pill_tag.dart';
import '../../widgets/responsive_card_grid.dart';
import 'job_applicants_screen.dart';
import 'job_form_screen.dart';

String _titleCase(String snakeCase) {
  return snakeCase
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join('-');
}

/// Job Management: every job the company has posted, with Create / Edit /
/// Delete / Archive actions and a per-job "View Applicants" entry point.
class EmployerJobsContent extends ConsumerWidget {
  const EmployerJobsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final jobsAsync = ref.watch(employerJobsProvider);

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
                child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(l10n.employerJobsTitle, style: Theme.of(context).textTheme.headlineSmall),
              ),
              GlowButton(
                label: l10n.employerDashboardPostAJob,
                icon: Icons.add_rounded,
                expand: false,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JobFormScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Text(
              l10n.employerJobsSubtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          jobsAsync.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return const _NoJobsState();
              }
              return ResponsiveCardGrid(
                cards: [for (final job in jobs) _JobCard(job: job)],
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
                error is ApiException ? error.message : l10n.employerJobsCouldNotLoad,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoJobsState extends StatelessWidget {
  const _NoJobsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.employerJobsNoneYetTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.employerJobsNoneYetBody,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.45),
          ),
          const SizedBox(height: 14),
          GlowButton(
            label: l10n.employerDashboardPostAJob,
            icon: Icons.add_rounded,
            expand: false,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const JobFormScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

const _statusColors = {
  'active': AppColors.success,
  'archived': AppColors.warning,
  'closed': AppColors.textMuted,
};

class _JobCard extends ConsumerWidget {
  const _JobCard({required this.job});

  final EmployerJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final applicantCountAsync = ref.watch(jobApplicantCountProvider(job.id));

    return GlassCard(
      glowColor: job.status == 'active' ? AppColors.accentIndigo : AppColors.textMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.title.isEmpty ? l10n.employerJobsUntitledRole : job.title,
                  style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: (_statusColors[job.status] ?? AppColors.textMuted).withValues(alpha: 0.15),
                  border: Border.all(color: (_statusColors[job.status] ?? AppColors.textMuted).withValues(alpha: 0.4)),
                ),
                child: Text(
                  _titleCase(job.status),
                  style: TextStyle(
                    color: _statusColors[job.status] ?? AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  [job.location, job.country].where((s) => s.isNotEmpty).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              PillTag(label: _titleCase(job.employmentType)),
              PillTag(label: _titleCase(job.workArrangement)),
              PillTag(label: _titleCase(job.experienceLevel)),
              if (job.field.isNotEmpty) PillTag(label: job.field, accent: true),
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
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.accentCyan),
              const SizedBox(width: 6),
              Text(
                applicantCountAsync.when(
                  data: (count) => l10n.employerJobsApplicantCount(count),
                  loading: () => l10n.employerJobsApplicantCountLoading,
                  error: (_, __) => l10n.employerJobsApplicantCountError,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GlowButton(
                label: l10n.employerJobsViewApplicants,
                icon: Icons.people_alt_outlined,
                expand: false,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => JobApplicantsScreen(job: job)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => JobFormScreen(existingJob: job)),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(l10n.commonEdit),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _toggleArchive(context, ref, job),
                icon: Icon(job.status == 'archived' ? Icons.unarchive_outlined : Icons.archive_outlined, size: 16),
                label: Text(job.status == 'archived' ? l10n.employerJobsReactivate : l10n.employerJobsArchive),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, ref, job),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: Text(l10n.commonDelete),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleArchive(BuildContext context, WidgetRef ref, EmployerJob job) async {
    final controller = ref.read(employerJobControllerProvider.notifier);
    if (job.status == 'archived') {
      await controller.reactivateJob(job.id);
    } else {
      await controller.archiveJob(job.id);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, EmployerJob job) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.employerJobsDeleteConfirmTitle, style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.employerJobsDeleteConfirmBody(job.title),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(employerJobControllerProvider.notifier).deleteJob(job.id);
    }
  }
}
