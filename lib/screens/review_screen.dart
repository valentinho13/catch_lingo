import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/caught_word_storage.dart';
import '../models/catch_word.dart';
import '../widgets/catch_lingo_bottom_nav.dart';
import '../widgets/word_visuals.dart';
import 'dictionary_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';

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
      backgroundColor: CatchLingoColors.canvas,
      appBar: AppBar(title: const Text('Review')),
      bottomNavigationBar: CatchLingoBottomNav(
        selectedTab: CatchLingoTab.review,
        onSelected: _openTab,
      ),
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
                              color: CatchLingoColors.textPrimary,
                              fontWeight: FontWeight.w700,
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
                  '${words.length} ready to remember',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.lg),
                _ReviewProgress(
                  current: (_currentIndex % words.length) + 1,
                  total: words.length,
                ),
                const SizedBox(height: CatchLingoSpacing.xl),
                _ReviewCard(
                  word: currentWord,
                  current: (_currentIndex % words.length) + 1,
                  total: words.length,
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
    );
  }

  void _openTab(CatchLingoTab tab) {
    switch (tab) {
      case CatchLingoTab.discover:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case CatchLingoTab.dictionary:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DictionaryScreen()),
        );
        break;
      case CatchLingoTab.review:
        break;
    }
  }
}

class _ReviewProgress extends StatelessWidget {
  const _ReviewProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: CatchLingoColors.textPrimary.withValues(alpha: 0.08),
        valueColor: const AlwaysStoppedAnimation(CatchLingoColors.warmGreen),
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
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
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
              color: CatchLingoColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(CatchLingoRadius.card),
              border: Border.all(
                color: CatchLingoColors.amber.withValues(alpha: 0.16),
              ),
            ),
            child: const Icon(
              Icons.style_rounded,
              size: 42,
              color: CatchLingoColors.amber,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.lg),
          Text(
            'No words to review yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.sm),
          Text(
            'Catch words in Explore and they will appear here when you are ready to remember them.',
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.word,
    required this.current,
    required this.total,
    required this.isAnswerVisible,
    required this.onShowAnswer,
    required this.onAgain,
    required this.onKnewIt,
  });

  final CatchWord word;
  final int current;
  final int total;
  final bool isAnswerVisible;
  final VoidCallback onShowAnswer;
  final VoidCallback onAgain;
  final VoidCallback onKnewIt;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        key: ValueKey('${word.id}-$isAnswerVisible'),
        constraints: const BoxConstraints(minHeight: 360),
        padding: const EdgeInsets.all(CatchLingoSpacing.xl),
        decoration: BoxDecoration(
          color: CatchLingoColors.warmSurface,
          borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
          border: Border.all(
            color: CatchLingoColors.textPrimary.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$current / $total',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CatchLingoColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 52),
            Text(
              word.translation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: CatchLingoColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.md),
            _ReviewObjectIcon(word: word),
            const SizedBox(height: CatchLingoSpacing.xl),
            AnimatedSwitcher(
              duration: CatchLingoMotion.state,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.18),
                      end: Offset.zero,
                    ).animate(animation),
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.96,
                        end: 1,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                );
              },
              child: isAnswerVisible
                  ? Text(
                      word.source,
                      key: ValueKey('answer-${word.id}'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: CatchLingoColors.warmGreen,
                            fontWeight: FontWeight.w700,
                          ),
                    )
                  : Text(
                      'English hidden',
                      key: ValueKey('hidden-${word.id}'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: CatchLingoColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 44),
            if (!isAnswerVisible)
              Center(
                child: _RoundReviewButton(
                  onPressed: onShowAnswer,
                  icon: Icons.visibility_rounded,
                  color: CatchLingoColors.warmGreen,
                  foregroundColor: Colors.white,
                  label: 'Show answer',
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoundReviewButton(
                    onPressed: onAgain,
                    icon: Icons.close_rounded,
                    color: CatchLingoColors.warmSurface,
                    foregroundColor: CatchLingoColors.textMuted,
                    label: 'Again',
                  ),
                  _RoundReviewButton(
                    onPressed: onKnewIt,
                    icon: Icons.check_rounded,
                    color: CatchLingoColors.warmGreen,
                    foregroundColor: Colors.white,
                    label: 'Knew it',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ReviewObjectIcon extends StatelessWidget {
  const _ReviewObjectIcon({required this.word});

  final CatchWord word;

  @override
  Widget build(BuildContext context) {
    final icon = catchWordIcon(word);

    return Center(
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: CatchLingoColors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, color: CatchLingoColors.textPrimary, size: 34),
      ),
    );
  }
}

class _RoundReviewButton extends StatelessWidget {
  const _RoundReviewButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.foregroundColor,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: IconButton.filled(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          fixedSize: const Size.square(64),
          minimumSize: const Size.square(64),
          shadowColor: Colors.black.withValues(alpha: 0.12),
          elevation: 4,
        ),
        icon: Icon(icon),
        tooltip: label,
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
        color: CatchLingoColors.warmGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        border: Border.all(
          color: CatchLingoColors.warmGreen.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        '$current / $total',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: CatchLingoColors.warmGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
