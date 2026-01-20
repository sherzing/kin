import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/presentation/screens/circle_list_screen.dart';

import '../../helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('Circle creation form', () {
    testWidgets('create button enables when name is typed with default color',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const CircleListScreen());

        // Tap FAB to open dialog
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Dialog should be open
        expect(find.text('New Circle'), findsOneWidget);

        // Find the Create button
        final createButton = find.widgetWithText(FilledButton, 'Create');
        expect(createButton, findsOneWidget);

        // Button should be disabled initially (name is empty)
        final FilledButton buttonWidget = tester.widget(createButton);
        expect(buttonWidget.onPressed, isNull);

        // Type a name in the text field
        await tester.enterText(find.byType(TextField), 'Family');
        await tester.pump();

        // Button should now be enabled (color is pre-selected by default)
        final FilledButton enabledButton = tester.widget(createButton);
        expect(enabledButton.onPressed, isNotNull);
      });
    });

    testWidgets('default color (blue) is visually selected on open',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const CircleListScreen());

        // Tap FAB to open dialog
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Should show a check icon on the default selected color
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    testWidgets('button stays enabled when selecting different colors after typing name',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const CircleListScreen());

        // Tap FAB to open dialog
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Type a name
        await tester.enterText(find.byType(TextField), 'Work');
        await tester.pump();

        // Find the Create button - should be enabled
        final createButton = find.widgetWithText(FilledButton, 'Create');
        FilledButton buttonWidget = tester.widget(createButton);
        expect(buttonWidget.onPressed, isNotNull);

        // Tap a different color (find a GestureDetector with a colored container)
        // The colors are in a Wrap, find any tappable color circle
        final colorCircles = find.byWidgetPredicate(
          (widget) =>
              widget is GestureDetector &&
              widget.child is Container,
        );
        expect(colorCircles, findsAtLeastNWidgets(1));

        // Tap the first color circle
        await tester.tap(colorCircles.first);
        await tester.pump();

        // Button should still be enabled
        buttonWidget = tester.widget(createButton);
        expect(buttonWidget.onPressed, isNotNull);
      });
    });
  });
}
