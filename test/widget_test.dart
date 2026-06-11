import 'package:catch_lingo/app/catch_lingo_app.dart';
import 'package:catch_lingo/data/mock_catch_words.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the CatchLingo start screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CatchLingoApp());

    expect(find.text('CatchLingo'), findsOneWidget);
    expect(
      find.textContaining('Explore the world.', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('Point. Discover. Learn.'), findsOneWidget);

    expect(find.text('Your statistics'), findsOneWidget);
    expect(find.text('Your categories'), findsOneWidget);
    expect(find.text('Dictionary'), findsOneWidget);
  });

  testWidgets('catches an automatic mock discovery', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CatchLingoApp());

    await tester.scrollUntilVisible(find.text('Start Exploring'), 160);
    await tester.tap(find.text('Start Exploring'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Something here'), findsOneWidget);
    expect(find.text('Catch it to discover the word'), findsOneWidget);
    expect(find.text('Catch'), findsOneWidget);

    await tester.tap(find.text('Catch'));
    await tester.pump();

    expect(find.text('1 caught'), findsOneWidget);
    expect(find.text('Found it'), findsOneWidget);
    expect(
      mockCatchWords.any((word) => tester.any(find.text(word.translation))),
      isTrue,
    );
  });

  testWidgets('reviews saved caught words one card at a time', (tester) async {
    SharedPreferences.setMockInitialValues({
      'catch_lingo_caught_words': '''
[{"id":"chair","source":"chair","translation":"kursi","category":"Home","languageCode":"id","confidence":0.96,"markerX":0.0,"markerY":0.0,"caughtAt":null,"seenCount":1,"lastSeenAt":null},{"id":"coffee","source":"coffee","translation":"kopi","category":"Cafe","languageCode":"id","confidence":0.94,"markerX":0.0,"markerY":0.0,"caughtAt":null,"seenCount":1,"lastSeenAt":null}]
''',
    });

    await tester.pumpWidget(const CatchLingoApp());

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.text('Remember'), findsOneWidget);
    expect(find.text('kursi'), findsOneWidget);
    expect(find.text('English hidden'), findsOneWidget);
    expect(find.text('chair'), findsNothing);

    await tester.tap(find.byTooltip('Show answer'));
    await tester.pumpAndSettle();

    expect(find.text('chair'), findsOneWidget);

    await tester.tap(find.byTooltip('Knew it'));
    await tester.pumpAndSettle();

    expect(find.text('kopi'), findsOneWidget);
    expect(find.text('English hidden'), findsOneWidget);
  });

  testWidgets('opens dictionary word detail and starts review there', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'catch_lingo_caught_words': '''
[{"id":"mobil","source":"car","translation":"mobil","category":"Travel","languageCode":"id","confidence":0.93,"markerX":0.0,"markerY":0.0,"caughtAt":"2026-06-01T09:00:00.000","seenCount":4,"lastSeenAt":"2026-06-01T09:00:00.000"}]
''',
    });

    await tester.pumpWidget(const CatchLingoApp());

    await tester.tap(find.text('Dictionary'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('car', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.text('Sightings'), findsOneWidget);
    expect(find.text('4 times'), findsOneWidget);
    expect(find.text('Review this word'), findsOneWidget);

    await tester.tap(find.text('Review this word'));
    await tester.pumpAndSettle();

    expect(find.text('Remember'), findsOneWidget);
    expect(find.text('mobil'), findsOneWidget);
  });
}
