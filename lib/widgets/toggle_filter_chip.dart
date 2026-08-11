import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A tappable pill that toggles between a plain glass state and a
/// gradient-filled "selected" state — used for multi-select filter rows
/// (Job Matching, Internships & Graduate Opportunities).
class ToggleFilterChip extends StatelessWidget {
  const ToggleFilterChip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: selected ? AppColors.accentGradient : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.14),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
