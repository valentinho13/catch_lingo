import 'package:flutter/material.dart';

import 'demo_words.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final sourceController = TextEditingController();
  final targetController = TextEditingController();
  final wrongAnswer1Controller = TextEditingController();
  final wrongAnswer2Controller = TextEditingController();
  final wrongAnswer3Controller = TextEditingController();

  @override
  void dispose() {
    sourceController.dispose();
    targetController.dispose();
    wrongAnswer1Controller.dispose();
    wrongAnswer2Controller.dispose();
    wrongAnswer3Controller.dispose();
    super.dispose();
  }

  void _saveWord() {
    final source = sourceController.text.trim();
    final target = targetController.text.trim();
    final wrongAnswer1 = wrongAnswer1Controller.text.trim();
    final wrongAnswer2 = wrongAnswer2Controller.text.trim();
    final wrongAnswer3 = wrongAnswer3Controller.text.trim();

    if (source.isEmpty ||
        target.isEmpty ||
        wrongAnswer1.isEmpty ||
        wrongAnswer2.isEmpty ||
        wrongAnswer3.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte alle Felder ausfüllen. Ja, wirklich alle.'),
        ),
      );
      return;
    }

    final newWord = DemoWord(
      source: source,
      target: target,
      wrongAnswers: [wrongAnswer1, wrongAnswer2, wrongAnswer3],
    );

    Navigator.of(context).pop(newWord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wort hinzufügen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Neues Wort',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Füge ein Wort mit richtiger Übersetzung und drei falschen Antworten hinzu.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: sourceController,
              decoration: const InputDecoration(
                labelText: 'Wort',
                hintText: 'z. B. tidur',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: targetController,
              decoration: const InputDecoration(
                labelText: 'Richtige Übersetzung',
                hintText: 'z. B. schlafen',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Falsche Antworten',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: wrongAnswer1Controller,
              decoration: const InputDecoration(
                labelText: 'Falsche Antwort 1',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: wrongAnswer2Controller,
              decoration: const InputDecoration(
                labelText: 'Falsche Antwort 2',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: wrongAnswer3Controller,
              decoration: const InputDecoration(
                labelText: 'Falsche Antwort 3',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _saveWord,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Wort speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
