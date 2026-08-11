import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A labeled paragraph inside an expandable "AI Insights" block — used by
/// Job Matching, Internships & Graduate Opportunities, and the Employer
/// Portal's applicant AI Match Analysis.
class InsightSection extends StatelessWidget {
  const InsightSection({super.key, required this.title, required this.body});

  final String title;
  final String body;

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
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.4)),
        ],
      ),
    );
  }
}
