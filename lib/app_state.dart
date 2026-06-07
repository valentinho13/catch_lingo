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
}
