import 'package:catch_lingo/app/catch_lingo_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the CatchLingo start screen', (tester) async {
    await tester.pumpWidget(const CatchLingoApp());
    await tester.pump();

    expect(find.text('CatchLingo'), findsOneWidget);
    expect(find.text('Catch words from the world around you.'), findsOneWidget);
    expect(find.text('Start Exploring'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('My Dictionary'), 160);

    expect(find.text('My Dictionary'), findsOneWidget);
    expect(find.text('No words caught yet.'), findsOneWidget);
  });

  testWidgets('catches a word once and rewards spotting it again', (
    tester,
  ) async {
    await tester.pumpWidget(const CatchLingoApp());
    await tester.pump();

    await tester.tap(find.text('Start Exploring'));
    await tester.pumpAndSettle();

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Discovery preview'), findsOneWidget);
    expect(find.text('Cafe table'), findsOneWidget);
    expect(find.text('0 caught this session'), findsOneWidget);
    expect(find.text('Object'), findsWidgets);
    expect(find.text('chair'), findsNothing);
    expect(find.text('kursi'), findsNothing);

    final chairChip = find.byKey(const ValueKey('catch-chair'));

    await tester.ensureVisible(chairChip);
    await tester.tap(chairChip);
    await tester.pumpAndSettle();

    // Catch reveal: the translation is the reward.
    expect(find.text('1 caught this session'), findsOneWidget);
    expect(find.text('Caught!'), findsOneWidget);
    expect(find.text('kursi'), findsWidgets);
    expect(find.text('chair'), findsWidgets);

    // Spotting the same word again is a micro-reward, not a new catch.
    await tester.ensureVisible(chairChip);
    await tester.tap(chairChip);
    await tester.pumpAndSettle();

    expect(find.text('1 caught this session'), findsOneWidget);
    expect(find.text('kursi — you know this one!'), findsOneWidget);
    expect(find.textContaining('Spotted 2×'), findsOneWidget);
  });

  testWidgets('switches to the next scene', (tester) async {
    await tester.pumpWidget(const CatchLingoApp());
    await tester.pump();

    await tester.tap(find.text('Start Exploring'));
    await tester.pumpAndSettle();

    expect(find.text('Cafe table'), findsOneWidget);

    await tester.tap(find.text('Next scene'));
    await tester.pumpAndSettle();

    expect(find.text('Street market'), findsOneWidget);
    expect(find.text('Cafe table'), findsNothing);
  });

  testWidgets('caught words appear in the dictionary', (tester) async {
    await tester.pumpWidget(const CatchLingoApp());
    await tester.pump();

    await tester.tap(find.text('Start Exploring'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('catch-coffee')));
    await tester.tap(find.byKey(const ValueKey('catch-coffee')));
    await tester.pumpAndSettle();

    // Back home, then into the dictionary.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('My Dictionary'), 160);
    await tester.tap(find.text('My Dictionary'));
    await tester.pumpAndSettle();

    expect(find.text('1 word caught'), findsOneWidget);
    expect(find.text('kopi'), findsOneWidget);
    expect(find.text('coffee'), findsOneWidget);
    expect(find.text('Review your words'), findsOneWidget);
    expect(find.textContaining('Spotted once'), findsOneWidget);
  });

  testWidgets('empty dictionary encourages exploring', (tester) async {
    await tester.pumpWidget(const CatchLingoApp());
    await tester.pump();

    await tester.scrollUntilVisible(find.text('My Dictionary'), 160);
    await tester.tap(find.text('My Dictionary'));
    await tester.pumpAndSettle();

    expect(find.text('No words caught yet.'), findsOneWidget);
    expect(
      find.text('Start exploring to catch your first real-world words.'),
      findsOneWidget,
    );
    expect(find.text('Review your words'), findsNothing);
  });

  testWidgets('finishing a session shows the summary', (tester) async {
    await tester.pumpWidget(const CatchLingoApp());
    await tester.pump();

    await tester.tap(find.text('Start Exploring'));
    await tester.pumpAndSettle();

    // No session activity yet, so the session cannot be finished.
    expect(find.text('Finish session'), findsNothing);

    final chairChip = find.byKey(const ValueKey('catch-chair'));
    await tester.ensureVisible(chairChip);
    await tester.tap(chairChip);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish session'));
    await tester.pumpAndSettle();

    expect(find.text('Session complete'), findsOneWidget);
    expect(find.textContaining('1 new word'), findsOneWidget);
    expect(find.text('kursi'), findsOneWidget);
    expect(find.text('Review these words'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Back home with the catch persisted.
    expect(find.text('Start Exploring'), findsOneWidget);
    expect(find.text('1 word in your journal.'), findsOneWidget);
  });
}
