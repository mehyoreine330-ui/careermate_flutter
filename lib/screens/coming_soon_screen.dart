import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

/// Professional placeholder content for modules that don't have a real
/// implementation yet. Rendered inside AppShellScreen's content area (the
/// sidebar stays visible/permanent), not as its own full-screen route.
class ComingSoonContent extends StatelessWidget {
  const ComingSoonContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: GlassCard(
          glowColor: AppColors.accentIndigo,
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.accentGradient,
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.35)),
                ),
                child: Text(
                  AppLocalizations.of(context).comingSoonLabel,
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
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
