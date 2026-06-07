import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'demo_words.dart';

class VocabularyStorage {
  const VocabularyStorage();

  static const _wordsKey = 'catch_lingo_words';

  Future<List<DemoWord>?> loadWords() async {
    final preferences = await SharedPreferences.getInstance();
    final savedWords = preferences.getString(_wordsKey);

    if (savedWords == null) {
      return null;
    }

    final decodedWords = jsonDecode(savedWords) as List<dynamic>;

    return decodedWords
        .map((word) => DemoWord.fromMap(word as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveWords(List<DemoWord> words) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedWords = jsonEncode(words.map((word) => word.toMap()).toList());

    await preferences.setString(_wordsKey, encodedWords);
  }
}
