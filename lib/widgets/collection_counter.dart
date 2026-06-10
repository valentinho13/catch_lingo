import 'package:flutter/material.dart';

import '../app/app_theme.dart';

class CollectionCounter extends StatelessWidget {
  const CollectionCounter({
    super.key,
    required this.count,
    this.compact = false,
  });

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CatchLingoMotion.state,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: child,
        );
      },
      child: compact
          ? _CompactCounter(count: count)
          : _SessionCounter(count: count),
    );
  }
}

class _CompactCounter extends StatelessWidget {
  const _CompactCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('compact-$count'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF121615).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        border: Border.all(
          color: CatchLingoColors.mint.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        '$count caught words',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: CatchLingoColors.mint,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SessionCounter extends StatelessWidget {
  const _SessionCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('session-$count'),
      decoration: BoxDecoration(
        color: const Color(0xFF111414).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchLingoSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: CatchLingoColors.mint),
            const SizedBox(width: CatchLingoSpacing.md),
            Expanded(
              child: Text(
                '$count words collected',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
