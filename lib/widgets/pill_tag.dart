import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small rounded label used for metadata badges on cards (employment type,
/// work arrangement, paid/unpaid, ...). Pass [accent] for the gradient-filled
/// variant used to call out a category (e.g. "Internship" vs "Graduate
/// Program").
class PillTag extends StatelessWidget {
  const PillTag({super.key, required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: accent ? AppColors.accentGradient : null,
        color: accent ? null : Colors.white.withValues(alpha: 0.06),
        border: accent ? null : Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent ? Colors.white : AppColors.textSecondary,
          fontSize: 11,
          fontWeight: accent ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
