import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/candidate_application_provider.dart';
import 'glow_button.dart';

/// Apply button for a real, employer-posted job — creates a genuine
/// application row (see candidate_application_provider.dart). Used on both
/// Job Matching cards and Saved Jobs cards for employer-sourced postings.
class EmployerApplyButton extends ConsumerWidget {
  const EmployerApplyButton({super.key, required this.employerJobId});

  final String employerJobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appliedIdsAsync = ref.watch(myAppliedEmployerJobIdsProvider);
    final applying = ref.watch(candidateApplyControllerProvider).isLoading;
    final alreadyApplied = appliedIdsAsync.valueOrNull?.contains(employerJobId) ?? false;

    return GlowButton(
      label: alreadyApplied ? l10n.commonApplied : l10n.commonApply,
      icon: alreadyApplied ? Icons.check_circle_outline_rounded : Icons.send_rounded,
      expand: false,
      isLoading: applying,
      onPressed: alreadyApplied || applying ? null : () => _apply(context, ref),
    );
  }

  Future<void> _apply(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(candidateApplyControllerProvider.notifier).apply(employerJobId);
    if (!context.mounted) return;

    final state = ref.read(candidateApplyControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error is ApiException ? (state.error as ApiException).message : l10n.candidateApplyFailed,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.candidateApplySuccess)),
    );
  }
}
