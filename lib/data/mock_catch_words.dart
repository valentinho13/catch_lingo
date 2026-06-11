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
      CatchWord(
        id: 'cafe.coffee',
        source: 'coffee',
        translation: 'kopi',
        category: 'Cafe',
      ),
      CatchWord(
        id: 'cafe.cup',
        source: 'cup',
        translation: 'cangkir',
        category: 'Cafe',
      ),
      CatchWord(
        id: 'cafe.table',
        source: 'table',
        translation: 'meja',
        category: 'Cafe',
      ),
      CatchWord(
        id: 'cafe.chair',
        source: 'chair',
        translation: 'kursi',
        category: 'Cafe',
      ),
    ],
  ),
  MockScene(
    name: 'Street market',
    words: [
      CatchWord(
        id: 'market.banana',
        source: 'banana',
        translation: 'pisang',
        category: 'Market',
      ),
      CatchWord(
        id: 'market.bag',
        source: 'bag',
        translation: 'tas',
        category: 'Market',
      ),
      CatchWord(
        id: 'market.umbrella',
        source: 'umbrella',
        translation: 'payung',
        category: 'Market',
      ),
      CatchWord(
        id: 'market.bottle',
        source: 'bottle',
        translation: 'botol',
        category: 'Market',
      ),
    ],
  ),
  MockScene(
    name: 'Hotel room',
    words: [
      CatchWord(
        id: 'hotel.bed',
        source: 'bed',
        translation: 'tempat tidur',
        category: 'Hotel',
      ),
      CatchWord(
        id: 'hotel.key',
        source: 'key',
        translation: 'kunci',
        category: 'Hotel',
      ),
      CatchWord(
        id: 'hotel.towel',
        source: 'towel',
        translation: 'handuk',
        category: 'Hotel',
      ),
      CatchWord(
        id: 'hotel.lamp',
        source: 'lamp',
        translation: 'lampu',
        category: 'Hotel',
      ),
    ],
  ),
  MockScene(
    name: 'Park path',
    words: [
      CatchWord(
        id: 'park.tree',
        source: 'tree',
        translation: 'pohon',
        category: 'Park',
      ),
      CatchWord(
        id: 'park.flower',
        source: 'flower',
        translation: 'bunga',
        category: 'Park',
      ),
      CatchWord(
        id: 'park.bench',
        source: 'bench',
        translation: 'bangku',
        category: 'Park',
      ),
      CatchWord(
        id: 'park.path',
        source: 'path',
        translation: 'jalan kecil',
        category: 'Park',
      ),
    ],
  ),
  MockScene(
    name: 'Train station',
    words: [
      CatchWord(
        id: 'station.train',
        source: 'train',
        translation: 'kereta',
        category: 'Station',
      ),
      CatchWord(
        id: 'station.ticket',
        source: 'ticket',
        translation: 'tiket',
        category: 'Station',
      ),
      CatchWord(
        id: 'station.clock',
        source: 'clock',
        translation: 'jam',
        category: 'Station',
      ),
      CatchWord(
        id: 'station.door',
        source: 'door',
        translation: 'pintu',
        category: 'Station',
      ),
    ],
  ),
];

/// All catchable mock words across scenes.
final List<CatchWord> allMockWords = [
  for (final scene in mockScenes) ...scene.words,
];

CatchWord? mockWordById(String id) {
  for (final word in allMockWords) {
    if (word.id == id) return word;
  }
  return null;
}

IconData markerIconFor(CatchWord word) {
  return switch (word.id) {
    'cafe.coffee' => Icons.local_cafe_rounded,
    'cafe.cup' => Icons.local_drink_rounded,
    'cafe.table' => Icons.table_restaurant_rounded,
    'cafe.chair' => Icons.chair_rounded,
    'market.banana' => Icons.spa_rounded,
    'market.bag' => Icons.shopping_bag_rounded,
    'market.umbrella' => Icons.beach_access_rounded,
    'market.bottle' => Icons.water_drop_rounded,
    'hotel.bed' => Icons.bed_rounded,
    'hotel.key' => Icons.key_rounded,
    'hotel.towel' => Icons.dry_cleaning_rounded,
    'hotel.lamp' => Icons.light_rounded,
    'park.tree' => Icons.park_rounded,
    'park.flower' => Icons.local_florist_rounded,
    'park.bench' => Icons.chair_alt_rounded,
    'park.path' => Icons.directions_walk_rounded,
    'station.train' => Icons.train_rounded,
    'station.ticket' => Icons.confirmation_number_rounded,
    'station.clock' => Icons.schedule_rounded,
    'station.door' => Icons.door_front_door_rounded,
    _ => Icons.center_focus_strong_rounded,
  };
}

IconData categoryIconFor(String category) {
  return switch (category) {
    'Cafe' => Icons.local_cafe_rounded,
    'Market' => Icons.storefront_rounded,
    'Hotel' => Icons.hotel_rounded,
    'Park' => Icons.park_rounded,
    'Station' => Icons.train_rounded,
    _ => Icons.auto_awesome_rounded,
  };
}
