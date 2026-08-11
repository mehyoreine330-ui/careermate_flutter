import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Custom text input: glass fill, hairline border that glows cyan on focus.
/// Deliberately bypasses the global InputDecorationTheme's border (uses
/// InputBorder.none) so the glow effect can live on the outer container
/// instead, letting it animate independently of the TextField's own focus
/// painting.
class SleekTextField extends StatefulWidget {
  const SleekTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int maxLines;

  @override
  State<SleekTextField> createState() => _SleekTextFieldState();
}

class _SleekTextFieldState extends State<SleekTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: _focused ? AppColors.accentCyan.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.12),
              width: 1.4,
            ),
            boxShadow: _focused
                ? [BoxShadow(color: AppColors.accentCyan.withValues(alpha: 0.25), blurRadius: 16)]
                : const [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: AppColors.accentCyan,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: Colors.white54, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}
