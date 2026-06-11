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
    expect(find.text('kursi')