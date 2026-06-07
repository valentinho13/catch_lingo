import 'package:flutter/material.dart';

import 'demo_words.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final word = demoWords.first;

    final answers = [word.target, ...word.wrongAnswers]..shuffle();

    return Scaffold(
      appBar: AppBar(title: const Text('Training')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

              ...answers.map(
                (answer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    onPressed: () {
                      final isCorrect = answer == word.target;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isCorrect
                                ? 'Richtig.'
                                : 'Leider falsch. Richtig wäre: ${word.target}',
                          ),
                        ),
                      );
                    },
                    child: Text(answer),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
