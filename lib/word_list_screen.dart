import 'package:flutter/material.dart';

import 'app_state.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final words = appState.words;

    return Scaffold(
      appBar: AppBar(title: const Text('Meine Wörter')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: words.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final word = words[index];

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
