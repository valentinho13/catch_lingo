import 'package:flutter/material.dart';

import '../app/app_theme.dart';

enum CatchLingoTab { discover, dictionary, review }

class CatchLingoBottomNav extends StatelessWidget {
  const CatchLingoBottomNav({
    super.key,
    required this.selectedTab,
    required this.onSelected,
  });

  final CatchLingoTab selectedTab;
  final ValueChanged<CatchLingoTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: CatchLingoColors.warmSurface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: CatchLingoColors.textPrimary.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.travel_explore_rounded,
              label: 'Discover',
              isSelected: selectedTab == CatchLingoTab.discover,
              onTap: () => onSelected(CatchLingoTab.discover),
            ),
            _NavItem(
              icon: Icons.menu_book_rounded,
              label: 'Dictionary',
              isSelected: selectedTab == CatchLingoTab.dictionary,
              onTap: () => onSelected(CatchLingoTab.dictionary),
            ),
            _NavItem(
              icon: Icons.style_rounded,
              label: 'Review',
              isSelected: selectedTab == CatchLingoTab.review,
              onTap: () => onSelected(CatchLingoTab.review),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  var _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? CatchLingoColors.warmGreen
        : CatchLingoColors.textMuted;
    final scale = _isPressed ? 0.94 : (widget.isSelected ? 1.04 : 1.0);

    return Expanded(
      child: AnimatedScale(
        scale: scale,
        duration: CatchLingoMotion.tap,
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTapUp: (_) => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: CatchLingoMotion.state,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? CatchLingoColors.warmGreen.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: widget.isSelected ? 1.08 : 1,
                  duration: CatchLingoMotion.state,
                  curve: Curves.easeOutBack,
                  child: Icon(widget.icon, size: 22, color: color),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
