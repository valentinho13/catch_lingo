import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/catch_word.dart';
import 'mock_catch_words.dart';

class CaughtWordStorage {
  const CaughtWordStorage();

  static const _wordsKey = 'catch_lingo_caught_words';
  static const _caughtIdsKey = 'caughtIDs';
  static const _seenCountKey = 'seenCount';
  static const _lastSeenAtKey = 'lastSeenAt';

  Future<List<CatchWord>> loadWords() async {
    final preferences = await SharedPreferences.getInstance();
    final savedWords = preferences.getString(_wordsKey);

    if (savedWords == null || savedWords.isEmpty) {
      return _loadFromStableKeys(preferences);
    }

    final decodedWords = _decodeList(savedWords);

    if (decodedWords == null) {
      return _loadFromStableKeys(preferences);
    }

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
    await preferences.setStringList(
      _caughtIdsKey,
      words.map((word) => word.id).toList(),
    );
    await preferences.setString(
      _seenCountKey,
      jsonEncode({for (final word in words) word.id: word.seenCount}),
    );
    await preferences.setString(
      _lastSeenAtKey,
      jsonEncode({
        for (final word in words)
          if (word.lastSeenAt != null)
            word.id: word.lastSeenAt!.toIso8601String(),
      }),
    );
  }

  List<CatchWord> _loadFromStableKeys(SharedPreferences preferences) {
    final caughtIds = preferences.getStringList(_caughtIdsKey) ?? const [];
    if (caughtIds.isEmpty) {
      return [];
    }

    final seenCounts = _decodeMap(preferences.getString(_seenCountKey));
    final lastSeenAt = _decodeMap(preferences.getString(_lastSeenAtKey));
    final words = <CatchWord>[];

    for (final id in caughtIds) {
      final word = _wordById(id);
      if (word == null) {
        continue;
      }

      final seenCount = seenCounts[id];
      final lastSeenRaw = lastSeenAt[id];
      final lastSeen = lastSeenRaw is String
          ? DateTime.tryParse(lastSeenRaw)
          : null;

      words.add(
        CatchWord(
          id: word.id,
          source: word.source,
          translation: word.translation,
          category: word.category,
          languageCode: word.languageCode,
          confidence: word.confidence,
          markerX: word.markerX,
          markerY: word.markerY,
          caughtAt: lastSeen,
          seenCount: seenCount is int ? seenCount : 1,
          lastSeenAt: lastSeen,
        ),
      );
    }

    return words;
  }

  CatchWord? _wordById(String id) {
    for (final word in mockCatchWords) {
      if (word.id == id) return word;
    }
    return null;
  }

  List<dynamic>? _decodeList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return decoded;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Map<String, Object?> _decodeMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
    } on FormatException {
      return const {};
    }

    return const {};
  }
}
