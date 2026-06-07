import 'package:flutter/foundation.dart';

import 'demo_words.dart';

class AppState extends ChangeNotifier {
  AppState() : _words = List.of(demoWords);

  final List<DemoWord> _words;

  List<DemoWord> get words => List.unmodifiable(_words);

  void addWord(DemoWord word) {
    _words.add(word);
    notifyListeners();
  }

  bool removeWordAt(int index) {
    if (_words.length <= 1) {
      return false;
    }

    _words.removeAt(index);
    notifyListeners();
    return true;
  }
}
