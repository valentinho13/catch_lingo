import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/mock_catch_words.dart';
import '../models/catch_word.dart';
import 'review_screen.dart';

/// The reward screen after an explore session.
///
/// Shows what was caught in this session — new words and words
/// spotted again — and offers an immediate review.
class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({
    super.key,
    required this.newWords,
    required this.seenAgainWords,
  });

  final List<CatchWord> newWords;
  final List<CatchWord> seenAgainWords;

  List<CatchWord> get _allWords => [...newWords, ...seenAgainWords];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchLingoSpacing.screen,
            CatchLingoSpacing.sm,
            CatchLingoSpacing.screen,
            CatchLingoSpacing.screen,
          ),
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: CatchLingoColors.successSurface,
                  borderRadius: BorderRadius.circular(CatchLingoRadius.card),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 44,
                  color: CatchLingoColors.successIcon,
                ),
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            Text(
              'Session complete',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.sm),
            Text(
              _subtitle(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CatchLingoColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    count: newWords.length,
                    label: newWords.length == 1 ? 'new word' : 'new words',
                    surface: CatchLingoColors.successSurface,
                    accent: CatchLingoColors.successText,
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),
                if (seenAgainWords.isNotEmpty) ...[
                  const SizedBox(width: CatchLingoSpacing.md),
                  Expanded(
                    child: _StatCard(
                      count: seenAgainWords.length,
                      label: 'spotted again',
                      surface: CatchLingoColors.amberSurface,
                      accent: CatchLingoColors.amberText,
                      icon: Icons.visibility_rounded,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: CatchLingoSpacing.xl),
            Text(
              'Your words from this session',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.md),
            for (final word in newWords) ...[
              _SessionWordCard(word: word, isNew: true),
              const SizedBox(height: CatchLingoSpacing.md),
            ],
            for (final word in seenAgainWords) ...[
              _SessionWordCard(word: word, isNew: false),
              const SizedBox(height: CatchLingoSpacing.md),
            ],
            const SizedBox(height: CatchLingoSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReviewScreen(words: _allWords),
                  ),
                );
              },
              icon: const Icon(Icons.style_rounded),
              label: const Text('Review these words'),
            ),
            const SizedBox(height: CatchLingoSpacing.md),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final newCount = newWords.length;
    final againCount = seenAgainWords.length;
    if (newCount == 0) {
      return 'You revisited $againCount '
          '${againCount == 1 ? 'word' : 'words'} you already knew.';
    }
    if (againCount == 0) {
      return 'You caught $newCount new '
          '${newCount == 1 ? 'word' : 'words'} from the world.';
    }
    return 'You caught $newCount new '
        '${newCount == 1 ? 'word' : 'words'} and revisited $againCount.';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.count,
    required this.label,
    required this.surface,
    required this.accent,
    required this.icon,
  });

  final int count;
  final String label;
  final Color surface;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: CatchLingoSpacing.sm),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionWordCard extends StatelessWidget {
  const _SessionWordCard({required this.word, required this.isNew});

  final CatchWord word;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final surface = isNew
        ? CatchLingoColors.successSurface
        : CatchLingoColors.amberSurface;
    final accent = isNew
        ? CatchLingoColors.successIcon
        : CatchLingoColors.amberText;

    return Container(
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      decoration: BoxDecoration(
        color: CatchLingoColors.card,
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12443C28),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(markerIconFor(word), size: 22, color: accent),
          ),
          const SizedBox(width: CatchLingoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.translation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: CatchLingoColors.textPrimary,
                  ),
                ),
                Text(
                  word.source,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!isNew)
            Text(
              'known',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CatchLingoColors.amberText,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}
