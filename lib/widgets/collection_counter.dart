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
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Text(
        '$count caught',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
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
    return Card(
      key: ValueKey('session-$count'),
      child: Padding(
        padding: const EdgeInsets.all(CatchLingoSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: CatchLingoSpacing.md),
            Expanded(
              child: Text(
                '$count caught this session',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
