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

  Future<void> _deleteWord(int index) async {
    final word = widget.appState.words[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wort löschen?'),
          content: Text('Möchtest du "${word.source}" wirklich löschen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final wasRemoved = widget.appState.removeWordAt(index);

    if (!wasRemoved) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mindestens ein Wort muss bleiben. Keine Anarchie.'),
        ),
      );
      return;
    }

    setState(() {});

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${word.source} wurde gelöscht.')));
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _WordListHeader(count: words.length),
          const SizedBox(height: 16),
          for (var index = 0; index < words.length; index++) ...[
            _WordCard(word: words[index], onDelete: () => _deleteWord(index)),
            const SizedBox(height: 10),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddWordScreen,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Wort'),
      ),
    );
  }
}

class _WordListHeader extends StatelessWidget {
  const _WordListHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.collections_bookmark_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count Wörter in deinem Deck',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.word, required this.onDelete});

  final DemoWord word;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.language_rounded,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.source,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.target,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Wort löschen',
            ),
          ],
        ),
      ),
    );
  }
}
