import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import 'explore_screen.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  static const _previewWords = [
    _DictionaryPreviewWord(
      target: 'kursi',
      source: 'chair',
      category: 'Home',
      status: 'New',
      color: Color(0xFFE5F7EF),
    ),
    _DictionaryPreviewWord(
      target: 'botol',
      source: 'bottle',
      category: 'Travel',
      status: 'Caught',
      color: Color(0xFFEFF3FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Dictionary')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const _DictionaryEmptyState(),
            const SizedBox(height: CatchLingoSpacing.xl),
            Text(
              'Collection shelf preview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: CatchLingoSpacing.sm),
            Text(
              'Caught words will live here after Explore sessions.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            const _FilterPreview(),
            const SizedBox(height: CatchLingoSpacing.lg),
            for (final word in _previewWords) ...[
              _DictionaryWordCard(word: word),
              const SizedBox(height: CatchLingoSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _DictionaryEmptyState extends StatelessWidget {
  const _DictionaryEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(CatchLingoRadius.card),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 42,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            Text(
              'No words collected yet.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: CatchLingoSpacing.sm),
            Text(
              'Start exploring to catch your first words.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
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

class _FilterPreview extends StatelessWidget {
  const _FilterPreview();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _FilterPill(label: 'All', isSelected: true),
        _FilterPill(label: 'New'),
        _FilterPill(label: 'Learning'),
        _FilterPill(label: 'Known'),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, this.isSelected = false});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DictionaryWordCard extends StatelessWidget {
  const _DictionaryWordCard({required this.word});

  final _DictionaryPreviewWord word;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: word.color,
                borderRadius: BorderRadius.circular(CatchLingoRadius.button),
              ),
              child: const Icon(Icons.check_circle_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.target,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    word.source,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _StatusBadge(label: word.category),
                      _StatusBadge(label: word.status, isStrong: true),
                    ],
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, this.isStrong = false});

  final String label;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isStrong
            ? const Color(0xFFE5F7EF)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isStrong ? const Color(0xFF145C3F) : Colors.black54,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DictionaryPreviewWord {
  const _DictionaryPreviewWord({
    required this.target,
    required this.source,
    required this.category,
    required this.status,
    required this.color,
  });

  final String target;
  final String source;
  final String category;
  final String status;
  final Color color;
}
