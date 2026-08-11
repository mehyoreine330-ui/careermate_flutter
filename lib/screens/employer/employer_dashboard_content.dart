import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/employer_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/responsive_card_grid.dart';

/// Employer Portal's home page: Total Jobs / Active Jobs / Applications
/// Received / Interviews Scheduled, pulled from the backend's one
/// aggregation endpoint (GET /api/v1/employer-portal/dashboard).
class EmployerDashboardContent extends ConsumerWidget {
  const EmployerDashboardContent({super.key, required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(employerDashboardProvider);

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
                child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Text(l10n.employerDashboardTitle, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Text(
              l10n.employerDashboardSubtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 22),
          statsAsync.when(
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveCardGrid(
                  cards: [
                    _CountStatCard(icon: Icons.work_outline_rounded, label: l10n.employerDashboardTotalJobs, count: stats.totalJobs),
                    _CountStatCard(
                      icon: Icons.bolt_rounded,
                      label: l10n.employerDashboardActiveJobs,
                      count: stats.activeJobs,
                    ),
                    _CountStatCard(
                      icon: Icons.people_outline_rounded,
                      label: l10n.employerDashboardApplicationsReceived,
                      count: stats.applicationsReceived,
                    ),
                    _CountStatCard(
                      icon: Icons.event_available_outlined,
                      label: l10n.employerDashboardInterviewsScheduled,
                      count: stats.interviewsScheduled,
                    ),
                  ],
                  columnsForWidth: (w) => w >= 900 ? 4 : (w >= 560 ? 2 : 1),
                ),
                const SizedBox(height: 24),
                if (stats.totalJobs == 0)
                  GlassCard(
                    glowColor: AppColors.accentIndigo,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.accentGradient),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            l10n.employerDashboardPostFirstJob,
                            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                          ),
                        ),
                        const SizedBox(width: 14),
                        GlowButton(
                          label: l10n.employerDashboardPostAJob,
                          expand: false,
                          onPressed: () => onNavigate('employer_jobs'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => GlassCard(
              glowColor: AppColors.danger,
              child: Text(
                error is ApiException ? error.message : l10n.employerDashboardCouldNotLoad,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountStatCard extends StatelessWidget {
  const _CountStatCard({required this.icon, required this.label, required this.count});

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentCyan.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: AppColors.accentCyan, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Text(
                  label,
                  maxLines: 2,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    height: 1.3,
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
