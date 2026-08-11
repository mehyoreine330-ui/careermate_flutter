import 'dart:ui';

import 'package:flutter/material.dart';

/// The core glassmorphic surface used everywhere: a blurred, semi-transparent
/// panel with a subtle top-left-to-bottom-right white gradient fill and a
/// hairline border highlight. Pass [glowColor] for cards that should also
/// cast a soft ambient shadow in an accent color (e.g. the score card).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: glowColor == null
            ? null
            : [
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.28),
                  blurRadius: 44,
                  spreadRadius: -8,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
