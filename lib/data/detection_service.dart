import 'dart:math';

import '../models/catch_word.dart';
import 'mock_catch_words.dart';

abstract class DetectionService {
  CatchWord? nextDetection();
}

class MockDetectionService implements DetectionService {
  MockDetectionService({this.words = mockCatchWords});

  static const _recentLimit = 3;

  final List<CatchWord> words;
  final _random = Random();
  final List<String> _recentDetectionIds = [];

  @override
  CatchWord? nextDetection() {
    if (words.isEmpty) {
      return null;
    }

    var candidates = words
        .where((word) => !_recentDetectionIds.contains(word.id))
        .toList();

    if (candidates.isEmpty) {
      candidates = List.of(words);
    }

    final word = candidates[_random.nextInt(candidates.length)];
    _remember(word.id);

    return word;
  }

  void _remember(String wordId) {
    _recentDetectionIds.add(wordId);

    if (_recentDetectionIds.length > _recentLimit) {
      _recentDetectionIds.removeAt(0);
    }
  }
}
