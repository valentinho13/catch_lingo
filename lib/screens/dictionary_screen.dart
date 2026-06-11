import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/mock_catch_words.dart';
import '../models/catch_word.dart';
import '../services/collection_store.dart';
import 'explore_screen.dart';
import 'review_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final CollectionStore _store = CollectionStore();

  CollectionData _collection = const CollectionData.empty();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    final data = await _store.load();
    if (!mounted) return;
    setState(() {
      _collection = data;
      _loaded = true;
    });
  }

  List<CatchWord> get _caughtWords => [
        for (final word in allMockWords)
          if (_collection.isCaught(word.id)) word,
      ];

  @override
  Widget build(BuildContext context) {
    final caughtWords = _caughtWords;

    return Scaffold(
      appBar: AppBar(title: const Text('My Dictionary')),
      body: SafeArea(
        child: !_loaded
            ? const SizedBox.shrink()
            : caughtWords.isEmpty
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: const [_DictionaryEmptyState()],
                  )
                : _DictionaryContent(
                    words: caughtWords,
                    collection: _collection,
                    onReviewDone: _loadCollection,
                  ),
      ),
    );
  }
}

class _DictionaryContent extends StatelessWidget {
  const _DictionaryContent({
    required this.words,
    required this.collection,
    required this.onReviewDone,
  });

  final List<CatchWord> words;
  final CollectionData collection;
  final VoidCallback onReviewDone;

  @override
  Widget build(BuildContext context) {
    final categories = <String, List<CatchWord>>{};
    for (final word in words) {
      categories.putIfAbsent(word.category, () => []).add(word);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        _JournalSummaryCard(caughtCount: words.length),
        const SizedBox(height: CatchLingoSpacing.lg),
        FilledButton.tonalIcon(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ReviewScreen(words: words)),
            );
            onReviewDone();
          },
          icon: const Icon(Icons.style_rounded),
          label: const Text('Review your words'),
        ),
        const SizedBox(height: CatchLingoSpacing.xl),
        for (final entry in categories.entries) ...[
          _CategoryHeader(category: entry.key, count: entry.value.length),
          const SizedBox(height: CatchLingoSpacing.md),
          for (final word in entry.value) ...[
            _DictionaryWordCard(word: word, collection: collection),
            const SizedBox(height: CatchLingoSpacing.md),
          ],
          const SizedBox(height: CatchLingoSpacing.sm),
        ],
      ],
    );
  }
}

class _JournalSummaryCard extends StatelessWidget {
  const _JournalSummaryCard({required this.caughtCount});

  final int caughtCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = allMockWords.length;

    return Container(
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CatchLingoColors.successSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: CatchLingoColors.successIcon,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$caughtCount ${caughtCount == 1 ? 'word' : 'words'} caught',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  caughtCount >= total
                      ? 'You caught every word out there — for now.'
                      : '${total - caughtCount} more waiting in the scenes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.count});

  final String category;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          categoryIconFor(category),
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: CatchLingoSpacing.sm),
        Expanded(
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: CatchLingoColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DictionaryEmptyState extends StatelessWidget {
  const _DictionaryEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: CatchLingoColors.card,
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CatchLingoColors.amberSurface,
                    CatchLingoColors.successSurface,
                  ],
                ),
                borderRadius: BorderRadius.circular(CatchLingoRadius.card),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 42,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            Text(
              'No words caught yet.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: CatchLingoSpacing.sm),
            Text(
              'Start exploring to catch your first real-world words.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CatchLingoColors.textMuted,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ExploreScreen()),
                );
              },
              icon: const Icon(Icons.travel_explore_rounded),
              label: const Text('Start Exploring'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DictionaryWordCard extends StatelessWidget {
  const _DictionaryWordCard({required this.word, required this.collection});

  final CatchWord word;
  final CollectionData collection;

  @override
  Widget build(BuildContext context) {
    final seenCount = collection.seenCount(word.id);
    final lastSeen = collection.lastSeenAt[word.id];

    return Container(
      decoration: BoxDecoration(
        color: CatchLingoColors.card,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12443C28),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: CatchLingoColors.successSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                markerIconFor(word),
                color: CatchLingoColors.successIcon,
              ),
            ),
            const SizedBox(width: CatchLingoSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.translation,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: CatchLingoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    word.source,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CatchLingoColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: CatchLingoSpacing.sm),
                  Text(
                    _spotInfo(seenCount, lastSeen),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: CatchLingoColors.textMuted,
                 