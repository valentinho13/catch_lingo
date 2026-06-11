import 'package:catch_lingo/models/catch_word.dart';
import 'package:catch_lingo/screens/review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _kopi = CatchWord(
  id: 'cafe.coffee',
  source: 'coffee',
  translation: 'kopi',
  category: 'Cafe',
);

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('reveals the answer on tap and finishes', (tester) async {
    await tester.pumpWidget(
      _wrap(const ReviewScreen(words: [_kopi], shuffleSeed: 1)),
    );

    expect(find.text('kopi'), findsOneWidget);
    expect(find.text('Tap to reveal'), findsOneWidget);
    expect(find.text('coffee'), findsNothing);

    await tester.tap(find.text('kopi'));
    await tester.pumpAndSettle();

    expect(find.text('coffee'), findsOneWidget);

    await tester.tap(find.text('Knew it'));
    await tester.pumpAndSettle();

    expect(find.text('Review complete'), findsOneWidget);
    expect(find.textContaining('You knew all 1'), findsOneWidget);
  });

  testWidgets('again later requeues the word once', (tester) async {
    await tester.pumpWidget(
      _wrap(const ReviewScreen(words: [_kopi], shuffleSeed: 1)),
    );

    await tester.tap(find.text('kopi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Again later'));
    await tester.pumpAndSettle();

    // The word comes back for a second pass.
    expect(find.text('kopi'), findsOneWidget);
    expect(find.text('2 of 2'), findsOneWidget);

    await tester.tap(find.text('kopi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Knew it'));
    await tester.pumpAndSettle();

    expect(find.text('Review complete'), findsOneWidget);
    expect(find.textContaining('revisited 1'), findsOneWidget);
  });
}
