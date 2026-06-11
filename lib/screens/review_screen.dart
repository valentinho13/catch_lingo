import 'dart:math';

import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/mock_catch_words.dart';
import '../models/catch_word.dart';

/// Lightweight flashcard review over caught words.
///
/// Intentionally simple: tap to reveal, self-assess, done.
/// No spaced repetition yet — review supports discovery, it does not
/// replace it.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.words, this.shuffleSeed});

  final List<CatchWord> words;

  /// Fixed seed for deterministic order in tests.
  final int? shuffleSeed;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final List<CatchWord> _queue;
  late final int _initialCount;

  int _index = 0;
  bool _revealed = false;
  int _knewCount = 0;
  int _learningCount = 0;

  @override
  void initState() {
    super.initState();
    _queue = [...widget.words]
      ..shuffle(widget.shuffleSeed == null ? Random() : Random(widget.shuffleSeed));
    _initialCount = _queue.length;
  }

  bool get _done => _index >= _queue.length;

  CatchWord get _current => _queue[_index];

  void _reveal() {
    if (!_revealed) setState(() => _revealed = true);
  }

  void _answer({required bool knewIt}) {
    setState(() {
      if (knewIt) {
        _knewCount += 1;
      } else {
        _learningCount += 1;
        // Give the word one more pass at the end of this round.
        if (!_queue.sublist(_index + 1).contains(_current)) {
          _queue.add(_current);
        }
      }
      _index += 1;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        actions: [
          if (!_done)
            Padding(
              padding: const EdgeInsets.only(right: CatchLingoSpacing.lg),
              child: Center(
                child: Text(
                  '${_index + 1} of ${_queue.length}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CatchLingoSpacing.screen),
          child: _done ? _buildSummary(context) : _buildCard(context),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final word = _current;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _reveal,
            child: AnimatedContainer(
              duration: CatchLingoMotion.state,
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: const EdgeInsets.all(CatchLingoSpacing.xl),
              decoration: BoxDecoration(
                color: _revealed
                    ? CatchLingoColors.successSurface
                    : CatchLingoColors.card,
                borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
                border: Border.all(
                  color: _revealed
                      ? CatchLingoColors.successBorder
                      : Colors.white,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.10),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    markerIconFor(word),
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: CatchLingoSpacing.xl),
                  Text(
                    word.translation,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: CatchLingoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: CatchLingoSpacing.lg),
                  AnimatedSwitcher(
                    duration: CatchLingoMotion.feedback,
                    child: _revealed
                        ? Text(
                            word.source,
                            key: const ValueKey('answer'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: CatchLingoColors.successText,
                                  fontWeight: FontWeight.w700,
                                ),
                          )
                        : Text(
                            'Tap to reveal',
                            key: const ValueKey('hint'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: CatchLingoColors.textMuted),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: CatchLingoSpacing.lg),
        AnimatedOpacity(
          duration: CatchLingoMotion.feedback,
          opacity: _revealed ? 1 : 0,
          child: IgnorePointer(
            ignoring: !_revealed,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _answer(knewIt: false),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Again later'),
                  ),
                ),
                const SizedBox(width: CatchLingoSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _answer(knewIt: true),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Knew it'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
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
        const SizedBox(height: CatchLingoSpacing.xl),
        Text(
          'Review complete',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: CatchLingoSpacing.sm),
        Text(
          _summaryLine(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: CatchLingoColors.textMuted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: CatchLingoSpacing.xxl),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.menu_book_rounded),
          label: const Text('Back to Dictionary'),
        ),
      ],
    );
  }

  String _summaryLine() {
    if (_learningCount == 0) {
      return 'You knew all $_initialCount '
          '${_initialCount == 1 ? 'word' : 'words'}. Your journal is alive.';
    }
    return 'You knew $_knewCount and revisited $_learningCount — '
        'they will stick soon.';
  }
}
