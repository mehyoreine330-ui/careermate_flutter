import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_background.dart';

/// Shared full-screen layout for the legal/info pages (Privacy Policy,
/// Terms of Service, Contact Us, About) — back button + title + scrollable
/// content, matching the rest of the app's pushed-screen convention (see
/// job_form_screen.dart / job_applicants_screen.dart).
class InfoPageScaffold extends StatelessWidget {
  const InfoPageScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: child,
                      ),
                    ),
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

/// A heading + body paragraph — the repeating unit of every legal/info page.
class InfoSection extends StatelessWidget {
  const InfoSection({super.key, required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.55),
          ),
        ],
      ),
    );
  }
}
