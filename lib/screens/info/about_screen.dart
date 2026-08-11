import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/info_page_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InfoPageScaffold(
      title: l10n.legalLinksAbout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            glowColor: AppColors.accentIndigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                  child: const Text(
                    'CareerMate',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.aboutTagline,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _FeatureListCard(),
          const SizedBox(height: 16),
          const _VersionCard(),
        ],
      ),
    );
  }
}

class _FeatureListCard extends StatelessWidget {
  const _FeatureListCard();

  List<String> _features(AppLocalizations l10n) => [
        l10n.aboutFeature1,
        l10n.aboutFeature2,
        l10n.aboutFeature3,
        l10n.aboutFeature4,
        l10n.aboutFeature5,
        l10n.aboutFeature6,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aboutFeaturesTitle,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final feature in _features(l10n))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(feature, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aboutVersion,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                info == null ? l10n.commonLoading : '${info.version} (build ${info.buildNumber})',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.aboutCopyright,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
              ),
            ],
          );
        },
      ),
    );
  }
}
