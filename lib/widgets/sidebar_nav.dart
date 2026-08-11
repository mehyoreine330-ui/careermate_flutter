import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/nav_items.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

/// The nav list shared by the permanent desktop rail and the mobile drawer.
/// [selectedKey] is null while a pushed screen (Resume Analyzer, Career
/// Report, Mock Interview) is on top — none of the content-swap items are
/// highlighted in that case, which is correct since none of them are the
/// active page.
class SidebarNav extends StatelessWidget {
  const SidebarNav({
    super.key,
    required this.selectedKey,
    required this.onSelect,
    this.width = 260,
    this.items = kNavItems,
  });

  final String? selectedKey;
  final ValueChanged<NavItem> onSelect;
  final double width;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Colors.white.withValues(alpha: 0.03),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.accentGradient.createShader(bounds),
                child: const Text(
                  'CareerMate',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final item in items.where((i) => i.key != 'logout'))
                    _NavTile(
                      item: item,
                      selected: item.key == selectedKey,
                      onTap: () => onSelect(item),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: _NavTile(
                item: items.firstWhere((i) => i.key == 'logout'),
                selected: false,
                onTap: () =>
                    onSelect(items.firstWhere((i) => i.key == 'logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile(
      {required this.item, required this.selected, required this.onTap});

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovering = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = navItemLabel(l10n, widget.item.key);
    final active = widget.selected;
    final highlighted = _hovering || _focused;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        onTap: widget.onTap,
        child: Focus(
          onFocusChange: (focused) => setState(() => _focused = focused),
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.space)) {
              widget.onTap();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: active ? AppColors.accentGradient : null,
                  color: active
                      ? null
                      : (highlighted
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.transparent),
                  border: _focused && !active
                      ? Border.all(
                          color: AppColors.accentCyan.withValues(alpha: 0.5))
                      : null,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color:
                                AppColors.accentIndigo.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.item.icon,
                      size: 20,
                      color: active ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              active ? Colors.white : AppColors.textSecondary,
                          fontSize: 13.5,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
