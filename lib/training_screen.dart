import 'package:flutter/material.dart';

import 'demo_words.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int currentIndex = 0;
  String? selectedAnswer;
  late List<String> answers;

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
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _goToNextWord() {
    setState(() {
      currentIndex = (currentIndex + 1) % demoWords.length;
      selectedAnswer = null;
      answers = _buildAnswers();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Text('Nächstes Wort'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
