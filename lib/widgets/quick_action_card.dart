import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

/// Hoverable glass action card — lifts, brightens, and gains an ambient glow
/// on hover (web/desktop), matching the "dynamic action buttons" from the
/// design brief. Tap targets stay large enough for mobile too.
class QuickActionCard extends StatefulWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${widget.label}, ${widget.subtitle}',
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: _hovering ? 0.07 : 0.04),
              border: Border.all(
                color: _hovering
                    ? AppColors.accentCyan.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: AppColors.accentIndigo.withValues(alpha: 0.25),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.accentGradient,
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).quickActionOpen,
                      style: const TextStyle(
                        color: AppColors.accentCyan,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.accentCyan,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
