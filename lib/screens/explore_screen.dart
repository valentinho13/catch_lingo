import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/mock_catch_words.dart';
import '../models/catch_word.dart';
import '../services/collection_store.dart';
import '../widgets/catch_word_chip.dart';
import '../widgets/collection_counter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final CollectionStore _store = CollectionStore();

  CollectionData _collection = const CollectionData.empty();
  int _sceneIndex = 0;
  int _sessionCatchCount = 0;
  _LatestSpot? _latestSpot;

  MockScene get _scene => mockScenes[_sceneIndex];

  bool get _sceneComplete =>
      _scene.words.every((word) => _collection.isCaught(word.id));

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    final data = await _store.load();
    if (!mounted) return;
    setState(() => _collection = data);
  }

  Future<void> _spotWord(CatchWord word) async {
    final outcome = await _store.recordSpot(word.id);
    final data = await _store.load();
    if (!mounted) return;

    setState(() {
      _collection = data;
      if (outcome.isNewCatch) {
        _sessionCatchCount += 1;
      }
      _latestSpot = _LatestSpot(word: word, outcome: outcome);
    });
  }

  void _nextScene() {
    setState(() {
      _sceneIndex = (_sceneIndex + 1) % mockScenes.length;
      _latestSpot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: CatchLingoSpacing.lg),
            child: Center(
              child: CollectionCounter(count: _sessionCatchCount, compact: true),
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: CatchLingoColors.textMuted,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _scene.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _NextSceneButton(onTap: _nextScene),
              ],
            ),
            const SizedBox(height: CatchLingoSpacing.md),
            AnimatedSwitcher(
              duration: CatchLingoMotion.reveal,
              switchInCurve: Curves.easeOutCubic,
              child: _SceneDiscoveryPanel(
                key: ValueKey('scene-$_sceneIndex'),
                words: _scene.words,
                collection: _collection,
                onSpot: _spotWord,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            CollectionCounter(count: _sessionCatchCount),
            const SizedBox(height: CatchLingoSpacing.md),
            _LatestDiscoveryPanel(
              spot: _latestSpot,
              sceneComplete: _sceneComplete,
              onNextScene: _nextScene,
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestSpot {
  const _LatestSpot({required this.word, required this.outcome});

  final CatchWord word;
  final SpotOutcome outcome;
}

class _NextSceneButton extends StatelessWidget {
  const _NextSceneButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.switch_camera_rounded,
                size: 16,
                color: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: CatchLingoSpacing.sm),
              Text(
                'Next scene',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneDiscoveryPanel extends StatelessWidget {
  const _SceneDiscoveryPanel({
    super.key,
    required this.words,
    required this.collection,
    required this.onSpot,
  });

  final List<CatchWord> words;
  final CollectionData collection;
  final ValueChanged<CatchWord> onSpot;

  static const _chipAlignments = [
    Alignment(-0.92, -0.10),
    Alignment(0.92, -0.24),
    Alignment(-0.92, 0.60),
    Alignment(0.92, 0.48),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 430,
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFEF8), Color(0xFFF6F0DD), Color(0xFFEDF2E0)],
        ),
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _SceneTableSurface()),
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
                  'Words live here',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: CatchLingoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.xs),
                Text(
                  'Tap a marker to catch one',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Positioned.fill(child: _SceneVignette()),
          const Positioned.fill(child: _LensFrame()),
          for (var i = 0; i < words.length && i < _chipAlignments.length; i++)
            Align(
              alignment: _chipAlignments[i],
              child: CatchWordChip(
                key: ValueKey('catch-${words[i].source}'),
                word: words[i],
                isCollected: collection.isCaught(words[i].id),
                markerIcon: markerIconFor(words[i]),
                onTap: () => onSpot(words[i]),
              ),
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

class _SceneTableSurface extends StatelessWidget {
  const _SceneTableSurface();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SceneTableSurfacePainter(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          accent: CatchLingoColors.amberAccent.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

class _SceneTableSurfacePainter extends CustomPainter {
  const _SceneTableSurfacePainter({required this.color, required this.accent});

  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final tableRect = Rect.fromCenter(
      center: Offset(size.width * 0.52, size.height * 0.58),
      width: size.width * 0.78,
      height: size.height * 0.48,
    );

    final tablePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.05), color, accent],
      ).createShader(tableRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, const Radius.circular(42)),
      tablePaint,
    );

    final rimPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect.deflate(8), const Radius.circular(34)),
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SceneTableSurfacePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.accent != accent;
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

class _LatestDiscoveryPanel extends StatelessWidget {
  const _LatestDiscoveryPanel({
    required this.spot,
    required this.sceneComplete,
    required this.onNextScene,
  });

  final _LatestSpot? spot;
  final bool sceneComplete;
  final VoidCallback onNextScene;

  @override
  Widget build(BuildContext context) {
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
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final spot = this.spot;

    if (spot == null) {
      return const _HintCard(key: ValueKey('empty-discovery'));
    }

    if (spot.outcome.isNewCatch && sceneComplete) {
      return _NewCatchCard(
        key: ValueKey('caught-${spot.word.id}-complete'),
        word: spot.word,
        footer: _SceneCompleteFooter(onNextScene: onNextScene),
      );
    }

    if (spot.outcome.isNewCatch) {
      return _NewCatchCard(
        key: ValueKey('caught-${spot.word.id}'),
        word: spot.word,
      );
    }

    return _SeenAgainCard(
      key: ValueKey('seen-${spot.word.id}-${spot.outcome.seenCount}'),
      word: spot.word,
      seenCount: spot.outcome.seenCount,
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CatchLingoSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.touch_app_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: CatchLingoSpacing.md),
            Expanded(
              child: Text(
                'Tap a marker to catch your first word here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CatchLingoColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewCatchCard extends StatelessWidget {
  const _NewCatchCard({super.key, required this.word, this.footer});

  final CatchWord word;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF3E2), Color(0xFFE0EDD6)],
        ),
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        border: Border.all(color: CatchLingoColors.successBorder),
        boxShadow: [
          BoxShadow(
            color: CatchLingoColors.successIcon.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: CatchLingoColors.successIcon,
              ),
              const SizedBox(width: CatchLingoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Caught!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CatchLingoColors.successText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CatchLingoSpacing.xs),
                    Text(
                      word.translation,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: CatchLingoColors.successText,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      word.source,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CatchLingoColors.successIcon,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: CatchLingoSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _SceneCompleteFooter extends StatelessWidget {
  const _SceneCompleteFooter({required this.onNextScene});

  final VoidCallback onNextScene;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
         