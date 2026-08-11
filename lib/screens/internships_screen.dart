import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/opportunity_models.dart';
import '../providers/opportunity_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/gradient_progress_ring.dart';
import '../widgets/insight_bullets.dart';
import '../widgets/insight_section.dart';
import '../widgets/pill_tag.dart';
import '../widgets/responsive_card_grid.dart';
import '../widgets/toggle_filter_chip.dart';

/// Below this match score, an opportunity isn't worth showing as a
/// "recommendation" — drives the "no suitable opportunities yet" empty
/// state independent of filters.
const int _kLowMatchThreshold = 35;

/// Internships & Graduate Opportunities — AI-scored recommendations from the
/// sample opportunity repository (services/opportunity_repository.py on the
/// backend; swappable for a real internship/graduate-program API later
/// without any UI changes). Mirrors Job Matching's architecture and layout
/// closely. Rendered inside AppShellScreen's content-swap area.
class InternshipsContent extends ConsumerWidget {
  const InternshipsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final baseAsync = ref.watch(opportunityRecommendationsProvider);

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
                child: const Icon(Icons.school_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.internshipsTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Text(
              l10n.internshipsSubtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          baseAsync.when(
            data: (baseRecommendations) {
              final hasSuitableOpportunities =
                  baseRecommendations.any((r) => r.analysis.matchScore >= _kLowMatchThreshold);

              if (baseRecommendations.isEmpty || !hasSuitableOpportunities) {
                return const _NoSuitableOpportunitiesState();
              }

              return Consumer(
                builder: (context, ref, _) {
                  final filtered =
                      ref.watch(filteredOpportunityRecommendationsProvider).valueOrNull ?? const [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FilterBar(),
                      const SizedBox(height: 18),
                      if (filtered.isEmpty)
                        const _NoFilterMatchState()
                      else
                        ResponsiveCardGrid(
                          cards: [for (final rec in filtered) _OpportunityCard(recommendation: rec)],
                          columnsForWidth: (w) => w >= 900 ? 2 : 1,
                        ),
                    ],
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => GlassCard(
              glowColor: AppColors.danger,
              child: Text(
                error is ApiException ? error.message : l10n.internshipsCouldNotLoad,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NoSuitableOpportunitiesState extends StatelessWidget {
  const _NoSuitableOpportunitiesState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.internshipsNoMatchesTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.internshipsNoMatchesBody,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _NoFilterMatchState extends ConsumerWidget {
  const _NoFilterMatchState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.internshipsNoFilterMatchTitle,
            style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.internshipsNoFilterMatchBody,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          GlowButton(
            label: l10n.commonClearFilters,
            expand: false,
            onPressed: () => ref.read(opportunityFilterProvider.notifier).clear(),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filters = ref.watch(opportunityFilterProvider);
    final countries = ref.watch(availableOpportunityCountriesProvider);
    final fields = ref.watch(availableOpportunityFieldsProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.filtersTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              const Spacer(),
              if (filters.hasActiveFilters)
                GestureDetector(
                  onTap: () => ref.read(opportunityFilterProvider.notifier).clear(),
                  child: Text(
                    l10n.commonClearAll,
                    style: const TextStyle(color: AppColors.accentCyan, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;
              final countryDropdown = _PickerDropdown(
                hint: l10n.filtersAllCountries,
                value: filters.country,
                options: countries,
                onChanged: (v) => ref.read(opportunityFilterProvider.notifier).setCountry(v),
              );
              final fieldDropdown = _PickerDropdown(
                hint: l10n.filtersAllFieldsOfStudy,
                value: filters.fieldOfStudy,
                options: fields,
                onChanged: (v) => ref.read(opportunityFilterProvider.notifier).setFieldOfStudy(v),
              );
              if (stacked) {
                return Column(
                  children: [countryDropdown, const SizedBox(height: 10), fieldDropdown],
                );
              }
              return Row(
                children: [
                  Expanded(child: countryDropdown),
                  const SizedBox(width: 10),
                  Expanded(child: fieldDropdown),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ToggleFilterChip(
                label: l10n.filtersInternship,
                selected: filters.internship,
                onTap: () => ref.read(opportunityFilterProvider.notifier).toggleInternship(),
              ),
              ToggleFilterChip(
                label: l10n.filtersGraduateProgram,
                selected: filters.graduateProgram,
                onTap: () => ref.read(opportunityFilterProvider.notifier).toggleGraduateProgram(),
              ),
              ToggleFilterChip(
                label: l10n.filtersRemote,
                selected: filters.remote,
                onTap: () => ref.read(opportunityFilterProvider.notifier).toggleRemote(),
              ),
              ToggleFilterChip(
                label: l10n.filtersHybrid,
                selected: filters.hybrid,
                onTap: () => ref.read(opportunityFilterProvider.notifier).toggleHybrid(),
              ),
              ToggleFilterChip(
                label: l10n.filtersOnsite,
                selected: filters.onsite,
                onTap: () => ref.read(opportunityFilterProvider.notifier).toggleOnsite(),
              ),
              ToggleFilterChip(
                label: l10n.filtersPaid,
                selected: filters.paid,
                onTap: () => ref.read(opportunityFilterProvider.notifier).togglePaid(),
              ),
              ToggleFilterChip(
                label: l10n.filtersUnpaid,
                selected: filters.unpaid,
                onTap: () => ref.read(opportunityFilterProvider.notifier).toggleUnpaid(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickerDropdown extends StatelessWidget {
  const _PickerDropdown({
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
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
          hint: Text(hint, style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(hint)),
            for (final option in options) DropdownMenuItem<String?>(value: option, child: Text(option)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

String _titleCase(String snakeCase) {
  return snakeCase
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class _OpportunityCard extends StatefulWidget {
  const _OpportunityCard({required this.recommendation});

  final OpportunityRecommendation recommendation;

  @override
  State<_OpportunityCard> createState() => _OpportunityCardState();
}

class _OpportunityCardState extends State<_OpportunityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final opportunity = widget.recommendation.opportunity;
    final analysis = widget.recommendation.analysis;
    final location = opportunity.city != null ? '${opportunity.city}, ${opportunity.country}' : opportunity.country;

    return GlassCard(
      glowColor: analysis.matchScore >= 70 ? AppColors.success : AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillTag(
            label: opportunity.isInternship ? l10n.filtersInternship : l10n.filtersGraduateProgram,
            accent: true,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  GradientProgressRing(progress: analysis.matchScore / 100, size: 56, strokeWidth: 5),
                  Text(
                    '${analysis.matchScore}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      opportunity.company,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
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
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (opportunity.duration != null) PillTag(label: opportunity.duration!),
              PillTag(label: _titleCase(opportunity.workArrangement)),
              PillTag(label: opportunity.isPaid ? l10n.filtersPaid : l10n.filtersUnpaid),
            ],
          ),
          if (opportunity.requirements != null && opportunity.requirements!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.internshipsRequirements,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            ...opportunity.requirements!.map(
              (req) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 5, color: AppColors.accentCyan),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(req, style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.35)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Text(
                  _expanded ? l10n.internshipsHideAiInsights : l10n.internshipsViewAiInsights,
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
            InsightSection(title: l10n.insightWhyMatch, body: analysis.whyMatch),
            if (analysis.strengths.isNotEmpty)
              InsightBullets(title: l10n.insightStrengths, items: analysis.strengths, icon: Icons.check_circle_outline_rounded, color: AppColors.success),
            if (analysis.missingSkills.isNotEmpty)
              InsightBullets(title: l10n.insightMissingSkills, items: analysis.missingSkills, icon: Icons.warning_amber_rounded, color: AppColors.warning),
            if (analysis.recommendedCertifications.isNotEmpty)
              InsightBullets(title: l10n.insightRecommendedCerts, items: analysis.recommendedCertifications, icon: Icons.workspace_premium_outlined, color: AppColors.accentIndigo),
            if (analysis.suggestedImprovements.isNotEmpty)
              InsightBullets(title: l10n.insightSuggestedImprovementsBeforeApplying, items: analysis.suggestedImprovements, icon: Icons.trending_up_rounded, color: AppColors.accentCyan),
          ],
          const SizedBox(height: 14),
          GlowButton(
            label: l10n.commonApply,
            icon: Icons.open_in_new_rounded,
            expand: false,
            onPressed: () => _showApplyPlaceholder(context, opportunity.title),
          ),
        ],
      ),
    );
  }

  void _showApplyPlaceholder(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.internshipsApplyPlaceholder(title)),
      ),
    );
  }
}

