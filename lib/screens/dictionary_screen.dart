import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/caught_word_storage.dart';
import '../models/catch_word.dart';
import 'explore_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  static const _storage = CaughtWordStorage();

  late Future<List<CatchWord>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _wordsFuture = _storage.loadWords();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchLingoColors.canvas,
      appBar: AppBar(title: const Text('My Dictionary')),
      body: SafeArea(
        child: FutureBuilder<List<CatchWord>>(
          future: _wordsFuture,
          builder: (context, snapshot) {
            final words = snapshot.data ?? [];

            if (words.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  CatchLingoSpacing.screen,
                  CatchLingoSpacing.sm,
                  CatchLingoSpacing.screen,
                  CatchLingoSpacing.screen,
                ),
                children: [_DictionaryEmptyState(onExplore: _openExplore)],
              );
            }

            final groupedWords = _groupWordsByCategory(words);

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                CatchLingoSpacing.screen,
                CatchLingoSpacing.sm,
                CatchLingoSpacing.screen,
                CatchLingoSpacing.screen,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Collection',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: CatchLingoColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    _ShelfCountPill(count: words.length),
                  ],
                ),
                const SizedBox(height: CatchLingoSpacing.xs),
                Text(
                  'Words caught from real scenes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.lg),
                _CollectionStats(
                  words: words,
                  categoryCount: groupedWords.length,
                ),
                const SizedBox(height: CatchLingoSpacing.xl),
                for (final entry in groupedWords.entries) ...[
                  _CategorySectionHeader(
                    label: entry.key,
                    count: entry.value.length,
                  ),
                  const SizedBox(height: CatchLingoSpacing.sm),
                  for (final word in entry.value) ...[
                    _DictionaryWordCard(word: word),
                    const SizedBox(height: CatchLingoSpacing.md),
                  ],
                  const SizedBox(height: CatchLingoSpacing.sm),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, List<CatchWord>> _groupWordsByCategory(List<CatchWord> words) {
    final groupedWords = <String, List<CatchWord>>{};

    for (final word in words) {
      final category = _categoryLabel(word.category);
      groupedWords.putIfAbsent(category, () => []).add(word);
    }

    final sortedEntries = groupedWords.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }
}

String _categoryLabel(String category) {
  final trimmedCategory = category.trim();

  if (trimmedCategory.isEmpty) {
    return 'Other';
  }

  return trimmedCategory;
}

class _CollectionStats extends StatelessWidget {
  const _CollectionStats({required this.words, required this.categoryCount});

  final List<CatchWord> words;
  final int categoryCount;

  @override
  Widget build(BuildContext context) {
    final sightings = words.fold<int>(
      0,
      (total, word) => total + (word.seenCount <= 0 ? 1 : word.seenCount),
    );

    return Container(
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              label: 'Caught',
              value: words.length.toString(),
              icon: Icons.bookmark_added_rounded,
            ),
          ),
          _StatDivider(),
          Expanded(
            child: _StatTile(
              label: 'Sightings',
              value: sightings.toString(),
              icon: Icons.visibility_rounded,
            ),
          ),
          _StatDivider(),
          Expanded(
            child: _StatTile(
              label: 'Categories',
              value: categoryCount.toString(),
              icon: Icons.category_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: CatchLingoSpacing.sm),
      color: CatchLingoColors.textPrimary.withValues(alpha: 0.10),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: CatchLingoColors.mint, size: 20),
        const SizedBox(height: CatchLingoSpacing.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: CatchLingoColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: CatchLingoColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DictionaryEmptyState extends StatelessWidget {
  const _DictionaryEmptyState({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: CatchLingoColors.mint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(CatchLingoRadius.card),
              border: Border.all(
                color: CatchLingoColors.mint.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 42,
              color: CatchLingoColors.mint,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.lg),
          Text(
            'No words collected yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.sm),
          Text(
            'Catch words in Explore and they will appear here as your collection grows.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CatchLingoColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.lg),
          FilledButton.icon(
            onPressed: onExplore,
            style: FilledButton.styleFrom(
              backgroundColor: CatchLingoColors.warmGreen,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.travel_explore_rounded),
            label: const Text('Start Exploring'),
          ),
        ],
      ),
    );
  }
}

class _ShelfCountPill extends StatelessWidget {
  const _ShelfCountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CatchLingoColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        border: Border.all(
          color: CatchLingoColors.mint.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        '$count caught words',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: CatchLingoColors.mint,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategorySectionHeader extends StatelessWidget {
  const _CategorySectionHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '$count ${count == 1 ? 'word' : 'words'}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: CatchLingoColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DictionaryWordCard extends StatelessWidget {
  const _DictionaryWordCard({required this.word});

  final CatchWord word;

  @override
  Widget build(BuildContext context) {
    final category = _categoryLabel(word.category);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: CatchLingoColors.mint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: CatchLingoColors.mint.withValues(alpha: 0.16),
              ),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: CatchLingoColors.mint,
            ),
          ),
          const SizedBox(width: CatchLingoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.translation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: CatchLingoColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: CatchLingoSpacing.sm),
                    _StatusBadge(label: category),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  word.source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.sm),
                Wrap(
                  spacing: CatchLingoSpacing.sm,
                  runSpacing: CatchLingoSpacing.xs,
                  children: [
                    _MetadataChip(
                      icon: Icons.visibility_rounded,
                      label:
                          'Seen ${word.seenCount <= 0 ? 1 : word.seenCount} ${(word.seenCount <= 1) ? 'time' : 'times'}',
                    ),
                    _MetadataChip(
                      icon: Icons.schedule_rounded,
                      label: _lastSeenLabel(word.lastSeenAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _lastSeenLabel(DateTime? lastSeenAt) {
    if (lastSeenAt == null) {
      return 'Last spotted recently';
    }

    final difference = DateTime.now().difference(lastSeenAt);

    if (difference.inDays == 0) {
      return 'Last spotted today';
    }

    if (difference.inDays == 1) {
      return 'Last spotted yesterday';
    }

    return 'Last spotted ${difference.inDays} days ago';
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: CatchLingoColors.mint),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: CatchLingoColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: CatchLingoColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        border: Border.all(
          color: CatchLingoColors.mint.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: CatchLingoColors.mint,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
