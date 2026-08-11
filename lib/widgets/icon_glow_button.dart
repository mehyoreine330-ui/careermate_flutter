import 'package:flutter/material.dart';

/// Small circular glass icon button (used for sign-out, notifications, etc.)
/// with a hover-brighten effect on web/desktop.
class IconGlowButton extends StatefulWidget {
  const IconGlowButton(
      {super.key, required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  State<IconGlowButton> createState() => _IconGlowButtonState();
}

class _IconGlowButtonState extends State<IconGlowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: widget.tooltip,
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: _hovering ? 0.14 : 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Icon(widget.icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );

    return widget.tooltip == null
        ? button
        : Tooltip(message: widget.tooltip!, child: button);
  }
}
