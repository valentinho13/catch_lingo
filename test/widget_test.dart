import 'package:catch_lingo/app/catch_lingo_app.dart';
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
    expect(find.text('Point. Discover. Learn.'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('My Dictionary'), 160);

    expect(find.text('My Dictionary'), findsOneWidget);
    expect(find.text('No words collected yet.'), findsOneWidget);
  });

  testWidgets('catches an automatic mock discovery', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CatchLingoApp());

    await tester.scrollUntilVisible(find.text('Start Exploring'), 160);
    await tester.tap(find.text('Start Exploring'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('Explore Mode'), findsOneWidget);
    expect(find.text('Live scene'), findsOneWidget);
    expect(find.text('New discovery'), findsOneWidget);
    expect(find.text('Catch word'), findsOneWidget);

    await tester.tap(find.text('Catch word'));
    await tester.pump();

    expect(find.text('1 caught'), findsOneWidget);
  });

  testWidgets('reviews saved caught words one card at a time', (tester) async {
    SharedPreferences.setMockInitialValues({
      'catch_lingo_caught_words': '''
[{"id":"chair","source":"chair","translation":"kursi","category":"Home","languageCode":"id","confidence":0.96,"markerX":0.0,"markerY":0.0,"caughtAt":null,"seenCount":1,"lastSeenAt":null},{"id":"coffee","source":"coffee","translation":"kopi","category":"Cafe","languageCode":"id","confidence":0.94,"markerX":0.0,"markerY":0.0,"caughtAt":null,"seenCount":1,"lastSeenAt":null}]
''',
    });

    await tester.pumpWidget(const CatchLingoApp());

    await tester.scrollUntilVisible(find.text('Review'), 160);
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('kursi'), findsOneWidget);
    expect(find.text('English hidden'), findsOneWidget);
    expect(find.text('chair'), findsNothing);

    await tester.tap(find.text('Show answer'));
    await tester.pumpAndSettle();

    expect(find.text('chair'), findsOneWidget);

    await tester.tap(find.text('Knew it'));
    await tester.pumpAndSettle();

    expect(find.text('kopi'), findsOneWidget);
    expect(find.text('English hidden'), findsOneWidget);
  });
}
