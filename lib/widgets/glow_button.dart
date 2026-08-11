import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Primary CTA button: indigo -> cyan gradient fill, soft ambient glow that
/// intensifies on hover (web/desktop), and a slight press-down scale — the
/// "dynamic action button" called for in the design brief.
class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _hovering = false;
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.98 : (_hovering ? 1.02 : 1.0);

    return Semantics(
      button: true,
      enabled: !_disabled,
      label: widget.isLoading ? '${widget.label}, loading' : widget.label,
      onTap: _disabled ? null : widget.onPressed,
      child: MouseRegion(
        cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTapDown: _disabled ? null : (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: _disabled ? null : widget.onPressed,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: _disabled
                      ? [
                          AppColors.accentIndigo.withValues(alpha: 0.35),
                          AppColors.accentCyan.withValues(alpha: 0.35),
                        ]
                      : const [AppColors.accentIndigo, AppColors.accentCyan],
                ),
                boxShadow: _disabled
                    ? const []
                    : [
                        BoxShadow(
                          color: AppColors.accentIndigo
                              .withValues(alpha: _hovering ? 0.45 : 0.28),
                          blurRadius: _hovering ? 28 : 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  else ...[
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
