import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/presentation/widgets/widgets.dart';

void main() {
  group('EmptyStateIllustration', () {
    testWidgets('renders with required properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateIllustration(
              icon: Icons.person,
              title: 'Test Title',
              subtitle: 'Test Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders action button when provided', (WidgetTester tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateIllustration(
              icon: Icons.add,
              title: 'Title',
              subtitle: 'Subtitle',
              actionLabel: 'Add Item',
              onAction: () => actionPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      // FilledButton.icon is used, find by text instead
      expect(find.widgetWithText(FilledButton, 'Add Item'), findsOneWidget);

      await tester.tap(find.text('Add Item'));
      await tester.pump();

      expect(actionPressed, isTrue);
    });

    testWidgets('does not render action button when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateIllustration(
              icon: Icons.info,
              title: 'Title',
              subtitle: 'Subtitle',
            ),
          ),
        ),
      );

      // No action button should be present
      expect(find.byWidgetPredicate((w) => w is FilledButton), findsNothing);
    });

    testWidgets('renders secondary icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateIllustration(
              icon: Icons.people,
              secondaryIcon: Icons.favorite,
              title: 'Title',
              subtitle: 'Subtitle',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('uses custom decoration color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateIllustration(
              icon: Icons.star,
              title: 'Title',
              subtitle: 'Subtitle',
              decorationColor: Colors.orange,
            ),
          ),
        ),
      );

      // Find the icon and verify it has the custom color
      final iconFinder = find.byIcon(Icons.star);
      expect(iconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, equals(Colors.orange));
    });
  });

  group('AllCaughtUpIllustration', () {
    testWidgets('renders celebration message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AllCaughtUpIllustration(),
          ),
        ),
      );

      expect(find.text("You're all caught up!"), findsOneWidget);
      expect(find.textContaining('No contacts are due'), findsOneWidget);
      expect(find.byIcon(Icons.celebration_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('uses green color theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AllCaughtUpIllustration(),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.celebration_outlined);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, equals(Colors.green));
    });
  });

  group('NoContactsIllustration', () {
    testWidgets('renders add contact message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoContactsIllustration(),
          ),
        ),
      );

      expect(find.text('Start building your network'), findsOneWidget);
      expect(find.textContaining('Add the people'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('renders action button when callback provided',
        (WidgetTester tester) async {
      bool addPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoContactsIllustration(
              onAddContact: () => addPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Your First Contact'), findsOneWidget);

      await tester.tap(find.text('Add Your First Contact'));
      await tester.pump();

      expect(addPressed, isTrue);
    });

    testWidgets('does not render action button without callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoContactsIllustration(),
          ),
        ),
      );

      expect(find.text('Add Your First Contact'), findsNothing);
    });
  });

  group('NoInteractionsIllustration', () {
    testWidgets('renders log interaction message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoInteractionsIllustration(),
          ),
        ),
      );

      expect(find.text('No interactions yet'), findsOneWidget);
      expect(find.textContaining('Log your conversations'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('renders action button when callback provided',
        (WidgetTester tester) async {
      bool logPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoInteractionsIllustration(
              onLogInteraction: () => logPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Log First Interaction'), findsOneWidget);

      await tester.tap(find.text('Log First Interaction'));
      await tester.pump();

      expect(logPressed, isTrue);
    });
  });
}
