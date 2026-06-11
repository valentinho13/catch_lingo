import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../models/catch_word.dart';

class CatchWordChip extends StatelessWidget {
  const CatchWordChip({
    super.key,
    required this.word,
    required this.isCollected,
    required this.markerIcon,
    required this.onTap,
  });

  final CatchWord word;
  final bool isCollected;
  final IconData markerIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: isCollected ? 1.04 : 1,
      duration: CatchLingoMotion.chip,
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: isCollected ? 124 : 82,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
            child: AnimatedContainer(
              duration: CatchLingoMotion.state,
              curve: Curves.easeOutCubic,
              constraints: BoxConstraints(minHeight: isCollected ? 54 : 66),
              padding: EdgeInsets.symmetric(
                horizontal: isCollected ? 10 : 8,
                vertical: isCollected ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: isCollected
                    ? CatchLingoColors.successSurface
                    : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(
                  isCollected ? CatchLingoRadius.chip : 22,
                ),
                border: Border.all(
                  color: isCollected
                      ? CatchLingoColors.successBorder
                      : colorScheme.primary.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCollected
                        ? CatchLingoColors.successIcon.withValues(alpha: 0.20)
                        : colorScheme.primary.withValues(alpha: 0.10),
                    blurRadius: isCollected ? 16 : 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: CatchLingoMotion.state,
                child: isCollected
                    ? _CaughtContent(key: const ValueKey('caught'), word: word)
                    : _HiddenMarkerContent(
                        key: const ValueKey('hidden'),
                        icon: markerIcon,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HiddenMarkerContent extends StatelessWidget {
  const _HiddenMarkerContent({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(height: CatchLingoSpacing.xs),
        Text(
          'Object',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CaughtContent extends StatelessWidget {
  const _CaughtContent({super.key, required this.word});

  final CatchWord word;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: CatchLingoColors.successIcon,
        ),
        const SizedBox(width: CatchLingoSpacing.sm),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word.translation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CatchLingoColors.successText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                word.source,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: CatchLingoColors.successIcon,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
