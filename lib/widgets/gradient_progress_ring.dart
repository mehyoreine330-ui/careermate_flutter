import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A circular progress ring with an indigo -> cyan gradient stroke, used for
/// the employability score. Plain CircularProgressIndicator only supports a
/// single stroke color, so this paints the arc manually with a SweepGradient
/// shader to get the "glowing accent" look called for in the design brief.
///
/// Animates from 0 to [progress] whenever the widget is first built or
/// [progress] changes (e.g. once an analysis result comes back) — the
/// "animated gauge" called for in the CV optimization flow.
class GradientProgressRing extends StatelessWidget {
  const GradientProgressRing({
    super.key,
    required this.progress,
    this.size = 96,
    this.strokeWidth = 9,
    this.animate = true,
  });

  /// 0.0 - 1.0
  final double progress;
  final double size;
  final double strokeWidth;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final target = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: animate ? const Duration(milliseconds: 1200) : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _GradientRingPainter(progress: value, strokeWidth: strokeWidth),
          );
        },
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: sweepAngle,
      transform: const GradientRotation(-math.pi / 2),
      colors: const [AppColors.accentIndigo, AppColors.accentCyan],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
}
