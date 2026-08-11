import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'glow_button.dart';

/// A single, consistent "nothing here yet" presentation — a soft glow icon
/// badge, title, message, and an optional primary action. Replaces the
/// near-identical private empty-state classes each screen used to
/// reimplement on its own (same data/callbacks, shared presentation).
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    this.glowColor = AppColors.accentIndigo,
  });

  final IconData icon;
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: glowColor,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(color: glowColor.withValues(alpha: 0.35), blurRadius: 28, spreadRadius: -4),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 20),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.5),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 22),
            GlowButton(
              label: actionLabel!,
              expand: false,
              isLoading: isLoading,
              onPressed: isLoading ? null : onAction,
            ),
          ],
        ],
      ),
    );
  }
}
