import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Left brand panel (desktop only) + right form panel, split ~55/45.
/// Shared by the candidate and employer login screens — same visual
/// treatment, different headline/description copy per audience.
class AuthDesktopLayout extends StatelessWidget {
  const AuthDesktopLayout({
    super.key,
    required this.child,
    required this.headline,
    required this.description,
  });

  final Widget child;
  final String headline;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                  child: const Text(
                    'CareerMate',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
