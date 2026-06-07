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
        width: 124,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
            child: AnimatedContainer(
              duration: CatchLingoMotion.state,
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isCollected
                    ? CatchLingoColors.successSurface
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
                border: Border.all(
                  color: isCollected
                      ? CatchLingoColors.successBorder
                      : colorScheme.primary.withValues(alpha: 0.24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCollected
                        ? CatchLingoColors.successIcon.withValues(alpha: 0.20)
                        : colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: isCollected ? 16 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: CatchLingoMotion.chip,
                    child: Icon(
                      isCollected ? Icons.check_circle_rounded : markerIcon,
                      key: ValueKey(isCollected),
                      size: 20,
                      color: isCollected
                          ? CatchLingoColors.successIcon
                          : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: CatchLingoSpacing.sm),
                  Expanded(
                    child: AnimatedSize(
                      duration: CatchLingoMotion.state,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        key: ValueKey(isCollected),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCollected ? word.translation : 'Object',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isCollected
                                      ? CatchLingoColors.successText
                                      : colorScheme.onSurface,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          Text(
                            isCollected ? word.source : 'tap to reveal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isCollected
                                      ? const Color(0xFF31765A)
                                      : Colors.black45,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
