import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A labeled bullet list inside an expandable "AI Insights" block — used by
/// Job Matching, Internships & Graduate Opportunities, and the Employer
/// Portal's applicant AI Match Analysis.
class InsightBullets extends StatelessWidget {
  const InsightBullets({
    super.key,
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 13, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.35)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
