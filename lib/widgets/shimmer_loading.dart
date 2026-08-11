import 'package:flutter/material.dart';

import 'glass_card.dart';

/// A rounded placeholder box with a soft diagonal sheen sweeping across it —
/// the skeleton building block every preset below is made of. Used in place
/// of a bare spinner so the loading state occupies roughly the same shape as
/// the content that's about to arrive.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, this.width, this.height = 14, this.borderRadius = 6});

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // The bright band's center sweeps from the box's left edge (-1) to
        // its right edge (+1) and loops — Alignment's fractional space
        // already maps -1..1 to the box's own pixel bounds.
        final center = -1 + 2 * _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(center - 0.7, 0),
              end: Alignment(center + 0.7, 0),
              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.06),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A card-sized skeleton shaped like a typical [GlassCard] section — a
/// title-width line followed by a few shorter body lines — for loading
/// states that should occupy roughly the same footprint as the eventual
/// content instead of a bare centered spinner.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.lines = 3, this.titleWidth = 120});

  final int lines;
  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerBox(width: titleWidth, height: 14),
          const SizedBox(height: 16),
          for (var i = 0; i < lines; i++) ...[
            ShimmerBox(width: i == lines - 1 ? 160 : double.infinity, height: 11),
            if (i != lines - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
