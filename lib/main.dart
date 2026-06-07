import 'package:flutter/material.dart';

import 'word_list_screen.dart';
import 'training_screen.dart';

void main() {
  runApp(const CatchLingoApp());
}

class CatchLingoApp extends StatelessWidget {
  const CatchLingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatchLingo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5FEF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              const Icon(
                Icons.translate_rounded,
                size: 88,
                color: Color(0xFF5B5FEF),
              ),

              const SizedBox(height: 24),

              Text(
                'CatchLingo',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Text(
                'Sammle Wörter, trainiere sie spielerisch und bleib an deinen Sprachen dran.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TrainingScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Training starten'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WordListScreen()),
                  );
                },
                icon: const Icon(Icons.collections_bookmark_rounded),
                label: const Text('Meine Wörter'),
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Einstellungen später. Erstmal laufen lernen.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Einstellungen'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
