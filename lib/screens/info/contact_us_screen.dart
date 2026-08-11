import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/info_page_scaffold.dart';

const _supportEmail = 'support@careermate.app';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InfoPageScaffold(
      title: l10n.contactUsTitle,
      child: GlassCard(
        glowColor: AppColors.accentIndigo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.accentGradient),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.contactUsHeading,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.contactUsBody,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.accentCyan, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: SelectableText(_supportEmail, style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlowButton(
              label: l10n.contactUsEmailSupport,
              icon: Icons.open_in_new_rounded,
              expand: false,
              onPressed: () => _openEmail(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri(scheme: 'mailto', path: _supportEmail, queryParameters: {'subject': 'CareerMate Support'});
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactUsCouldNotOpenMail(_supportEmail))),
      );
    }
  }
}
