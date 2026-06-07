import 'package:catch_lingo/app/catch_lingo_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the CatchLingo start screen', (tester) async {
    await tester.pumpWidget(const CatchLingoApp());

    expect(find.text('CatchLingo'), findsOneWidget);
    expect(find.text('Catch words from the world around you.'), findsOneWidget);
    expect(find.text('Start Exploring'), findsOneWidget);
    expect(find.text('My Dictionary'), findsOneWidget);
    expect(find.text('No words collected yet.'), findsOneWidget);
  });

  testWidgets('collects a mock discovery only once', (tester) async {
    await tester.pumpWidget(const CatchLingoApp());

    await tester.tap(find.text('Start Exploring'));
    await tester.pumpAndSettle();

    expect(find.text('Explore Mode'), findsOneWidget);
    expect(find.text('Discovery preview'), findsOneWidget);
    expect(find.text('Cafe table'), findsOneWidget);
    expect(find.text('Words collected this session: 0'), findsOneWidget);
    expect(find.text('Object'), findsWidgets);
    expect(find.text('tap to reveal'), findsWidgets);
    expect(find.text('chair'), findsNothing);
    expect(find.text('kursi'), findsNothing);

    final chairChip = find.byKey(const ValueKey('catch-chair'));

    await tester.ensureVisible(chairChip);
    await tester.tap(chairChip);
    await tester.pumpAndSettle();

    expect(find.text('Words collected this session: 1'), findsOneWidget);
    expect(find.text('kursi'), findsWidgets);
    expect(find.text('chair'), findsWidgets);
    expect(find.text('chair found nearby'), findsOneWidget);
    expect(find.text('kursi caught'), findsOneWidget);

    await tester.ensureVisible(chairChip);
    await tester.tap(chairChip);
    await tester.pumpAndSettle();

    expect(find.text('Words collected this session: 1'), findsOneWidget);
  });
}
