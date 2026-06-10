import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/caught_word_storage.dart';
import '../models/catch_word.dart';
import 'explore_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  static const _storage = CaughtWordStorage();

  late Future<List<CatchWord>> _wordsFuture;
  var _currentIndex = 0;
  var _isAnswerVisible = false;

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
      _currentIndex = 0;
      _isAnswerVisible = false;
      _wordsFuture = _storage.loadWords();
    });
  }

  void _showAnswer() {
    setState(() {
      _isAnswerVisible = true;
    });
  }

  void _moveNext(List<CatchWord> words) {
    if (words.isEmpty) {
      return;
    }

    setState(() {
      _currentIndex = (_currentIndex + 1) % words.length;
      _isAnswerVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070908),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070908),
        foregroundColor: Colors.white,
        title: const Text('Review'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101617), Color(0xFF070908)],
          ),
        ),
        child: SafeArea(
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
                  children: [_ReviewEmptyState(onExplore: _openExplore)],
                );
              }

              final currentWord = words[_currentIndex % words.length];

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
                          'Remember',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      _ReviewCountPill(
                        current: (_currentIndex % words.length) + 1,
                        total: words.length,
                      ),
                    ],
                  ),
                  const SizedBox(height: CatchLingoSpacing.xs),
                  Text(
                    'Review words you caught from real scenes.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: CatchLingoSpacing.xl),
                  _ReviewCard(
                    word: currentWord,
                    isAnswerVisible: _isAnswerVisible,
                    onShowAnswer: _showAnswer,
                    onAgain: () => _moveNext(words),
                    onKnewIt: () => _moveNext(words),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReviewEmptyState extends StatelessWidget {
  const _ReviewEmptyState({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111414).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
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
              Icons.style_rounded,
              size: 42,
              color: CatchLingoColors.mint,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.lg),
          Text(
            'No words to review yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.sm),
          Text(
            'Catch words in Explore and they will appear here when you are ready to remember them.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.lg),
          FilledButton.icon(
            onPressed: onExplore,
            style: FilledButton.styleFrom(
              backgroundColor: CatchLingoColors.mint,
              foregroundColor: const Color(0xFF07120E),
            ),
            icon: const Icon(Icons.travel_explore_rounded),
            label: const Text('Start Exploring'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.word,
    required this.isAnswerVisible,
    required this.onShowAnswer,
    required this.onAgain,
    required this.onKnewIt,
  });

  final CatchWord word;
  final bool isAnswerVisible;
  final VoidCallback onShowAnswer;
  final VoidCallback onAgain;
  final VoidCallback onKnewIt;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CatchLingoMotion.feedback,
      child: Container(
        key: ValueKey('${word.id}-$isAnswerVisible'),
        padding: const EdgeInsets.all(CatchLingoSpacing.xl),
        decoration: BoxDecoration(
          color: const Color(0xFF111414).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
          border: Border.all(
            color: CatchLingoColors.mint.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: CatchLingoColors.mint,
                ),
                const SizedBox(width: CatchLingoSpacing.sm),
                Text(
                  'Caught word',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: CatchLingoColors.mint,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                _CategoryBadge(label: word.category),
              ],
            ),
            const SizedBox(height: CatchLingoSpacing.xxl),
            Text(
              word.translation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.lg),
            AnimatedSwitcher(
              duration: CatchLingoMotion.state,
              child: isAnswerVisible
                  ? Text(
                      word.source,
                      key: ValueKey('answer-${word.id}'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: CatchLingoColors.mint,
                            fontWeight: FontWeight.w900,
                          ),
                    )
                  : Text(
                      'English hidden',
                      key: ValueKey('hidden-${word.id}'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.48),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: CatchLingoSpacing.xxl),
            if (!isAnswerVisible)
              FilledButton.icon(
                onPressed: onShowAnswer,
                style: FilledButton.styleFrom(
                  backgroundColor: CatchLingoColors.mint,
                  foregroundColor: const Color(0xFF07120E),
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Show answer'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onAgain,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Again'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.86),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: CatchLingoSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onKnewIt,
                      style: FilledButton.styleFrom(
                        backgroundColor: CatchLingoColors.mint,
                        foregroundColor: const Color(0xFF07120E),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Knew it'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCountPill extends StatelessWidget {
  const _ReviewCountPill({required this.current, required this.total});

  final int current;
  final int total;

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
        '$current / $total',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: CatchLingoColors.mint,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = label.trim().isEmpty ? 'Other' : label;

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
        badgeLabel,
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
