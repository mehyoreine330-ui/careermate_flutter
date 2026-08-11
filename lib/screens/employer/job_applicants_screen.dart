import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/employer_models.dart';
import '../../providers/employer_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_progress_ring.dart';
import '../../widgets/insight_bullets.dart';
import '../../widgets/insight_section.dart';
import '../../widgets/pill_tag.dart';

Map<String, String> _statusLabels(AppLocalizations l10n) => {
      'applied': l10n.employerApplicantsStatusApplied,
      'shortlisted': l10n.employerApplicantsStatusShortlisted,
      'interview': l10n.employerApplicantsStatusInterview,
      'hired': l10n.employerApplicantsStatusHired,
      'rejected': l10n.employerApplicantsStatusRejected,
    };

const _statusColors = {
  'applied': AppColors.textSecondary,
  'shortlisted': AppColors.accentCyan,
  'interview': AppColors.warning,
  'hired': AppColors.success,
  'rejected': AppColors.danger,
};

/// Applicant Management for one job: every applicant, their resume/career
/// report, and an AI Match Score computed by the same engine used for
/// candidate-facing Job Matching (GET /jobs/{jobId}/applicants). Shortlist
/// / Reject / Mark Interview / Hire update status via PATCH.
class JobApplicantsScreen extends ConsumerWidget {
  const JobApplicantsScreen({super.key, required this.job});

  final EmployerJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final applicantsAsync = ref.watch(jobApplicantsProvider(job.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.employerApplicantsTitle,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            job.title.isEmpty ? l10n.employerJobsUntitledRole : job.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: applicantsAsync.when(
                    data: (applicants) {
                      if (applicants.isEmpty) {
                        return const _NoApplicantsState();
                      }
                      final sorted = [...applicants]
                        ..sort((a, b) => (b.matchAnalysis?.matchScore ?? -1).compareTo(a.matchAnalysis?.matchScore ?? -1));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final applicant in sorted) ...[
                            _ApplicantCard(jobId: job.id, applicant: applicant),
                            const SizedBox(height: 16),
                          ],
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (error, _) => GlassCard(
                      glowColor: AppColors.danger,
                      child: Text(
                        error is ApiException ? error.message : l10n.employerApplicantsCouldNotLoad,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoApplicantsState extends StatelessWidget {
  const _NoApplicantsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.employerApplicantsNoneYetTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.employerApplicantsNoneYetBody,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ApplicantCard extends ConsumerStatefulWidget {
  const _ApplicantCard({required this.jobId, required this.applicant});

  final String jobId;
  final ApplicantRecommendation applicant;

  @override
  ConsumerState<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends ConsumerState<_ApplicantCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusLabels = _statusLabels(l10n);
    final applicant = widget.applicant;
    final analysis = applicant.matchAnalysis;
    final updating = ref.watch(applicationStatusControllerProvider).isLoading;

    return GlassCard(
      glowColor: (analysis?.matchScore ?? 0) >= 70 ? AppColors.success : AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (analysis != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    GradientProgressRing(progress: analysis.matchScore / 100, size: 56, strokeWidth: 5),
                    Text(
                      '${analysis.matchScore}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ],
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
                  child: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 24),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.fullName.isEmpty ? l10n.employerApplicantsCandidate : applicant.fullName,
                      style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      applicant.email.isEmpty ? l10n.commonNotAvailable : applicant.email,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: (_statusColors[applicant.status] ?? AppColors.textMuted).withValues(alpha: 0.15),
                  border: Border.all(
                    color: (_statusColors[applicant.status] ?? AppColors.textMuted).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  statusLabels[applicant.status] ?? applicant.status,
                  style: TextStyle(
                    color: _statusColors[applicant.status] ?? AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (applicant.resume != null)
                PillTag(label: l10n.employerApplicantsResumeAts(applicant.resume!.atsScore))
              else
                PillTag(label: l10n.employerApplicantsNoResume),
              if (applicant.careerReport != null)
                PillTag(label: l10n.employerApplicantsHiringScore(applicant.careerReport!.estimatedHiringScore))
              else
                PillTag(label: l10n.employerApplicantsNoCareerReport),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Text(
                  _expanded ? l10n.employerApplicantsHideMatchAnalysis : l10n.employerApplicantsViewMatchAnalysis,
                  style: const TextStyle(color: AppColors.accentCyan, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                Icon(
                  _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.accentCyan,
                  size: 18,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            if (analysis == null)
              Text(
                l10n.employerApplicantsAnalysisUnavailable,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              )
            else ...[
              InsightSection(title: l10n.employerApplicantsWhyMatch, body: analysis.whyMatch),
              if (analysis.strengths.isNotEmpty)
                InsightBullets(title: l10n.insightStrengths, items: analysis.strengths, icon: Icons.check_circle_outline_rounded, color: AppColors.success),
              if (analysis.missingSkills.isNotEmpty)
                InsightBullets(title: l10n.insightMissingSkills, items: analysis.missingSkills, icon: Icons.warning_amber_rounded, color: AppColors.warning),
              if (analysis.suggestedImprovements.isNotEmpty)
                InsightBullets(title: l10n.insightSuggestedImprovements, items: analysis.suggestedImprovements, icon: Icons.trending_up_rounded, color: AppColors.accentCyan),
              if (analysis.certifications.isNotEmpty)
                InsightBullets(title: l10n.employerApplicantsRelevantCerts, items: analysis.certifications, icon: Icons.workspace_premium_outlined, color: AppColors.accentIndigo),
              if (analysis.interviewTips.isNotEmpty)
                InsightBullets(title: l10n.employerApplicantsInterviewTips, items: analysis.interviewTips, icon: Icons.record_voice_over_outlined, color: AppColors.accentCyan),
            ],
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusButton(
                label: l10n.employerApplicantsShortlist,
                status: 'shortlisted',
                current: applicant.status,
                enabled: !updating,
                onTap: () => _updateStatus(context, 'shortlisted'),
              ),
              _StatusButton(
                label: l10n.employerApplicantsMarkInterview,
                status: 'interview',
                current: applicant.status,
                enabled: !updating,
                onTap: () => _updateStatus(context, 'interview'),
              ),
              _StatusButton(
                label: l10n.employerApplicantsHire,
                status: 'hired',
                current: applicant.status,
                enabled: !updating,
                onTap: () => _updateStatus(context, 'hired'),
              ),
              _StatusButton(
                label: l10n.employerApplicantsReject,
                status: 'rejected',
                current: applicant.status,
                enabled: !updating,
                isDestructive: true,
                onTap: () => _updateStatus(context, 'rejected'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    await ref.read(applicationStatusControllerProvider.notifier).updateStatus(
          jobId: widget.jobId,
          applicationId: widget.applicant.applicationId,
          newStatus: newStatus,
        );
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final state = ref.read(applicationStatusControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error is ApiException
                ? (state.error as ApiException).message
                : l10n.employerApplicantsCouldNotUpdateStatus,
          ),
        ),
      );
    }
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.status,
    required this.current,
    required this.enabled,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final String status;
  final String current;
  final bool enabled;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final active = current == status;
    final color = isDestructive ? AppColors.danger : AppColors.accentCyan;

    return OutlinedButton(
      onPressed: enabled && !active ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? Colors.white : color,
        backgroundColor: active ? color.withValues(alpha: 0.25) : null,
        side: BorderSide(color: color.withValues(alpha: active ? 0.7 : 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }
}
