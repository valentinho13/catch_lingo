import 'package:flutter/material.dart';

import 'add_word_screen.dart';
import 'app_state.dart';
import 'demo_words.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  Future<void> _openAddWordScreen() async {
    final newWord = await Navigator.of(
      context,
    ).push<DemoWord>(MaterialPageRoute(builder: (_) => const AddWordScreen()));

    if (newWord == null) {
      return;
    }

    setState(() {
      widget.appState.addWord(newWord);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newWord.source} wurde hinzugefügt.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.appState.words;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Wörter'),
        actions: [
          IconButton(
            onPressed: _openAddWordScreen,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Wort hinzufügen',
          ),
        ],
      ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddWordScreen,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Wort'),
      ),
    );
  }
}
