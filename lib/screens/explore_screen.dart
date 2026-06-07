import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/mock_catch_words.dart';
import '../models/catch_word.dart';
import '../widgets/catch_word_chip.dart';
import '../widgets/collection_counter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Set<String> _collectedWords = {};
  CatchWord? _latestCollectedWord;
  String? _duplicateMessage;

  void _collectWord(CatchWord word) {
    if (_collectedWords.contains(word.source)) {
      setState(() {
        _duplicateMessage = '${word.translation} is already in this scene.';
        _latestCollectedWord = word;
      });
      return;
    }

    setState(() {
      _collectedWords.add(word.source);
      _latestCollectedWord = word;
      _duplicateMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Mode'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: CatchLingoSpacing.lg),
            child: Center(
              child: CollectionCounter(
                count: _collectedWords.length,
                compact: true,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchLingoSpacing.screen,
            CatchLingoSpacing.sm,
            CatchLingoSpacing.screen,
            CatchLingoSpacing.screen,
          ),
          children: [
            Text(
              'Discovery preview',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: CatchLingoSpacing.xs),
            Text(
              mockSceneName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: CatchLingoSpacing.md),
            _SceneDiscoveryPanel(
              words: mockCatchWords,
              collectedWords: _collectedWords,
              onCatch: _collectWord,
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            CollectionCounter(count: _collectedWords.length),
            const SizedBox(height: CatchLingoSpacing.md),
            _LatestDiscoveryPanel(
              word: _latestCollectedWord,
              duplicateMessage: _duplicateMessage,
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            _SceneHintCard(totalObjects: mockCatchWords.length),
          ],
        ),
      ),
    );
  }
}

class _SceneDiscoveryPanel extends StatelessWidget {
  const _SceneDiscoveryPanel({
    required this.words,
    required this.collectedWords,
    required this.onCatch,
  });

  final List<CatchWord> words;
  final Set<String> collectedWords;
  final ValueChanged<CatchWord> onCatch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 420,
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEFF3FF), Color(0xFFE8F8F3)],
        ),
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            child: _SceneBadge(icon: Icons.camera_alt_rounded, label: 'Scene'),
          ),
          Positioned(
            top: 54,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Objects are coming into focus',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: CatchLingoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.xs),
                Text(
                  'Tap a marker to reveal what the app noticed',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const Positioned.fill(child: _LensFrame()),
          const Positioned.fill(child: _SceneVignette()),
          _PositionedObjectChip(
            alignment: const Alignment(-0.92, -0.10),
            word: words[0],
            isCollected: collectedWords.contains(words[0].source),
            onTap: () => onCatch(words[0]),
          ),
          _PositionedObjectChip(
            alignment: const Alignment(0.92, -0.24),
            word: words[1],
            isCollected: collectedWords.contains(words[1].source),
            onTap: () => onCatch(words[1]),
          ),
          _PositionedObjectChip(
            alignment: const Alignment(-0.92, 0.60),
            word: words[2],
            isCollected: collectedWords.contains(words[2].source),
            onTap: () => onCatch(words[2]),
          ),
          _PositionedObjectChip(
            alignment: const Alignment(0.92, 0.48),
            word: words[3],
            isCollected: collectedWords.contains(words[3].source),
            onTap: () => onCatch(words[3]),
          ),
        ],
      ),
    );
  }
}

class _SceneBadge extends StatelessWidget {
  const _SceneBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: CatchLingoSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _LensFrame extends StatelessWidget {
  const _LensFrame();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.20);

    return IgnorePointer(
      child: CustomPaint(painter: _LensFramePainter(color: color)),
    );
  }
}

class _SceneVignette extends StatelessWidget {
  const _SceneVignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.95,
            colors: [
              Colors.white.withValues(alpha: 0),
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
              Colors.black.withValues(alpha: 0.035),
            ],
            stops: const [0.50, 0.82, 1],
          ),
        ),
      ),
    );
  }
}

class _LensFramePainter extends CustomPainter {
  const _LensFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const length = 34.0;
    const inset = 8.0;
    final right = size.width - inset;
    final bottom = size.height - inset;

    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset + length, inset),
      paint,
    );
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset, inset + length),
      paint,
    );
    canvas.drawLine(Offset(right, inset), Offset(right - length, inset), paint);
    canvas.drawLine(Offset(right, inset), Offset(right, inset + length), paint);
    canvas.drawLine(
      Offset(inset, bottom),
      Offset(inset + length, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(inset, bottom),
      Offset(inset, bottom - length),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right - length, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LensFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PositionedObjectChip extends StatelessWidget {
  const _PositionedObjectChip({
    required this.alignment,
    required this.word,
    required this.isCollected,
    required this.onTap,
  });

  final Alignment alignment;
  final CatchWord word;
  final bool isCollected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: CatchWordChip(
        key: ValueKey('catch-${word.source}'),
        word: word,
        isCollected: isCollected,
        markerIcon: _markerIconFor(word),
        onTap: onTap,
      ),
    );
  }

  IconData _markerIconFor(CatchWord word) {
    return switch (word.source) {
      'coffee' => Icons.local_cafe_rounded,
      'cup' => Icons.local_drink_rounded,
      'table' => Icons.table_restaurant_rounded,
      'chair' => Icons.chair_rounded,
      _ => Icons.center_focus_strong_rounded,
    };
  }
}

class _LatestDiscoveryPanel extends StatelessWidget {
  const _LatestDiscoveryPanel({
    required this.word,
    required this.duplicateMessage,
  });

  final CatchWord? word;
  final String? duplicateMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: CatchLingoMotion.feedback,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: word == null
          ? Card(
              key: const ValueKey('empty-discovery'),
              child: Padding(
                padding: const EdgeInsets.all(CatchLingoSpacing.lg),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded, color: colorScheme.primary),
                    const SizedBox(width: CatchLingoSpacing.md),
                    Expanded(
                      child: Text(
                        'Choose a marker in the scene to reveal its word.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              key: ValueKey('${word!.source}-$duplicateMessage'),
              padding: const EdgeInsets.all(CatchLingoSpacing.lg),
              decoration: BoxDecoration(
                color: duplicateMessage == null
                    ? CatchLingoColors.successSurface
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(CatchLingoRadius.card),
                border: Border.all(
                  color: duplicateMessage == null
                      ? CatchLingoColors.successBorder
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    duplicateMessage == null
                        ? Icons.check_circle_rounded
                        : Icons.info_rounded,
                    color: duplicateMessage == null
                        ? CatchLingoColors.successIcon
                        : colorScheme.primary,
                  ),
                  const SizedBox(width: CatchLingoSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          duplicateMessage ?? '${word!.source} found nearby',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: duplicateMessage == null
                                    ? CatchLingoColors.successText
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (duplicateMessage == null) ...[
                          const SizedBox(height: CatchLingoSpacing.xs),
                          Text(
                            '${word!.translation} caught',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: CatchLingoColors.successText,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SceneHintCard extends StatelessWidget {
  const _SceneHintCard({required this.totalObjects});

  final int totalObjects;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CatchLingoSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: CatchLingoSpacing.md),
            Expanded(
              child: Text(
                '$totalObjects hidden objects in this scene can become words.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
