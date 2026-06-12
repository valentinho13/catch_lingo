import 'package:catch_lingo/app/catch_lingo_app.dart';
import 'package:catch_lingo/data/mock_catch_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Review cards are taller than the default test surface; use a phone-sized
/// viewport so the round buttons stay tappable.
void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> tapReviewButton(WidgetTester tester, String label) async {
  final button = find.byTooltip(label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the CatchLingo start screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CatchLingoApp());

    expect(find.text('CatchLingo'), findsOneWidget);
    expect(
      find.textContaining('the camera gathers', findRichText: true),
      findsOneWidget,
    );

    expect(find.text('Your statistics'), findsOneWidget);
    expect(find.text('Your categories'), findsOneWidget);
    expect(find.text('Dictionary'), findsOneWidget);
  });

  testWidgets('collects a noticed word automatically', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CatchLingoApp());

    await tester.scrollUntilVisible(find.text('Start Exploring'), 160);
    await tester.tap(find.text('Start Exploring'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    // A word has been noticed in the scene and the counter is waiting.
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('collected'), findsOneWidget);
    expect(
      mockCatchWords.any((word) => tester.any(find.text(word.source))),
      isTrue,
    );

    // The word gets pulled into the counter on its own — no tap needed.
    await tester.pump(const Duration(milliseconds: 6900));
    await tester.pump();

    expect(find.text('Found it'), findsOneWidget);
    expect(find.text('1 caught'), findsOneWidget);
    expect(
      mockCatchWords.any((word) => tester.any(find.text(word.translation))),
      isTrue,
    );
  });

  testWidgets('shows session summary when ending explore after a catch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CatchLingoApp());

    await tester.scrollUntilVisible(find.text('Start Exploring'), 160);
    await tester.tap(find.text('Start Exploring'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 6900));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Good finds'), findsOneWidget);
    expect(find.text('Review these words'), findsOneWidget);

    await tester.tap(find.text('Review these words'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Remember'), findsOneWidget);
    expect(find.text('English hidden'), findsOneWidget);
  });

  testWidgets('reviews saved caught words one card at a time', (tester) async {
    usePhoneSurface(tester);
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

    await tapReviewButton(tester, 'Show answer');

    expect(find.text('chair'), findsOneWidget);

    await tapReviewButton(tester, 'Knew it');

    expect(find.text('kopi'), findsOneWidget);
    expect(find.text('English hidden'), findsOneWidget);

    await tapReviewButton(tester, 'Show answer');

    expect(find.text('coffee'), findsOneWidget);

    await tapReviewButton(tester, 'Again');

    // "Again" keeps the word in the round instead of finishing the review.
    expect(find.text('kopi'), findsOneWidget);
    expect(find.text('English hidden'), findsOneWidget);
    expect(find.text('Nice remembering'), findsNothing);

    await tapReviewButton(tester, 'Show answer');
    await tapReviewButton(tester, 'Knew it');

    expect(find.text('Nice remembering'), findsOneWidget);
    expect(find.text('Explore more'), findsOneWidget);
    expect(find.text('Review again'), findsOneWidget);
  });

  testWidgets('hard mode hides the picture hint during review', (tester) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({
      'catch_lingo_caught_words': '''
[{"id":"chair","source":"chair","translation":"kursi","category":"Home","languageCode":"id","confidence":0.96,"markerX":0.0,"markerY":0.0,"caughtAt":null,"seenCount":1,"lastSeenAt":null}]
''',
    });

    await tester.pumpWidget(const CatchLingoApp());

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    // Easy mode is the friendly default: the little picture helps.
    expect(find.text('Easy Mode'), findsOneWidget);
    expect(find.text('Hard Mode'), findsOneWidget);
    expect(find.text('A little picture helps you.'), findsOneWidget);
    expect(find.byIcon(Icons.chair_rounded), findsOneWidget);

    await tester.tap(find.text('Hard Mode'));
    await tester.pumpAndSettle();

    // Hard mode shows just the word — remember it on your own.
    expect(find.text('Just the word — from memory.'), findsOneWidget);
    expect(find.byIcon(Icons.chair_rounded), findsNothing);
    expect(find.text('kursi'), findsOneWidget);
  });

  testWidgets('a word marked Again comes back later in the round', (
    tester,
  ) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({
      'catch_lingo_caught_words': '''
[{"id":"chair","source":"chair","translation":"kursi","category":"Home","languageCode":"id","confidence":0.96,"markerX":0.0,"markerY":0.0,"caughtAt":null,"seenCount":1,"lastSeenAt":null},{"id":"coffee","source":"coffee","translation":"kopi","category":"Cafe","languageCode":"id","confidence":0.94,"markerX":0.0,"markerY":0.0,"caughtAt":null,"seenCount":1,"lastSeenAt":null}]
''',
    });

    await tester.pumpWidget(const CatchLingoApp());

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.text('kursi'), findsOneWidget);

    await tapReviewButton(tester, 'Show answer');
    await tapReviewButton(tester, 'Again');

    // The round moves on to the next word first.
    expect(find.text('kopi'), findsOneWidget);

    await tapReviewButton(tester, 'Show answer');
    await tapReviewButton(tester, 'Knew it');

    // The word marked Again returns instead of ending the review.
    expect(find.text('kursi'), findsOneWidget);
    expect(find.text('English hidden'), findsOneWidget);

    await tapReviewButton(tester, 'Show answer');
    await tapReviewButton(tester, 'Knew it');

    expect(find.text('Nice remembering'), findsOneWidget);
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

    expect(find.text('First caught'), findsOneWidget);
    expect(find.text('Sightings'), findsOneWidget);
    expect(find.text('4 times'), findsOneWidget);
    expect(find.text('Review this word'), findsOneWidget);

    await tester.tap(find.text('Review this word'));
    await tester.pumpAndSettle();

    expect(find.text('Remember'), findsOneWidget);
    expect(find.text('mobil'), findsOneWidget);
  });
}
