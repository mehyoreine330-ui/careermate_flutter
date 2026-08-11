import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/info_page_scaffold.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InfoPageScaffold(
      title: l10n.termsOfServiceTitle,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.legalLastUpdated,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            InfoSection(heading: l10n.termsHeading1, body: l10n.termsBody1),
            InfoSection(heading: l10n.termsHeading2, body: l10n.termsBody2),
            InfoSection(heading: l10n.termsHeading3, body: l10n.termsBody3),
            InfoSection(heading: l10n.termsHeading4, body: l10n.termsBody4),
            InfoSection(heading: l10n.termsHeading5, body: l10n.termsBody5),
            InfoSection(heading: l10n.termsHeading6, body: l10n.termsBody6),
            InfoSection(heading: l10n.termsHeading7, body: l10n.termsBody7),
            InfoSection(heading: l10n.termsHeading8, body: l10n.termsBody8),
            InfoSection(heading: l10n.termsHeading9, body: l10n.termsBody9),
            InfoSection(heading: l10n.termsHeading10, body: l10n.termsBody10),
            InfoSection(heading: l10n.termsHeading11, body: l10n.termsBody11),
          ],
        ),
      ),
    );
  }
}
