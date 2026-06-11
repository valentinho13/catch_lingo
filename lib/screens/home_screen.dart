import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/caught_word_storage.dart';
import '../models/catch_word.dart';
import '../widgets/catch_lingo_bottom_nav.dart';
import '../widgets/word_visuals.dart';
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
  static const _storage = CaughtWordStorage();

  late final AnimationController _controller;
  late Future<List<CatchWord>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CatchLingoMotion.homeIntro,
    )..forward();
    _wordsFuture = _storage.loadWords();
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
      bottomNavigationBar: CatchLingoBottomNav(
        selectedTab: CatchLingoTab.discover,
        onSelected: _openTab,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(CatchLingoSpacing.screen),
          children: [
            _HomeEntry(
              animation: _controller,
              begin: 0,
              end: 0.32,
              child: _MorningHeader(onSettings: _showSettingsSheet),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            _HomeEntry(
              animation: _controller,
              begin: 0.08,
              end: 0.48,
              child: _TodayCatchCard(onExplore: _openExplore),
            ),
            const SizedBox(height: CatchLingoSpacing.xl),
            _HomeEntry(
              animation: _controller,
              begin: 0.42,
              end: 0.92,
              child: FutureBuilder<List<CatchWord>>(
                future: _wordsFuture,
                builder: (context, snapshot) {
                  final words = snapshot.data ?? [];

                  return _HomeStats(words: words);
                },
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.xl),
            _HomeEntry(
              animation: _controller,
              begin: 0.52,
              end: 0.96,
              child: FutureBuilder<List<CatchWord>>(
                future: _wordsFuture,
                builder: (context, snapshot) {
                  final words = snapshot.data ?? [];

                  return _HomeCategories(
                    words: words,
                    onDictionary: _openDictionary,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExplore() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ExploreScreen()));

    if (!mounted) {
      return;
    }

    setState(() {
      _wordsFuture = _storage.loadWords();
    });
  }

  Future<void> _openDictionary() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DictionaryScreen()));

    if (!mounted) {
      return;
    }

    setState(() {
      _wordsFuture = _storage.loadWords();
    });
  }

  void _showSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CatchLingoColors.warmSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CatchLingoRadius.panel),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchLingoSpacing.screen,
              CatchLingoSpacing.sm,
              CatchLingoSpacing.screen,
              CatchLingoSpacing.screen,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: CatchLingoColors.warmGreen.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: CatchLingoColors.warmGreen,
                      ),
                    ),
                    const SizedBox(width: CatchLingoSpacing.md),
                    Expanded(
                      child: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: CatchLingoColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: CatchLingoSpacing.lg),
                Text(
                  'CatchLingo is focused on real-world word discovery. Language, camera, and reminder preferences will live here as the app grows.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.xl),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: CatchLingoColors.warmGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openTab(CatchLingoTab tab) async {
    switch (tab) {
      case CatchLingoTab.discover:
        break;
      case CatchLingoTab.dictionary:
        await _openDictionary();
        break;
      case CatchLingoTab.review:
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ReviewScreen()));

        if (!mounted) {
          return;
        }

        setState(() {
          _wordsFuture = _storage.loadWords();
        });
        break;
    }
  }
}

class _MorningHeader extends StatelessWidget {
  const _MorningHeader({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: CatchLingoColors.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.wb_sunny_rounded,
            color: CatchLingoColors.amber,
          ),
        ),
        const SizedBox(width: CatchLingoSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CatchLingoColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'CatchLingo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: CatchLingoColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onSettings,
          style: IconButton.styleFrom(
            backgroundColor: CatchLingoColors.warmSurface,
            foregroundColor: CatchLingoColors.textPrimary,
          ),
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
    );
  }
}

