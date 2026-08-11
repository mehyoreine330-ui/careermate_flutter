import 'package:flutter/material.dart';

/// Responsive `Wrap`-based grid: lays cards out in however many columns fit
/// the available width, one column on narrow/mobile layouts. Used by any
/// screen showing a list of equal-ish-width cards (Dashboard, Job Matching,
/// Internships & Graduate Opportunities, ...).
///
/// [columnsForWidth] decides the column count from the available width —
/// pass a screen-specific breakpoint function (e.g. Dashboard uses a 3-tier
/// 4/2/1 breakpoint, Job Matching and Internships use a simpler 2/1).
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.cards,
    required this.columnsForWidth,
    this.spacing = 16.0,
  });

  final List<Widget> cards;
  final int Function(double width) columnsForWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsForWidth(constraints.maxWidth);
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: itemWidth, child: card),
          ],
        );
      },
    );
  }
}
