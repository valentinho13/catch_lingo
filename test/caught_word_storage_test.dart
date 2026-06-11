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
}