class _TodayCatchCard extends StatelessWidget {
  const _TodayCatchCard({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CatchLingoColors.warmGreen.withValues(alpha: 0.14),
            CatchLingoColors.amber.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -14,
            child: SizedBox(
              width: 152,
              height: 152,
              child: Image.asset(
                'assets/images/welcome_cat.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catch words from the world around you.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: CatchLingoColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.sm),
              Text(
                'Explore the world. Point. Discover. Learn.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CatchLingoColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: CatchLingoSpacing.lg),
              SizedBox(
                width: 138,
                child: _StartExploringButton(onPressed: onExplore),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartExploringButton extends StatefulWidget {
  const _StartExploringButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_StartExploringButton> createState() => _StartExploringButtonState();
}

class _StartExploringButtonState extends State<_StartExploringButton> {
  var _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1,
      duration: CatchLingoMotion.tap,
      curve: Curves.easeOutCubic,
      child: Listener(
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        onPointerUp: (_) => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: CatchLingoMotion.state,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CatchLingoRadius.button),
            boxShadow: [
              BoxShadow(
                color: CatchLingoColors.textPrimary.withValues(
                  alpha: _isPressed ? 0.10 : 0.18,
                ),
                blurRadius: _isPressed ? 10 : 18,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: widget.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: CatchLingoColors.textPrimary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Start Exploring'),
          ),
        ),
      ),
    );
  }
}

class _HomeStats extends StatelessWidget {
  const _HomeStats({required this.words});

  final List<CatchWord> words;

  @override
  Widget build(BuildContext context) {
    final sightings = words.fold<int>(
      0,
      (total, word) => total + (word.seenCount <= 0 ? 1 : word.seenCount),
    );
    final categories = words
        .map((word) => word.category.trim().isEmpty ? 'Other' : word.category)
        .toSet()
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeSectionTitle(title: 'Your statistics'),
        const SizedBox(height: CatchLingoSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: words.length.toString(),
                label: 'words caught',
                icon: Icons.cruelty_free_rounded,
                color: CatchLingoColors.warmGreen,
              ),
            ),
            const SizedBox(width: CatchLingoSpacing.sm),
            Expanded(
              child: _StatCard(
                value: sightings.toString(),
                label: 'sightings',
                icon: Icons.local_fire_department_rounded,
                color: CatchLingoColors.amber,
              ),
            ),
            const SizedBox(width: CatchLingoSpacing.sm),
            Expanded(
              child: _StatCard(
                value: categories.toString(),
                label: 'categories',
                icon: Icons.star_rounded,
                color: const Color(0xFFE0A51B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      padding: const EdgeInsets.all(CatchLingoSpacing.md),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: CatchLingoColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.sm),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }
}

class _HomeCategories extends StatelessWidget {
  const _HomeCategories({required this.words, required this.onDictionary});

  final List<CatchWord> words;
  final VoidCallback onDictionary;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};

    for (final word in words) {
      final category = word.category.trim().isEmpty ? 'Other' : word.category;
      counts[category] = (counts[category] ?? 0) + 1;
    }

    final entries = counts.entries.take(3).toList();
    final visibleEntries = entries.isEmpty
        ? [
            const MapEntry('Cafe', 0),
            const MapEntry('Kitchen', 0),
            const MapEntry('Travel', 0),
          ]
        : entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeSectionTitle(title: 'Your categories', action: onDictionary),
        const SizedBox(height: CatchLingoSpacing.md),
        Row(
          children: [
            for (var index = 0; index < visibleEntries.length; index++) ...[
              if (index > 0) const SizedBox(width: CatchLingoSpacing.sm),
              Expanded(
                child: _CategoryPreviewCard(
                  category: visibleEntries[index].key,
                  count: visibleEntries[index].value,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _HomeSectionTitle extends StatelessWidget {
  const _HomeSectionTitle({required this.title, this.action});

  final String title;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: action, child: const Text('View all')),
      ],
    );
  }
}

class _CategoryPreviewCard extends StatelessWidget {
  const _CategoryPreviewCard({required this.category, required this.count});

  final String category;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(CatchLingoSpacing.md),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ObjectIconBadge(category: category),
          const SizedBox(height: CatchLingoSpacing.sm),
          Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$count caught',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: CatchLingoColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectIconBadge extends StatelessWidget {
  const _ObjectIconBadge({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final icon = catchCategoryIcon(category);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: CatchLingoColors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: CatchLingoColors.warmGreen, size: 22),
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
