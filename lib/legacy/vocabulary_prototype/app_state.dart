import 'dart:async';

import 'package:flutter/foundation.dart';

import 'demo_words.dart';
import 'vocabulary_storage.dart';

class AppState extends ChangeNotifier {
  AppState({VocabularyStorage? storage})
    : _storage = storage ?? const VocabularyStorage(),
      _words = List.of(demoWords);

  final VocabularyStorage _storage;
  final List<DemoWord> _words;

  List<DemoWord> get words => List.unmodifiable(_words);

  Future<void> loadWords() async {
    final savedWords = await _storage.loadWords();

    if (savedWords == null) {
      return;
    }

    _words
      ..clear()
      ..addAll(savedWords);
    notifyListeners();
  }

  void addWord(DemoWord word) {
    _words.add(word);
    unawaited(_storage.saveWords(_words));
    notifyListeners();
  }

  bool removeWordAt(int index) {
    if (_words.length <= 1) {
      return false;
    }

    _words.removeAt(index);
    unawaited(_storage.saveWords(_words));
    notifyListeners();
    return true;
  }
}
