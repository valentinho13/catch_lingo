import 'package:flutter/material.dart';

import 'demo_words.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int currentIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;

  String? selectedAnswer;
  late List<String> answers;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    answers = _buildAnswers();
  }

  List<String> _buildAnswers() {
    final word = demoWords[currentIndex];

    return [word.target, ...word.wrongAnswers]..shuffle();
  }

  void _selectAnswer(String answer) {
    final word = demoWords[currentIndex];
    final isCorrect = answer == word.target;

    setState(() {
      selectedAnswer = answer;

      if (isCorrect) {
        correctCount++;
      } else {
        wrongCount++;
      }
    });
  }

  void _goToNextWord() {
    final isLastWord = currentIndex == demoWords.length - 1;

    setState(() {
      if (isLastWord) {
        isFinished = true;
        return;
      }

      currentIndex++;
      selectedAnswer = null;
      answers = _buildAnswers();
    });
  }

  void _restartTraining() {
    setState(() {
      currentIndex = 0;
      correctCount = 0;
      wrongCount = 0;
      selectedAnswer = null;
      isFinished = false;
      answers = _buildAnswers();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFinished) {
      return _TrainingResultScreen(
        correctCount: correctCount,
        wrongCount: wrongCount,
        totalCount: demoWords.length,
        onRestart: _restartTraining,
      );
    }

    final word = demoWords[currentIndex];
    final isAnswered = selectedAnswer != null;
    final isCorrect = selectedAnswer == word.target;

    return Scaffold(
      appBar: AppBar(title: const Text('Training')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      label: 'Richtig',
                      value: correctCount,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreCard(
                      label: 'Falsch',
                      value: wrongCount,
                      icon: Icons.cancel_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                'Wort ${currentIndex + 1} von ${demoWords.length}',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),

              const Spacer(),

              Text(
                'Was bedeutet dieses Wort?',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.black54),
              ),

              const SizedBox(height: 24),

              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    word.source,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              ...answers.map((answer) {
                final isSelected = selectedAnswer == answer;
                final isRightAnswer = answer == word.target;

                IconData? icon;

                if (isAnswered && isRightAnswer) {
                  icon = Icons.check_circle_rounded;
                } else if (isAnswered && isSelected && !isRightAnswer) {
                  icon = Icons.cancel_rounded;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: isAnswered ? null : () => _selectAnswer(answer),
                    icon: Icon(icon ?? Icons.circle_outlined),
                    label: Text(answer),
                  ),
                );
              }),

              const SizedBox(height: 8),

              if (isAnswered)
                Card(
                  color: isCorrect
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      isCorrect
                          ? 'Richtig.'
                          : 'Leider falsch. Richtig wäre: ${word.target}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              FilledButton(
                onPressed: isAnswered ? _goToNextWord : null,
                child: Text(
                  currentIndex == demoWords.length - 1
                      ? 'Ergebnis anzeigen'
                      : 'Nächstes Wort',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainingResultScreen extends StatelessWidget {
  const _TrainingResultScreen({
    required this.correctCount,
    required this.wrongCount,
    required this.totalCount,
    required this.onRestart,
  });

  final int correctCount;
  final int wrongCount;
  final int totalCount;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final percent = (correctCount / totalCount * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Ergebnis')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              Icon(
                percent >= 80
                    ? Icons.emoji_events_rounded
                    : Icons.school_rounded,
                size: 88,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 24),

              Text(
                'Training abgeschlossen',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '$percent % richtig',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      label: 'Richtig',
                      value: correctCount,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreCard(
                      label: 'Falsch',
                      value: wrongCount,
                      icon: Icons.cancel_rounded,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Nochmal trainieren'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Zurück zum Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              '$label: $value',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
