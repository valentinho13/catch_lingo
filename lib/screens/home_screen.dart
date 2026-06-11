import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../services/collection_store.dart';
import 'dictionary_screen.dart';
import 'explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final CollectionStore _store = CollectionStore();
  int _caughtCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CatchLingoMotion.homeIntro,
    )..forward();
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    final data = await _store.load();
    if (!mounted) return;
    setState(() => _caughtCount = data.caughtIds.length);
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => screen));
    _loadCollection();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDFBF2),
              CatchLingoColors.background,
              Color(0xFFF3EFDF),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(CatchLingoSpacing.screen),
            children: [
              const SizedBox(height: 12),
              _HomeEntry(
                animation: _controller,
                begin: 0,
                end: 0.45,
                child: const _HeroMark(),
              ),
              const SizedBox(height: CatchLingoSpacing.xl),
              _HomeEntry(
                animation: _controller,
                begin: 0.12,
                end: 0.58,
                child: Text(
                  'CatchLingo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: CatchLingoColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.md),
              _HomeEntry(
                animation: _controller,
                begin: 0.20,
                end: 0.66,
                child: Text(
                  'Catch words from the world around you.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.xl),
              _HomeEntry(
                animation: _controller,
                begin: 0.30,
                end: 0.78,
                child: _CollectionStatusCard(caughtCount: _caughtCount),
              ),
              const SizedBox(height: CatchLingoSpacing.xl),
              _HomeEntry(
                animation: _controller,
                begin: 0.42,
                end: 0.92,
                child: FilledButton.icon(
                  onPressed: () => _open(const ExploreScreen()),
                  icon: const Icon(Icons.travel_explore_rounded),
                  label: const Text('Start Exploring'),
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.md),
              _HomeEntry(
                animation: _controller,
                begin: 0.52,
                end: 1,
                child: OutlinedButton.icon(
                  onPressed: () => _open(const DictionaryScreen()),
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text('My Dictionary'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeEntry extends StatelessWidget {
  const _HomeEntry({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _HeroMark extends StatelessWidget {
  const _HeroMark();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 258,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel + 8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFEF8), Color(0xFFF7F1DE), Color(0xFFEDF2E0)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _HomeLensFrame()),
          Positioned(
            top: 22,
            left: 22,
            child: _HeroPill(
              icon: Icons.camera_alt_rounded,
              label: 'Live discovery',
              color: colorScheme.primary,
            ),
          ),
          Center(
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [CatchLingoColors.seed, CatchLingoColors.amberAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.22),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Icon(
                Icons.center_focus_strong_rounded,
                size: 54,
                color: Colors.white,
              ),
            ),
          ),
          const Positioned(
            left: 34,
            bottom: 34,
            child: _MiniWordChip(label: 'kursi'),
          ),
          const Positioned(
            right: 34,
            bottom: 44,
            child: _MiniWordChip(label: 'kopi'),
          ),
          const Positioned(
            right: 54,
            top: 78,
            child: _ObjectMarker(icon: Icons.local_cafe_rounded),
          ),
          const Positioned(
            left: 50,
            top: 94,
            child: _ObjectMarker(icon: Icons.chair_rounded),
          ),
        ],
      ),
    );
  }
}

class _HomeLensFrame extends StatelessWidget {
  const _HomeLensFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _HomeLensFramePainter(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
    );
  }
}

class _HomeLensFramePainter extends CustomPainter {
  const _HomeLensFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const inset = 30.0;
    const length = 38.0;
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
  bool shouldRepaint(covariant _HomeLensFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: CatchLingoSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectMarker extends StatelessWidget {
  const _ObjectMarker({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _MiniWordChip extends StatelessWidget {
  const _MiniWordChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CollectionStatusCard extends StatelessWidget {
  const _CollectionStatusCard({required this.caughtCount});

  final int caughtCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: CatchLingoColors.card,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.secondaryContainer,
                    CatchLingoColors.successSurface,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caughtCount == 0
                        ? 'No words caught yet.'
                        : '$caughtCount ${caughtCount == 1 ? 'word' : 'words'} in your journal.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
 