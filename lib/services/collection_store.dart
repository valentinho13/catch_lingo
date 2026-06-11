import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Snapshot of the persisted collection.
class CollectionData {
  const CollectionData({
    required this.caughtIds,
    required this.seenCounts,
    required this.lastSeenAt,
  });

  const CollectionData.empty()
    : caughtIds = const {},
      seenCounts = const {},
      lastSeenAt = const {};

  final Set<String> caughtIds;
  final Map<String, int> seenCounts;
  final Map<String, DateTime> lastSeenAt;

  bool isCaught(String id) => caughtIds.contains(id);
  int seenCount(String id) => seenCounts[id] ?? 0;

  int? daysSinceLastSeen(String id, {DateTime? now}) {
    final lastSeen = lastSeenAt[id];
    if (lastSeen == null) return null;

    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final seenDay = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);
    return today.difference(seenDay).inDays;
  }

  bool isFading(String id, {DateTime? now}) {
    final days = daysSinceLastSeen(id, now: now);
    return days != null && days >= 7;
  }
}

/// Result of spotting a word in the world.
class SpotOutcome {
  const SpotOutcome({required this.isNewCatch, required this.seenCount});

  /// True when this spot caught the word for the first time.
  final bool isNewCatch;

  /// How often the word has been spotted in total (including this spot).
  final int seenCount;
}

/// Persists the caught-word collection with SharedPreferences.
///
/// Storage keys are part of the app's saved data — never rename them
/// without a migration:
///  - `caughtIDs`: StringList of caught word ids
///  - `seenCount`: JSON map id -> spot count
///  - `lastSeenAt`: JSON map id -> ISO-8601 timestamp
class CollectionStore {
  static const caughtIdsKey = 'caughtIDs';
  static const seenCountKey = 'seenCount';
  static const lastSeenAtKey = 'lastSeenAt';

  Future<CollectionData> load() async {
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs);
  }

  /// Records that [id] was spotted right now.
  ///
  /// First spot catches the word; later spots only bump the seen count.
  Future<SpotOutcome> recordSpot(String id, {DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final data = _read(prefs);

    final isNewCatch = !data.caughtIds.contains(id);
    final seenCount = data.seenCount(id) + 1;

    final caughtIds = {...data.caughtIds, id};
    final seenCounts = {...data.seenCounts, id: seenCount};
    final lastSeenAt = {...data.lastSeenAt, id: now ?? DateTime.now()};

    await prefs.setStringList(caughtIdsKey, caughtIds.toList());
    await prefs.setString(seenCountKey, jsonEncode(seenCounts));
    await prefs.setString(
      lastSeenAtKey,
      jsonEncode(
        lastSeenAt.map((key, value) => MapEntry(key, value.toIso8601String())),
      ),
    );

    return SpotOutcome(isNewCatch: isNewCatch, seenCount: seenCount);
  }

  CollectionData _read(SharedPreferences prefs) {
    final caughtIds = prefs.getStringList(caughtIdsKey)?.toSet() ?? <String>{};

    final seenCounts = <String, int>{};
    final lastSeenAt = <String, DateTime>{};

    final seenJson = _decodeMap(prefs.getString(seenCountKey));
    for (final entry in seenJson.entries) {
      final value = entry.value;
      if (value is int) seenCounts[entry.key] = value;
    }

    final lastSeenJson = _decodeMap(prefs.getString(lastSeenAtKey));
    for (final entry in lastSeenJson.entries) {
      final value = entry.value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) lastSeenAt[entry.key] = parsed;
      }
    }

    return CollectionData(
      caughtIds: caughtIds,
      seenCounts: seenCounts,
      lastSeenAt: lastSeenAt,
    );
  }

  Map<String, Object?> _decodeMap(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) return decoded;
    } on FormatException {
      // Corrupt value — treat as empty rather than crashing the app.
    }
    return const {};
  }
}
