import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// App-wide backdrop: the deep slate gradient plus two soft, off-canvas
/// color "orbs" (indigo top-left, cyan bottom-right) that fade to
/// transparent — the ambient glow seen behind Linear/Vercel-style dashboards,
/// done with a cheap RadialGradient rather than a heavy blur filter so it
/// stays smooth on web.
///
/// Wrap each screen's `body` in this (with `Scaffold(backgroundColor:
/// Colors.transparent, ...)`) rather than applying it once globally, so
/// route transitions don't flash the plain scaffold color underneath.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.showOrbs = true});

  final Widget child;
  final bool showOrbs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showOrbs) ...[
            const Positioned(
              top: -140,
              left: -100,
              child: _GlowOrb(color: AppColors.accentIndigo, size: 340),
            ),
            const Positioned(
              bottom: -160,
              right: -120,
              child: _GlowOrb(color: AppColors.accentCyan, size: 380),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
