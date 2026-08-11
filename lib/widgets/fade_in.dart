import 'package:flutter/material.dart';

/// One-shot fade + rise entrance animation, played once per mount via
/// `TweenAnimationBuilder` — no `AnimationController`/dispose bookkeeping
/// needed since it never repeats. Give it a new `key` (e.g. keyed by the
/// active sidebar tab) to replay it when the wrapped content changes.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, (1 - value) * 14), child: child),
        );
      },
      child: child,
    );
  }
}
