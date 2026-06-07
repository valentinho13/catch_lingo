import 'package:flutter/material.dart';

import 'demo_words.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Wörter')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demoWords.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final word = demoWords[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(
                word.source,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(word.target),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          );
        },
      ),
    );
  }
}
