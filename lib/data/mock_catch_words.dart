import 'package:flutter/material.dart';

import '../models/catch_word.dart';

/// A mock discovery scene — a preview of a future camera session.
class MockScene {
  const MockScene({required this.name, required this.words});

  final String name;
  final List<CatchWord> words;
}

const mockScenes = [
  MockScene(
    name: 'Cafe table',
    words: [
      CatchWord(id: 'cafe.coffee', so