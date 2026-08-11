import 'package:flutter/material.dart';

/// Lays out a row of equal-height cards on desktop (via `IntrinsicHeight` so
/// every card in the row stretches to match the tallest), or stacks them in
/// a single column on mobile. Used by Resume Analyzer and AI Career Report
/// for their breakdown card sections.
class EqualHeightCardRow extends StatelessWidget {
  const EqualHeightCardRow({super.key, required this.cards, required this.isDesktop});

  final List<Widget> cards;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: cards[i]),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final card in cards) ...[card, const SizedBox(height: 16)],
      ],
    );
  }
}
