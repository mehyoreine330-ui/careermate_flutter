import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/info_page_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InfoPageScaffold(
      title: l10n.privacyPolicyTitle,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.legalLastUpdated,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            InfoSection(heading: l10n.privacyHeading1, body: l10n.privacyBody1),
            InfoSection(heading: l10n.privacyHeading2, body: l10n.privacyBody2),
            InfoSection(heading: l10n.privacyHeading3, body: l10n.privacyBody3),
            InfoSection(heading: l10n.privacyHeading4, body: l10n.privacyBody4),
            InfoSection(heading: l10n.privacyHeading5, body: l10n.privacyBody5),
            InfoSection(heading: l10n.privacyHeading6, body: l10n.privacyBody6),
            InfoSection(heading: l10n.privacyHeading7, body: l10n.privacyBody7),
            InfoSection(heading: l10n.privacyHeading8, body: l10n.privacyBody8),
            InfoSection(heading: l10n.privacyHeading9, body: l10n.privacyBody9),
          ],
        ),
      ),
    );
  }
}
