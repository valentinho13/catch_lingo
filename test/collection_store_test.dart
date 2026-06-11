import 'package:catch_lingo/services/collection_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('starts empty', () async {
    final store = CollectionStore();
    final data = await store.load();

    expect(data.caughtIds, isEmpty);
    expect(data.seenCounts, isEmpty);
    expect(data.lastSeenAt, isEmpty);
  });

  test('first spot is a new catch', () async {
    final store = CollectionStore();
    final outcome = await store.recordSpot('cafe.coffee');

    expect(outcome.isNewCatch, isTrue);
    expect(outcome.seenCount, 1);

    final data = await store.load();
    expect(data.isCaught('cafe.coffee'), isTrue);
    expect(data.seenCount('cafe.coffee'), 1);
    expect(data.lastSeenAt['cafe.coffee'], isNotNull);
  });

  test('repeated spots bump the seen count without re-catching', () async {
    final store = CollectionStore();
    await store.recordSpot('cafe.coffee');
    final second = await store.recordSpot('cafe.coffee');
    final third = await store.recordSpot('cafe.coffee');

    expect(second.isNewCatch, isFalse);
    expect(second.seenCount, 2);
    expect(third.seenCount, 3);

    final data = await store.load();
    expect(data.caughtIds, {'cafe.coffee'});
    expect(data.seenCount('cafe.coffee'), 3);
  });

  test('updates lastSeenAt on every spot', () async {
    final store = CollectionStore();
    final first = DateTime(2026, 6, 1, 9);
    final later = DateTime(2026, 6, 11, 18);

    await store.recordSpot('cafe.cup', now: first);
    var data = await store.load();
    expect(data.lastSeenAt['cafe.cup'], first);

    await store.recordSpot('cafe.cup', now: later);
    data = await store.load();
    expect(data.lastSeenAt['cafe.cup'], later);
  });

  test('tolerates corrupt stored values', () async {
    SharedPreferences.setMockInitialValues({
      'caughtIDs': ['cafe.coffee'],
      'seenCount': 'not json {{{',
      'lastSeenAt': 'also broken',
    });

    final store = CollectionStore();
    final data = await store.load();

    expect(data.isCaught('cafe.coffee'), isTrue);
    expect(data.seenCounts, isEmpty);
    expect(data.lastSeenAt, isEmpty);

    // And recording still works afterwards.
    final outcome = await store.recordSpot('cafe.coffee');
    expect(outcome.isNewCatch, isFalse);
    expect(outcome.seenCount, 1);
  });
}
