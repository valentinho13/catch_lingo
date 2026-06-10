import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/catch_word.dart';

class CaughtWordStorage {
  const CaughtWordStorage();

  static const _wordsKey = 'catch_lingo_caught_words';

  Future<List<CatchWord>> loadWords() async {
    final preferences = await SharedPreferences.getInstance();
    final savedWords = preferences.getString(_wordsKey);

    if (savedWords == null) {
      return [];
    }

    final decodedWords = jsonDecode(savedWords) as List<dynamic>;

    final words = <CatchWord>[];

    for (final word in decodedWords) {
      try {
        words.add(CatchWord.fromMap(word as Map<String, dynamic>));
      } catch (_) {
        continue;
      }
    }

    return words;
  }

  Future<void> saveWord(CatchWord word) async {
    await _upsertWord(word);
  }

  Future<CatchWord?> reinforceWord(CatchWord detectedWord) async {
    final words = await loadWords();
    final existingIndex = words.indexWhere(
      (savedWord) => savedWord.id == detectedWord.id,
    );

    if (existingIndex == -1) {
      return null;
    }

    final reinforcedWord = words[existingIndex].seenAgain();
    words[existingIndex] = reinforcedWord;

    await _saveWords(words);

    return reinforcedWord;
  }

  Future<void> _upsertWord(CatchWord word) async {
    final words = await loadWords();
    final existingIndex = words.indexWhere(
      (savedWord) => savedWord.id == word.id,
    );

    if (existingIndex == -1) {
      words.insert(0, word);
    } else {
      words[existingIndex] = word;
    }

    await _saveWords(words);
  }

  Future<void> _saveWords(List<CatchWord> words) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedWords = jsonEncode(words.map((word) => word.toMap()).toList());

    await preferences.setString(_wordsKey, encodedWords);
  }
}
