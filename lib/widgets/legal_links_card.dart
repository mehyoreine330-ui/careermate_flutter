import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../screens/info/about_screen.dart';
import '../screens/info/contact_us_screen.dart';
import '../screens/info/privacy_policy_screen.dart';
import '../screens/info/terms_of_service_screen.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

/// Legal & Support links — shared by the candidate Settings screen and the
/// employer Company Profile screen, since both are the "account settings"
/// area for their respective account type.
class LegalLinksCard extends StatelessWidget {
  const LegalLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.legalLinksTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          _LinkRow(
            icon: Icons.privacy_tip_outlined,
            label: l10n.legalLinksPrivacyPolicy,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
          ),
          _LinkRow(
            icon: Icons.description_outlined,
            label: l10n.legalLinksTermsOfService,
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
          ),
          _LinkRow(
            icon: Icons.support_agent_rounded,
            label: l10n.legalLinksContactUs,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactUsScreen())),
          ),
          _LinkRow(
            icon: Icons.info_outline_rounded,
            label: l10n.legalLinksAbout,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.onTap, this.isLast = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accentCyan),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13.5)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
