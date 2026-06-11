import 'package:catch_lingo/data/caught_word_storage.dart';
import 'package:catch_lingo/models/catch_word.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves caught words and mirrors stable preference keys', () async {
    const storage = CaughtWordStorage();
    final word = CatchWord(
      id: 'mobil',
      source: 'car',
      translation: 'mobil',
      category: 'Travel',
      seenCount: 1,
      lastSeenAt: DateTime(2026, 6, 12, 9),
    );

    await storage.saveWord(word);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('catch_lingo_caught_words'), isNotNull);
    expect(prefs.getStringList('caughtIDs'), ['mobil']);
    expect(prefs.getString('seenCount'), contains('"mobil":1'));
    expect(prefs.getString('lastSeenAt'), contains('2026-06-12T09:00:00.000'));
  });

  test(
    'loads words from stable preference keys when rich storage is missing',
    () async {
      SharedPreferences.setMockInitialValues({
        'caughtIDs': ['mobil'],
        'seenCount': '{"mobil":3}',
        'lastSeenAt': '{"mobil":"2026-06-12T09:00:00.000"}',
      });

      const storage = CaughtWordStorage();
      final words = await storage.loadWords();

      expect(words, hasLength(1));
      expect(words.single.id, 'mobil');
      expect(words.single.source, 'car');
      expect(words.single.translation, 'mobil');
      expect(words.single.seenCount, 3);
      expect(words.single.lastSeenAt, DateTime(2026, 6, 12, 9));
    },
  );

  test('falls back to stable keys when rich storage is corrupt', () async {
    SharedPreferences.setMockInitialValues({
      'catch_lingo_caught_words': 'not json {{{',
      'caughtIDs': ['mobil'],
      'seenCount': '{"mobil":2}',
    });

    const storage = CaughtWordStorage();
    final words = await storage.loadWords();

    expect(words, hasLength(1));
    expect(words.single.id, 'mobil');
    expect(words.single.seenCount, 2);
  });
}
