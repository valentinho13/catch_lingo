import 'package:flutter/material.dart';

import '../app/app_theme.dart';
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(CatchLingoSpacing.screen),
          children: [
            const SizedBox(height: 18),
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
                  color: const Color(0xFF202338),
                  fontWeight: FontWeight.w900,
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
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
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
              end: 1,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DictionaryScreen()),
                  );
                },
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('My Dictionary'),
              ),
            ),
          ],
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

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, const Color(0xFF37BFA6)],
                ),
                borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.catching_pokemon_rounded,
                size: 54,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _MiniWordChip(label: 'kursi'),
                SizedBox(width: CatchLingoSpacing.sm),
                _MiniWordChip(label: 'botol'),
                SizedBox(width: CatchLingoSpacing.sm),
                _MiniWordChip(label: 'kopi'),
              ],
            ),
          ],
        ),
      ),
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
  const _CollectionStatusCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
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
                    'No words collected yet.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Start a discovery session and catch your first word.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
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
