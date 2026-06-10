import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import 'dictionary_screen.dart';
import 'explore_screen.dart';
import 'review_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CatchLingoMotion.homeIntro,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchLingoColors.canvas,
      body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(CatchLingoSpacing.screen),
            children: [
              const SizedBox(height: CatchLingoSpacing.sm),
              _HomeEntry(
                animation: _controller,
                begin: 0,
                end: 0.32,
                child: const _BrandLockup(),
              ),
              const SizedBox(height: CatchLingoSpacing.lg),
              _HomeEntry(
                animation: _controller,
                begin: 0.08,
                end: 0.48,
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: CatchLingoColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 0.98,
                      letterSpacing: 0,
                    ),
                    children: const [
                      TextSpan(text: 'Explore the world.\n'),
                      TextSpan(
                        text: 'Catch',
                        style: TextStyle(color: CatchLingoColors.warmGreen),
                      ),
                      TextSpan(text: ' new words.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.md),
              _HomeEntry(
                animation: _controller,
                begin: 0.16,
                end: 0.54,
                child: Text(
                  'Point. Discover. Learn.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.xl),
              _HomeEntry(
                animation: _controller,
                begin: 0.22,
                end: 0.45,
                child: const _HeroMark(),
              ),
              const SizedBox(height: CatchLingoSpacing.xl),
              _HomeEntry(
                animation: _controller,
                begin: 0.30,
                end: 0.78,
                child: const _CollectionStatusCard(),
              ),
              const SizedBox(height: CatchLingoSpacing.xl),
              _HomeEntry(
                animation: _controller,
                begin: 0.42,
                end: 0.92,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: CatchLingoColors.warmGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExploreScreen()),
                    );
                  },
                  icon: const Icon(Icons.travel_explore_rounded),
                  label: const Text('Start Exploring'),
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.md),
              _HomeEntry(
                animation: _controller,
                begin: 0.52,
                end: 0.96,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CatchLingoColors.textPrimary,
                    side: BorderSide(
                      color: CatchLingoColors.textPrimary.withValues(alpha: 0.22),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DictionaryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text('My Dictionary'),
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.md),
              _HomeEntry(
                animation: _controller,
                begin: 0.62,
                end: 1,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CatchLingoColors.textPrimary,
                    side: BorderSide(
                      color: CatchLingoColors.textPrimary.withValues(alpha: 0.22),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReviewScreen()),
                    );
                  },
                  icon: const Icon(Icons.style_rounded),
                  label: const Text('Review'),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: CatchLingoColors.warmGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CatchLingoColors.warmGreen.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'C',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: CatchLingoSpacing.md),
        Text(
          'CatchLingo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: CatchLingoColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
      height: 430,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel + 8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8D5B0), Color(0xFFD4C09A), Color(0xFFC8B48A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
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
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF5EDD8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 40,
                color: CatchLingoColors.amber,
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Center(child: _GreetingCat()),
          ),
          const Positioned(
            left: 34,
            bottom: 142,
            child: _MiniWordChip(label: 'kursi'),
          ),
          const Positioned(
            right: 34,
            bottom: 160,
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

class _GreetingCat extends StatelessWidget {
  const _GreetingCat();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 178,
      height: 178,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/welcome_cat.png',
        fit: BoxFit.contain,
        semanticLabel: 'Welcoming black and white cat',
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
          color: Colors.white.withValues(alpha: 0.36),
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
          Icon(icon, size: 16, color: CatchLingoColors.warmGreen),
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
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: CatchLingoColors.warmGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CollectionStatusCard extends StatelessWidget {
  const _CollectionStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                color: CatchLingoColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: CatchLingoColors.amber,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No words collected yet.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: CatchLingoColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Start a discovery session and catch your first word.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CatchLingoColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
